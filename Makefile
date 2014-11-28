ARCHS = armv7 arm64

include theos/makefiles/common.mk

THEOS_PACKAGE_DIR=./debs

TWEAK_NAME = IOTracker
IOTracker_FILES = Tweak.xm filelog.c FLogObjectiveC.m \
		NSURLConnectionDelegateProxy.m \
		$(wildcard WebSocketServer/*.m)
IOTracker_CFLAGS += -I./ -I./CocoaHTTPServer/include -DLOG_LEVEL=5 #-D_TRACE_STACKS
IOTracker_LDFLAGS += -L./CocoaHTTPServer -lCocoaHTTPServer -lxml2
IOTracker_FRAMEWORKS = Foundation UIKit CFNetwork Security CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

clean::
	rm -f $(THEOS_PACKAGE_DIR)/*.deb
