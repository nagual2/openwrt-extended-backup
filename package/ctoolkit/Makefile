include $(TOPDIR)/rules.mk

PKG_NAME:=ctoolkit
PKG_VERSION:=$(strip $(shell cat $(CURDIR)/../../VERSION))
PKG_RELEASE:=1

PKG_MAINTAINER:=openwrt-extended-backup maintainers
PKG_LICENSE:=Proprietary
PKG_LICENSE_FILES:=LICENSE
PKGARCH:=all
PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_ctoolkit_WITH_KSMBD

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/ctoolkit
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Backup and restore toolkit for OpenWrt
  URL:=https://github.com/nagual2/openwrt-extended-backup
  DEPENDS:=+tar +coreutils-sha256sum$(if $(CONFIG_PACKAGE_ctoolkit_WITH_KSMBD), +ksmbd-tools)
endef

define Package/ctoolkit/description
  Toolkit that automates full overlay backups, safe restore workflows, and user package list generation on OpenWrt systems.
endef

define Package/ctoolkit/config
  menu "Configuration"
    depends on PACKAGE_ctoolkit
  config PACKAGE_ctoolkit_WITH_KSMBD
    bool "Depend on ksmbd-tools"
    default y
    help
      Install ksmbd-tools to enable optional SMB sharing helpers in the backup script.
  endmenu
endef

define Build/Prepare
    rm -rf $(PKG_BUILD_DIR)
    mkdir -p $(PKG_BUILD_DIR)/scripts
    $(CP) $(CURDIR)/../../scripts/openwrt_full_backup $(PKG_BUILD_DIR)/scripts/
    $(CP) $(CURDIR)/../../scripts/openwrt_full_restore $(PKG_BUILD_DIR)/scripts/
    $(CP) $(CURDIR)/../../scripts/user_installed_packages $(PKG_BUILD_DIR)/scripts/
    $(CP) $(CURDIR)/../../README.md $(PKG_BUILD_DIR)/
    $(CP) $(CURDIR)/../../LICENSE $(PKG_BUILD_DIR)/
    $(CP) $(CURDIR)/../../VERSION $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/ctoolkit/install
    $(INSTALL_DIR) $(1)/usr/bin
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/openwrt_full_backup $(1)/usr/bin/openwrt_full_backup
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/openwrt_full_restore $(1)/usr/bin/openwrt_full_restore
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/user_installed_packages $(1)/usr/bin/user_installed_packages
    $(INSTALL_DIR) $(1)/usr/share/openwrt-extended-backup
    $(INSTALL_DATA) $(PKG_BUILD_DIR)/VERSION $(1)/usr/share/openwrt-extended-backup/VERSION
    $(INSTALL_DIR) $(1)/usr/share/doc/ctoolkit
    $(INSTALL_DATA) $(PKG_BUILD_DIR)/README.md $(1)/usr/share/doc/ctoolkit/README.md
    $(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/doc/ctoolkit/LICENSE
endef

$(eval $(call BuildPackage,ctoolkit))
