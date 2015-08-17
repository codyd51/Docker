ARCHS = armv7 arm64
TARGET = iphone:clang:latest:latest
THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TWEAK_NAME = Docker
Docker_FILES = Tweak.xm
Docker_FRAMEWORKS = UIKit
Docker_FRAMEWORKS += CoreGraphics
Docker_FRAMEWORKS += QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
