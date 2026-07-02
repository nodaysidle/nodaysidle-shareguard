# AGENTS.md — NODAYSIDLE ShareGuard

## What this project is
A native macOS SwiftPM executable app: a local-first pre-share privacy/safety scanner.

## Build, test, package
- `swift build`
- `swift test`
- `./Scripts/package_app.sh`

## Conventions
- Swift 6, strict concurrency.
- No external dependencies.
- UI in SwiftUI; AppKit may be used where SwiftUI is insufficient.
- Dark NODAYSIDLE UI, Volt accent `#C8FF00`.
- All findings must redact secrets; never print full tokens/keys.

## Directory layout
- `Sources/ShareGuard/` — app code.
  - `Views/` — SwiftUI.
  - `Detector/` — secret detectors.
  - `Scanner/` — file enumeration.
  - `Utilities/` — constants, redaction, extensions.
  - `Models/` — data models.
- `Tests/ShareGuardTests/` — XCTest cases.
- `Scripts/` — packaging script.
- `Resources/` — optional app resources.

## Forbidden
- Network calls.
- External Swift packages.
- Persisting user data outside app sandbox (first slice).
- OCR / PDF text extraction (not implemented in first slice).
