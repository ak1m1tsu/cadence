.DEFAULT_GOAL := help

.PHONY: help run deps gen icons analyze test \
        build-android build-windows build-macos clean release

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Dev:"
	@echo "  run            Run on connected device"
	@echo "  deps           Install pub dependencies"
	@echo "  gen            Run code generation (build_runner)"
	@echo "  icons          Generate launcher icons"
	@echo "  clean          Clean build artifacts"
	@echo ""
	@echo "Quality:"
	@echo "  analyze        Static analysis (fatal infos)"
	@echo "  test           Run tests"
	@echo ""
	@echo "Build:"
	@echo "  build-android  APK + AAB (release)"
	@echo "  build-windows  Windows executable (release)"
	@echo "  build-macos    macOS app bundle (release)"
	@echo ""
	@echo "Release:"
	@echo "  release v=1.2.3  Tag and push — triggers CI/CD"

run:
	flutter run

deps:
	flutter pub get

gen:
	dart run build_runner build --delete-conflicting-outputs

icons:
	dart run flutter_launcher_icons

analyze:
	flutter analyze --fatal-infos

test:
	flutter test

build-android:
	flutter build apk --release
	flutter build appbundle --release

build-windows:
	flutter build windows --release

build-macos:
	flutter build macos --release

clean:
	flutter clean

release:
ifndef v
	$(error Specify version: make release v=1.2.3)
endif
	git tag v$(v)
	git push origin v$(v)
