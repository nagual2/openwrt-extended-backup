SHELL := /bin/sh
.RECIPEPREFIX := >

USE_SYSTEM_TOOLS ?= 0
TOOLS_DIR := $(CURDIR)/tools

ifeq ($(USE_SYSTEM_TOOLS),1)
SHFMT ?= shfmt
SHELLCHECK ?= shellcheck
BATS ?= bats
else
SHFMT ?= $(TOOLS_DIR)/shfmt
SHELLCHECK ?= $(TOOLS_DIR)/shellcheck
BATS ?= $(TOOLS_DIR)/bats-core/bin/bats
endif

SHFMT_FLAGS ?= -i 2 -bn -ci -sr
SHELLCHECK_FLAGS ?= -s sh
BATS_FLAGS ?= -r
BATS_SHELL ?= /bin/sh

PKG_NAME := ctoolkit
PROJECT_VERSION ?=
GIT_TAG := $(strip $(shell git describe --tags --match 'v*' --abbrev=0 2>/dev/null || true))
PKG_VERSION := $(strip $(if $(PROJECT_VERSION),$(PROJECT_VERSION),$(if $(GIT_TAG),$(patsubst v%,%,$(GIT_TAG)),0.0.0)))
PKG_RELEASE ?= 1
WITH_KSMBD ?= 1

OUTPUT_DIR ?= dist
WORK_DIR := build/ipk
DATA_DIR := $(WORK_DIR)/data
CONTROL_DIR := $(WORK_DIR)/control
SHARE_DIR := openwrt-extended-backup

IPK_FILENAME := $(PKG_NAME)_$(PKG_VERSION)-$(PKG_RELEASE)_all.ipk
IPK_PATH := $(OUTPUT_DIR)/$(IPK_FILENAME)

CONTROL_DEPENDS := tar, coreutils-sha256sum
ifeq ($(WITH_KSMBD),1)
CONTROL_DEPENDS := $(CONTROL_DEPENDS), ksmbd-tools
endif

.PHONY: fmt lint test all ipk clean install

all: lint test

fmt:
> @set -e; \
> tmp=$$(mktemp); \
> git ls-files -z | while IFS= read -r -d '' file; do \
>     if [ -f "$$file" ] && head -n 1 "$$file" | grep -Eq '^\#!.*\b(sh|bash)\b'; then \
>         printf '%s\0' "$$file" >> "$$tmp"; \
>     fi; \
> done; \
> if [ -s "$$tmp" ]; then \
>     echo "Formatting shell scripts with $(SHFMT)..."; \
>     xargs -0 $(SHFMT) $(SHFMT_FLAGS) -w -- < "$$tmp"; \
> else \
>     echo "No shell scripts found to format."; \
> fi; \
> rm -f "$$tmp"

lint:
> @set -e; \
> tmp=$$(mktemp); \
> git ls-files -z | while IFS= read -r -d '' file; do \
>     if [ -f "$$file" ] && head -n 1 "$$file" | grep -Eq '^\#!.*\b(sh|bash)\b'; then \
>         printf '%s\0' "$$file" >> "$$tmp"; \
>     fi; \
> done; \
> if [ -s "$$tmp" ]; then \
>     echo "Running ShellCheck..."; \
>     if [ -f .shellcheckrc ]; then \
>         xargs -0 $(SHELLCHECK) --config-file ./.shellcheckrc -- < "$$tmp"; \
>     else \
>         xargs -0 $(SHELLCHECK) $(SHELLCHECK_FLAGS) -- < "$$tmp"; \
>     fi; \
> else \
>     echo "No shell scripts found to lint."; \
> fi; \
> rm -f "$$tmp"

test:
> @set -e; \
> if [ -d tests ]; then \
>     BATS_SHELL=$(BATS_SHELL) $(BATS) $(BATS_FLAGS) tests; \
> else \
>     echo "tests/ directory not found. Skipping."; \
> fi

ipk: $(IPK_PATH)

$(IPK_PATH): scripts/openwrt_full_backup scripts/openwrt_restore scripts/openwrt_full_restore scripts/user_installed_packages
> rm -rf $(WORK_DIR)
> mkdir -p $(DATA_DIR)/usr/bin
> mkdir -p $(DATA_DIR)/usr/share/$(SHARE_DIR)
> mkdir -p $(DATA_DIR)/usr/share/doc/$(PKG_NAME)
> install -m 0755 scripts/openwrt_full_backup $(DATA_DIR)/usr/bin/openwrt_full_backup
> install -m 0755 scripts/openwrt_restore $(DATA_DIR)/usr/bin/openwrt_restore
> install -m 0755 scripts/openwrt_full_restore $(DATA_DIR)/usr/bin/openwrt_full_restore
> install -m 0755 scripts/user_installed_packages $(DATA_DIR)/usr/bin/user_installed_packages
> printf '%s\n' "$(PKG_VERSION)" > $(DATA_DIR)/usr/share/$(SHARE_DIR)/VERSION
> install -m 0644 README.md $(DATA_DIR)/usr/share/doc/$(PKG_NAME)/README.md
> install -m 0644 LICENSE $(DATA_DIR)/usr/share/doc/$(PKG_NAME)/LICENSE
> mkdir -p $(CONTROL_DIR)
> printf 'Package: %s\n' $(PKG_NAME) > $(CONTROL_DIR)/control
> printf 'Version: %s-%s\n' $(PKG_VERSION) $(PKG_RELEASE) >> $(CONTROL_DIR)/control
> printf 'Architecture: all\n' >> $(CONTROL_DIR)/control
> printf 'Section: utils\n' >> $(CONTROL_DIR)/control
> printf 'Priority: optional\n' >> $(CONTROL_DIR)/control
> printf 'Maintainer: openwrt-extended-backup maintainers\n' >> $(CONTROL_DIR)/control
> printf 'Depends: %s\n' "$(CONTROL_DEPENDS)" >> $(CONTROL_DIR)/control
> printf 'Description: Backup, restore, and package listing toolkit for OpenWrt.\n' >> $(CONTROL_DIR)/control
> tar -C $(DATA_DIR) -czf $(WORK_DIR)/data.tar.gz .
> tar -C $(CONTROL_DIR) -czf $(WORK_DIR)/control.tar.gz .
> printf '2.0\n' > $(WORK_DIR)/debian-binary
> mkdir -p $(OUTPUT_DIR)
> rm -f $(IPK_PATH)
> (cd $(WORK_DIR) && ar rcs $(abspath $(IPK_PATH)) debian-binary control.tar.gz data.tar.gz)

clean:
> rm -rf $(WORK_DIR) $(OUTPUT_DIR)

install: $(IPK_PATH)
> @if command -v opkg >/dev/null 2>&1; then \
>     opkg install $(IPK_PATH); \
> else \
>     echo "Package built at $(IPK_PATH). Copy it to the router and run:"; \
>     echo "  opkg install $(IPK_FILENAME)"; \
> fi
