ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = PowerBanners
PowerBanners_FILES = PowerBanners.mm
PowerBanners_INSTALL_PATH = /Library/PreferenceBundles
PowerBanners_FRAMEWORKS = UIKit
PowerBanners_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PowerBanners.plist$(ECHO_END)

include $(THEOS_MAKE_PATH)/aggregate.mk
