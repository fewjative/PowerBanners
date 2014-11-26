ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = PowerBanners
PowerBanners_FILES = Tweak.xm
PowerBanners_FRAMEWORKS = UIKit Foundation QuartzCore AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += pb
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
