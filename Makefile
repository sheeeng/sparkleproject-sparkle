.PHONY: all localizable-strings release build test ci

all: build

ifndef BUILDDIR
    BUILDDIR := $(shell mktemp -d "$(TMPDIR)/Sparkle.XXXXXX")
endif

localizable-strings:
	rm -f Sparkle/en.lproj/Sparkle.strings
	genstrings -o Sparkle/en.lproj -s SULocalizedString Sparkle/*.m Sparkle/*.h
	iconv -f UTF-16 -t UTF-8 < Sparkle/en.lproj/Localizable.strings > Sparkle/en.lproj/Sparkle.strings
	rm Sparkle/en.lproj/Localizable.strings

release:
	xcodebuild -scheme Sparkle -configuration Release -derivedDataPath "$(BUILDDIR)" -archivePath "$(BUILDDIR)/Build/Products/Release/Sparkle.xcarchive" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
	xcodebuild -create-xcframework -framework "$(BUILDDIR)/Build/Products/Release/Sparkle.xcarchive/Products/Library/Frameworks/Sparkle.framework" -debug-symbols "$(BUILDDIR)/Build/Products/Release/Sparkle.xcarchive/dSYMs/Sparkle.framework.dSYM" -output "$(BUILDDIR)/Build/Products/Release/Sparkle.xcframework"
	xcodebuild -scheme SparkleCore -configuration Release -derivedDataPath "$(BUILDDIR)" -archivePath "$(BUILDDIR)/Build/Products/Release/SparkleCore.xcarchive" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO archive
	xcodebuild -create-xcframework -framework "$(BUILDDIR)/Build/Products/Release/SparkleCore.xcarchive/Products/Library/Frameworks/SparkleCore.framework" -debug-symbols "$(BUILDDIR)/Build/Products/Release/SparkleCore.xcarchive/dSYMs/SparkleCore.framework.dSYM" -output "$(BUILDDIR)/Build/Products/Release/SparkleCore.xcframework"
	xcodebuild -scheme Distribution -configuration Release -derivedDataPath "$(BUILDDIR)" build
	open "$(BUILDDIR)/Build/Products/Release/"
	cat Sparkle.podspec
	@echo "Don't forget to update CocoaPods! pod trunk push"
	@echo "Don't forget to commit the updated Package manifest before releasing!"

build:
	xcodebuild clean build

test:
	xcodebuild -scheme Distribution -configuration Debug test
	./objc_dep/objc_dep.py -t .

uitest:
	xcodebuild -scheme UITests -configuration Debug test

ci:
	for i in {7..9} ; do \
		if xcrun --sdk "macosx10.$$i" --show-sdk-path 2> /dev/null ; then \
			( rm -rf build && xcodebuild -sdk "macosx10.$$i" -scheme Distribution -configuration Coverage -derivedDataPath build ) || exit 1 ; \
		fi ; \
	done
	for i in {10..12} ; do \
		if xcrun --sdk "macosx10.$$i" --show-sdk-path 2> /dev/null ; then \
			( rm -rf build && xcodebuild -sdk "macosx10.$$i" -scheme Distribution -configuration Coverage -derivedDataPath build test ) || exit 1 ; \
		fi ; \
	done

check-localizations:
	./Sparkle/CheckLocalizations.swift -root . -htmlPath "$(TMPDIR)/LocalizationsReport.htm"
	open "$(TMPDIR)/LocalizationsReport.htm"
