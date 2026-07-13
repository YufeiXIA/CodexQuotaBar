APP_NAME := CodexQuotaBar
BUILD_DIR := build
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
EXECUTABLE := $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)

.PHONY: build install uninstall clean

build:
	mkdir -p $(APP_BUNDLE)/Contents/MacOS $(BUILD_DIR)/module-cache
	clang -fobjc-arc -fmodules -fmodules-cache-path=$(BUILD_DIR)/module-cache -framework Cocoa -o $(EXECUTABLE) Sources/main.m
	cp Resources/Info.plist $(APP_BUNDLE)/Contents/Info.plist
	xattr -cr $(APP_BUNDLE)
	xattr -d com.apple.FinderInfo $(APP_BUNDLE) 2>/dev/null || true
	xattr -d 'com.apple.fileprovider.fpfs#P' $(APP_BUNDLE) 2>/dev/null || true
	codesign --force --sign - $(APP_BUNDLE)

install: build
	./scripts/install.sh $(APP_BUNDLE)

uninstall:
	./scripts/uninstall.sh

clean:
	rm -rf $(BUILD_DIR)
