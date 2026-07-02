# PRD — ShareGuard First Slice

## Objective
Deliver an installable, useful native macOS app that scans files/folders for likely leaks before sharing.

## User stories
- As a user, I can drag files/folders onto ShareGuard and tap Scan.
- I see a summary of files scanned and findings by severity.
- I can review each finding with file path, line number, detector, redacted excerpt, and remediation.

## Features (slice 1)
1. SwiftPM executable app, macOS 14+, Swift 6.
2. Native SwiftUI window with dark Volt UI.
3. Drag/drop file and folder support.
4. Recursive scanning with ignored build/cache/vendor dirs.
5. Detectors for tokens, keys, env secrets, emails, phones, URL tokens, local paths, suspicious filenames.
6. Redaction of all secrets in UI.
7. Metadata-only scanning for images and PDFs.

## Out of scope (slice 1)
- OCR on images.
- PDF text extraction.
- Auto-fix / auto-redact.
- Sandboxing / App Store distribution.
- Cloud or network features.

## Success criteria
- `swift test` passes.
- `Scripts/package_app.sh` produces a codesigned `.app` bundle.
- App launches, accepts drops, and reports findings on sample files.
