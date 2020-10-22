ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = Instagram

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = IGCopyComments

IGCopyComments_FILES = Tweak.xm
$(TWEAK_NAME)_FRAMEWORKS = AudioToolbox
IGCopyComments_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
