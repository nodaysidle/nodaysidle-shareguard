# Agent Execution Contract — ShareGuard

## Read Order
- README.md
- USERGUIDE.md
- CHANGELOG.md
- docs/internal/ (planning/spec/agent notes)
- AGENTS.md

## Hard Stack Contract
- Preset id: native-macos-swiftpm-local
- Preset label: Native macOS Utility App (Local-Only)
- Swift 6
- SwiftUI
- Swift Package Manager (Package.swift)
- macOS 14+
- Zero network calls
- Zero external Swift package dependencies

## Must Use
- Swift 6
- SwiftUI
- SwiftPM (swift build / swift test)
- Local file scanning only — no uploads, no cloud, no backend
- Drag-and-drop macOS file handling
- Heuristic-based text pattern detection (regex/scanning)
- Redacted/safe-to-screenshot output display

## Must Not Use
- Network calls of any kind (not even optional)
- External Swift packages (zero dependencies beyond stdlib)
- Cloud APIs, telemetry, analytics, error reporting backends
- OCR or PDF text extraction libraries
- Electron, React, Tauri, WebView shell

## Architecture Rules
- Agent must enforce zero-network, zero-external-dependency build.
- Agent must keep all scanning local — files never leave the user's machine.
- Agent must display redacted excerpts in findings — never full secrets.
- Agent must treat detector coverage as explicit, not exhaustive — findings are heuristics, not guarantees.
- Agent must preserve the drag-and-drop UX as the primary interaction model.

## File Rules
- Source in `Sources/ShareGuard/`.
- Tests in `Tests/ShareGuardTests/`.
- Scripts in `Scripts/` (package_app.sh).
- End-user docs in `USERGUIDE.md`.
- Release notes in `CHANGELOG.md`.
- Internal planning/spec in `docs/internal/`.

## Validation Rules
- Run `swift test` before marking any task complete.
- Run `swift build` to verify compilation.
- Run `./Scripts/package_app.sh` to verify the app bundles.
- Run `codesign --verify --deep --strict --verbose=2 .build/release/ShareGuard.app` to verify signing.
- Verify zero network imports: `grep -r "URLSession\|import Network\|import FoundationNetworking" Sources/` must return empty.

## Stop Conditions
- Stop if a task adds any network dependency, external package, or cloud API.
- Stop if a task proposes OCR or PDF text extraction.
- Stop if a task exposes unredacted secret content in UI output.
- Stop if validation fails and the failure is not documented with a concrete fix.
