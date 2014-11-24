######################################
#  Common Static library Makefile
######################################

TARGET  := libCocoaHTTPServer.a
SRC_DIR := Core Core/Categories Core/Mime Core/Responses Extensions/WebDAV \
	Vendor/CocoaAsyncSocket Vendor/CocoaLumberjack Vendor/CocoaLumberjack/Extensions
HEADER_DIR := include/

# > make clean && make && make headers
# Add following lines to your theos Makefile
# (name)_CFLAGS += -I./CocoaHTTPServer/include
# (name)_LDFLAGS += -L./ -lCocoaHTTPServer -lxml2 -lz
# (name)_FRAMEWORKS = UIKit CFNetwork Security CoreGraphics

ARCHS   := armv7 armv7s arm64
CFLAGS  := -O2 -fobjc-arc -I/usr/include/libxml2 -Wno-format -Wno-mismatched-parameter-types -Wno-unused-function -Wno-deprecated-declarations -Wno-enum-conversion

CLANG   := clang
AR      := ar

ARCH_FLAG := $(addprefix -arch ,$(ARCHS))
SDK     := $(shell ls -1d /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iP* | tail -n1)
INCLUDE_PATH := -I./ $(addprefix -I./,$(SRC_DIR))

SOURCE  := $(wildcard *.m) $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.m))
OBJS    := $(patsubst %.m, %.o, $(SOURCE))
HEADER  := $(wildcard *.h) $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.h))

.m.o:
	@echo "  CLANG $^"
	@$(CLANG) -c $^ $(ARCH_FLAG) -isysroot $(SDK) $(INCLUDE_PATH) $(CFLAGS)

all: $(TARGET)

$(TARGET): $(OBJS)
	@echo "  AR $(TARGET)"
	@rm -f $(TARGET)
	@$(AR) -rs $(TARGET) $(notdir $(OBJS)) >/dev/null 2>&1
	@rm -f *.o

clean:
	rm -f $(TARGET) *.o $(foreach sdir,$(SRC_DIR),$(sdir)/*.o)

headers:
	@echo "[+] copy headers to $(HEADER_DIR)"
	@rm -Rf $(HEADER_DIR)
	@mkdir -pm 775 $(HEADER_DIR)
	@cp -vf $(HEADER) $(HEADER_DIR)
