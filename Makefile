SHELL := /bin/sh
.RECIPEPREFIX := >

PKG_NAME := openwrt-extended-backup
PKG_VERSION := $(strip $(shell cat VERSION))
PKG_RELEASE ?= 1
WITH_KSMBD ?= 1

OUTPUT_DIR ?= dist
WORK_DIR := build/ipk
DATA_DIR := $(WORK_DIR)/data
CONTROL_DIR := $(WORK_DIR)/control

IPK_FILENAME := $(PKG_NAME)_$(PKG_VERSION)-$(PKG_RELEASE)_all.ipk
IPK_PATH := $(OUTPUT_DIR)/$(IPK_FILENAME)

ifeq ($(WITH_KSMBD),1)
CONTROL_DEPENDS := tar, ksmbd-tools
else
CONTROL_DEPENDS := tar
endif

.PHONY: all ipk clean install

all: ipk

ipk: $(IPK_PATH)

$(IPK_PATH): scripts/openwrt_full_backup scripts/user_installed_packages VERSION
> rm -rf $(WORK_DIR)
> mkdir -p $(DATA_DIR)/usr/sbin
> mkdir -p $(DATA_DIR)/usr/share/$(PKG_NAME)
> install -m 0755 scripts/openwrt_full_backup $(DATA_DIR)/usr/sbin/openwrt_full_backup
> install -m 0755 scripts/user_installed_packages $(DATA_DIR)/usr/sbin/user_installed_packages
> install -m 0644 VERSION $(DATA_DIR)/usr/share/$(PKG_NAME)/VERSION
> mkdir -p $(CONTROL_DIR)
> printf 'Package: %s\n' $(PKG_NAME) > $(CONTROL_DIR)/control
> printf 'Version: %s-%s\n' $(PKG_VERSION) $(PKG_RELEASE) >> $(CONTROL_DIR)/control
> printf 'Architecture: all\n' >> $(CONTROL_DIR)/control
> printf 'Section: utils\n' >> $(CONTROL_DIR)/control
> printf 'Priority: optional\n' >> $(CONTROL_DIR)/control
> printf 'Maintainer: openwrt-extended-backup maintainers\n' >> $(CONTROL_DIR)/control
> printf 'Depends: %s\n' "$(CONTROL_DEPENDS)" >> $(CONTROL_DIR)/control
> printf 'Description: OpenWrt full backup helpers and user package listing scripts.\n' >> $(CONTROL_DIR)/control
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
