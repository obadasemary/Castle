# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build
xcodebuild -project Castle.xcodeproj -scheme Castle -configuration Debug build

# Run all tests
xcodebuild -project Castle.xcodeproj -scheme Castle -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run unit tests only
xcodebuild -project Castle.xcodeproj -scheme CastleTests -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test (Swift Testing)
xcodebuild -project Castle.xcodeproj -scheme Castle -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CastleTests/CastleTests/example
```

## Architecture

This is a greenfield SwiftUI iOS app (iOS 26.4+, Swift 6.2) with a single Xcode project and no external dependencies. The intended architecture is **Modular Clean Architecture via Swift Package Manager**, following the `ios-clean-architecture` skill pattern:

- **Layers:** NetworkService → Endpoints → Repositories → UseCases → DIContainer → Feature Views
- **Pattern:** Protocol-first cross-module dependencies; Builder-based feature instantiation
- **State management:** `@Observable` (not `ObservableObject`) with Swift 6 main-actor isolation
- **DI:** Constructor injection via a `DIContainer`; no global singletons

As the app grows, features should be extracted into separate SPM packages under a `Packages/` directory rather than adding more files to the main `Castle/` target.

## Testing

Unit tests use the **Swift Testing** framework (`import Testing`, `@Test` macro, `#expect`). Do not use XCTest for new unit tests. UI tests remain XCTest (`XCUIApplication`).

## Skills

Two skills are installed and available via `openskills read <skill-name>`:

- **`ios-clean-architecture`** — scaffold new features, SPM package layering, `@Observable` migration, Builder wiring
- **`find-skills`** — discover and install additional skills

Use these before implementing non-trivial features from scratch.
