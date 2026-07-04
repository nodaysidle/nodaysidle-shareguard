# ARD — ShareGuard First Slice

## Architecture
- Single executable target.
- MainActor SwiftUI view model drives scanning via an actor-isolated `DetectionEngine`.
- `FileEnumerator` expands dropped URLs into scannable file URLs, skipping ignored dirs.
- `Detector` protocol allows independent, composable detectors.
- `Redaction` centralizes secret masking.

## Concurrency
- `DetectionEngine` is an actor.
- `ScanViewModel` is `@MainActor @Observable`.
- Swift 6 strict concurrency is enabled.

## Security / privacy
- No network.
- Secrets always redacted in UI.
- PDF/image scanning is metadata-only; no OCR/extraction.

## Packaging
- `Scripts/package_app.sh` builds release, creates `.app`, writes `Info.plist`/`PkgInfo`, copies resources, ad-hoc signs, and verifies.
