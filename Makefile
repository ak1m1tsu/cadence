SHELL := bash
.DEFAULT_GOAL := help

.PHONY: help run deps gen icons analyze test build clean release

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
	@echo "  build          APK + AAB (release)"
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

build:
	flutter build apk --release --no-tree-shake-icons
	flutter build appbundle --release --no-tree-shake-icons

clean:
	flutter clean

release:
ifndef v
	$(error Specify version: make release v=1.2.3)
endif
	@BUILD=$$(grep '^version:' pubspec.yaml | sed 's/.*+//'); \
	NEW_BUILD=$$((BUILD + 1)); \
	sed -i "s/^version:.*/version: $(v)+$$NEW_BUILD/" pubspec.yaml; \
	git add pubspec.yaml; \
	git commit -m "chore: bump version to $(v)+$$NEW_BUILD"; \
	git tag v$(v); \
	git push origin master v$(v)
