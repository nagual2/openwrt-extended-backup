#!/usr/bin/env python3
"""Generate a numbered commit report for commits ahead of upstream."""
from __future__ import annotations

import argparse
import datetime as dt
import os
import re
import subprocess
import sys
from typing import Iterable, List, Sequence
from urllib.parse import urlparse, urlunparse

DEFAULT_UPSTREAM_URL = os.environ.get(
    "UPSTREAM_URL", "https://github.com/kkkkCampbell/master.git"
)
DEFAULT_UPSTREAM_REMOTE = os.environ.get("UPSTREAM_REMOTE", "upstream")
DEFAULT_UPSTREAM_BRANCH = os.environ.get("UPSTREAM_BRANCH", "main")
DEFAULT_LOCAL_BRANCH = os.environ.get("LOCAL_BRANCH", "main")
DEFAULT_REPORT_DIR = os.environ.get("REPORT_DIR", os.path.join("docs"))
CATEGORY_LABELS = {
    "feat": "Feature",
    "fix": "Bug Fix",
    "refactor": "Refactor",
    "docs": "Docs",
    "ci": "CI",
    "chore": "Chore",
    "test": "Test",
    "build": "Build",
    "perf": "Performance",
}


def run_git(command: Sequence[str], check: bool = True) -> subprocess.CompletedProcess[str]:
    """Run a git command and return the completed process."""
    return subprocess.run(
        ["git", *command],
        check=check,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )


def ensure_repo_root() -> str:
    """Return the repository root and set cwd accordingly."""
    completed = run_git(["rev-parse", "--show-toplevel"])
    repo_root = completed.stdout.strip()
    if not repo_root:
        raise RuntimeError("Unable to determine repository root")
    os.chdir(repo_root)
    return repo_root


def add_upstream_remote(remote_name: str, upstream_url: str) -> None:
    """Ensure the upstream remote exists, adding it if necessary."""
    result = run_git(["remote", "get-url", remote_name], check=False)
    if result.returncode == 0:
        # Remote already exists; nothing to do.
        return
    run_git(["remote", "add", remote_name, upstream_url], check=False)


def fetch_upstream(remote_name: str) -> None:
    """Fetch the upstream remote."""
    run_git(["fetch", remote_name, "--prune"])


def clean_repo_url(url: str) -> str:
    """Remove credentials and trailing .git from a repository URL."""
    url = url.strip()
    if url.endswith(".git"):
        url = url[:-4]
    parsed = urlparse(url)
    scheme = parsed.scheme or "https"
    netloc = parsed.hostname or parsed.netloc.split("@")[-1]
    path = parsed.path
    clean = urlunparse((scheme, netloc, path, "", "", ""))
    return clean.rstrip("/")


def get_origin_url() -> str:
    """Return a sanitized origin URL for links."""
    result = run_git(["remote", "get-url", "origin"], check=False)
    if result.returncode != 0:
        return ""
    return clean_repo_url(result.stdout.strip())


def parse_git_log(remote_branch: str, local_branch: str) -> List[dict[str, str]]:
    """Return a list of commit dictionaries from the git log range."""
    format_str = "%H%x1f%h%x1f%ad%x1f%an%x1f%s%x1f%b%x1e"
    completed = run_git(
        [
            "log",
            f"{remote_branch}..{local_branch}",
            "--reverse",
            "--date=short",
            f"--pretty=format:{format_str}",
        ]
    )
    raw_entries = completed.stdout.strip("\n\x1e")
    commits: List[dict[str, str]] = []
    if not raw_entries:
        return commits
    for entry in raw_entries.split("\x1e"):
        if not entry.strip():
            continue
        parts = entry.split("\x1f")
        if len(parts) != 6:
            # Skip malformed entries to avoid crashing the report generation.
            continue
        commit = {
            "full_hash": parts[0],
            "short_hash": parts[1],
            "date": parts[2],
            "author": parts[3],
            "subject": parts[4],
            "body": parts[5],
        }
        commits.append(commit)
    return commits


def category_for_subject(subject: str) -> str:
    """Derive a human-friendly category from the commit subject."""
    merge_prefixes = (
        "Merge pull request",
        "Merge branch",
        "Merge remote",
    )
    if subject.startswith(merge_prefixes):
        return "Merge"

    match = re.match(r"^(?P<type>[A-Za-z]+)(?:\([^)]*\))?:", subject)
    if match:
        type_key = match.group("type").lower()
        label = CATEGORY_LABELS.get(type_key)
        if label:
            return label
        type_map = {
            "style": "Style",
            "revert": "Revert",
            "perf": "Performance",
        }
        return type_map.get(type_key, type_key.capitalize())
    return "Other"


def normalize_sentence(text: str) -> str:
    text = text.strip()
    if text and text[0].islower():
        text = text[0].upper() + text[1:]
    return text


def first_paragraph(text: str) -> str:
    """Extract the first non-empty paragraph from text."""
    if not text:
        return ""
    normalized = text.strip()
    if not normalized:
        return ""
    paragraphs = [p.strip() for p in normalized.split("\n\n")]
    for paragraph in paragraphs:
        if paragraph:
            single_line = re.sub(r"\s+", " ", paragraph)
            single_line = re.sub(r"\s*-\s+", " ", single_line)
            single_line = re.sub(r"^[A-Za-z]+\s*:\s+", "", single_line)
            single_line = re.sub(r":\s+", ". ", single_line)
            sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", single_line) if s.strip()]
            if sentences:
                first_sentence = normalize_sentence(sentences[0])
                if len(first_sentence.split()) < 5 and len(sentences) > 1:
                    second_sentence = normalize_sentence(sentences[1])
                    return f"{first_sentence} {second_sentence}".strip()
                if len(sentences) > 1 and len(sentences[1].split()) <= 18:
                    second_sentence = normalize_sentence(sentences[1])
                    return f"{first_sentence} {second_sentence}".strip()
                return first_sentence
            return single_line.strip()
    return ""


def extract_pr_links(text: str, repo_url: str) -> List[str]:
    """Return markdown links for PR numbers referenced in text."""
    if not repo_url:
        base_url = ""
    else:
        base_url = repo_url
    pr_numbers = sorted({match for match in re.findall(r"#(\d+)", text)})
    links: List[str] = []
    for pr_num in pr_numbers:
        if not base_url:
            links.append(f"#{pr_num}")
        else:
            links.append(f"[#{pr_num}]({base_url}/pull/{pr_num})")
    return links


def build_report_lines(
    commits: Sequence[dict[str, str]],
    repo_url: str,
    remote_branch: str,
    local_branch: str,
    report_date: dt.date,
) -> List[str]:
    """Construct the markdown report lines."""
    header = [
        f"# Commit Report — {report_date.isoformat()}",
        "",
        (
            f"Commits ahead of upstream ({remote_branch} → {local_branch}): "
            f"**{len(commits)}**"
        ),
        "",
    ]

    lines: List[str] = header
    if not commits:
        lines.append("No commits ahead of upstream. Great job keeping branches aligned!")
        return lines

    for index, commit in enumerate(commits, start=1):
        short_hash = commit["short_hash"]
        date = commit["date"]
        author = commit["author"]
        subject = commit["subject"].strip()
        body = commit["body"]
        category = category_for_subject(subject)
        paragraph = first_paragraph(body)
        paragraph_text = paragraph if paragraph else subject
        paragraph_text = paragraph_text.rstrip('.') + '.' if paragraph_text else ''
        commit_url = (
            f"{repo_url}/commit/{commit['full_hash']}" if repo_url else ""
        )
        header_line = (
            f"{index}. `{short_hash}` ({date}) — {category} — **{subject}** "
            f"_(by {author})_"
        )
        if commit_url:
            header_line = (
                f"{index}. [`{short_hash}`]({commit_url}) ({date}) — {category} — "
                f"**{subject}** _(by {author})_"
            )

        links = extract_pr_links(subject + "\n" + body, repo_url)
        details = paragraph_text
        if links:
            details = f"{details} {' '.join(links)}".strip()
        details_line = f"   - {details}" if details else ""

        lines.append(header_line)
        if details_line:
            lines.append(details_line)
        lines.append("")

    return lines


def write_report(path: str, lines: Iterable[str]) -> None:
    content = "\n".join(lines).rstrip() + "\n"
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(content)


def write_step_summary(lines: Sequence[str]) -> None:
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if not summary_path:
        return
    content = "\n".join(lines).rstrip() + "\n"
    with open(summary_path, "w", encoding="utf-8") as handle:
        handle.write(content)


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Generate commit report ahead of upstream")
    parser.add_argument(
        "--date",
        dest="report_date",
        help="Report date in YYYY-MM-DD (defaults to today)",
    )
    parser.add_argument(
        "--remote",
        default=DEFAULT_UPSTREAM_REMOTE,
        help="Upstream remote name (default: upstream)",
    )
    parser.add_argument(
        "--remote-url",
        default=DEFAULT_UPSTREAM_URL,
        help="Upstream remote URL to add if missing",
    )
    parser.add_argument(
        "--remote-branch",
        default=DEFAULT_UPSTREAM_BRANCH,
        help="Upstream branch name (default: main)",
    )
    parser.add_argument(
        "--local-branch",
        default=DEFAULT_LOCAL_BRANCH,
        help="Local branch to compare against upstream (default: main)",
    )
    parser.add_argument(
        "--report-dir",
        default=DEFAULT_REPORT_DIR,
        help="Directory where the markdown report will be stored",
    )
    args = parser.parse_args(argv)

    repo_root = ensure_repo_root()
    add_upstream_remote(args.remote, args.remote_url)
    fetch_upstream(args.remote)

    remote_branch = f"{args.remote}/{args.remote_branch}"
    local_branch = args.local_branch

    commits = parse_git_log(remote_branch, local_branch)
    repo_url = get_origin_url()

    if args.report_date:
        report_date = dt.datetime.strptime(args.report_date, "%Y-%m-%d").date()
    else:
        report_date = dt.date.today()

    report_lines = build_report_lines(
        commits,
        repo_url,
        remote_branch,
        local_branch,
        report_date,
    )

    report_filename = f"commit-report-{report_date.isoformat()}.md"
    report_path = os.path.join(repo_root, args.report_dir, report_filename)

    write_report(report_path, report_lines)
    write_step_summary(report_lines)

    sys.stdout.write("\n".join(report_lines) + "\n")
    sys.stdout.write(f"\nReport saved to {report_path}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
