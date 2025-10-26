include $(TOPDIR)/rules.mk

PKG_NAME:=openwrt-extended-backup
PKG_VERSION:=$(strip $(shell cat $(CURDIR)/../VERSION))
PKG_RELEASE:=1

PKG_MAINTAINER:=openwrt-extended-backup maintainers
PKG_LICENSE:=Proprietary
PKGARCH:=all
PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_openwrt-extended-backup_WITH_KSMBD

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/openwrt-extended-backup
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Extended backup scripts for OpenWrt routers
  URL:=https://github.com/nagual2/openwrt-extended-backup
  DEPENDS:=+tar$(if $(CONFIG_PACKAGE_openwrt-extended-backup_WITH_KSMBD), +ksmbd-tools)
endef

define Package/openwrt-extended-backup/description
  Toolkit that automates full backup creation of the overlay partition, provides a safe restore helper, and lists user installed packages on OpenWrt.
endef

define Package/openwrt-extended-backup/config
  menu "Configuration"
    depends on PACKAGE_openwrt-extended-backup
  config PACKAGE_openwrt-extended-backup_WITH_KSMBD
    bool "Depend on ksmbd-tools"
    default y
    help
      Install ksmbd-tools alongside the backup scripts to enable SMB sharing helper commands.
  endmenu
endef

define Build/Prepare
    rm -rf $(PKG_BUILD_DIR)
    mkdir -p $(PKG_BUILD_DIR)
    $(CP) $(CURDIR)/../scripts $(PKG_BUILD_DIR)/
    $(CP) $(CURDIR)/../VERSION $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/openwrt-extended-backup/install
    $(INSTALL_DIR) $(1)/usr/sbin
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/openwrt_full_backup $(1)/usr/sbin/openwrt_full_backup
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/openwrt_full_restore $(1)/usr/sbin/openwrt_full_restore
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/openwrt_restore $(1)/usr/sbin/openwrt_restore
    $(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/user_installed_packages $(1)/usr/sbin/user_installed_packages
    $(INSTALL_DIR) $(1)/usr/share/openwrt-extended-backup
    $(INSTALL_DATA) $(PKG_BUILD_DIR)/VERSION $(1)/usr/share/openwrt-extended-backup/VERSION
endef

$(eval $(call BuildPackage,openwrt-extended-backup))
