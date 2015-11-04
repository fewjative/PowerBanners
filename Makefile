ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = PowerBanners
PowerBanners_FILES = Tweak.xm
PowerBanners_FRAMEWORKS = UIKit Foundation QuartzCore AudioToolbox
PowerBanners_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += pb
include $(THEOS_MAKE_PATH)/aggregate.mk

before-stage::
	find . -name ".DS_STORE" -delete
after-install::
	install.exec "killall -9 SpringBoard"
