# TRD — ShareGuard First Slice

## Tech stack
- Language: Swift 6
- Platform: macOS 14+
- UI: SwiftUI (AppKit available if needed)
- Build: SwiftPM
- Dependencies: none

## Build settings
- `swiftLanguageMode(.v6)`
- `StrictConcurrency` enabled

## Tests
- `RedactionTests` — token/env redaction, excerpt, line numbers.
- `DetectorTests` — each detector and severity mapping.
- `FileEnumeratorTests` — ignore rules and recursion.

## CI / local verification
```bash
swift build
swift test
./Scripts/package_app.sh
```
