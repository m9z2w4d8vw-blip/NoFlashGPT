TARGET := iphone:clang:latest:15.0

# arm64 only, on purpose. ChatGPT is an App Store app, and iOS 17.0 runs every
# App Store app as plain arm64 (third-party arm64e starts at iOS 17.4), so this
# is the only slice ChatGPT ever loads. It also keeps the Linux toolchain's
# arm64e output out of the package: that is the slice that crashed every
# injected process on this iOS 17.0 phone during NextUp3.
ARCHS = arm64

THEOS_PACKAGE_SCHEME ?= rootless
INSTALL_TARGET_PROCESSES = ChatGPT

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoFlashGPT

NoFlashGPT_FILES = Tweak.x
NoFlashGPT_CFLAGS = -fobjc-arc
NoFlashGPT_FRAMEWORKS = AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
