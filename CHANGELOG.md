# Changelog

All notable changes to ShareGuard are documented here.

## [0.1.0] — 2026-07-02

### Added
- First installable macOS slice of ShareGuard.
- Local-only drag-and-drop scanner for files and folders.
- Detectors for token-like strings, private key markers, `.env` secrets, email addresses, phone-like strings, URL query tokens, absolute `/Users/` paths, and suspicious secret-bearing filenames.
- Manual-review flags for PDF and image files.
- Redacted findings UI with severity summary, findings list, and read-error section.
- SwiftPM XCTest coverage for detectors, file enumeration, redaction, and end-to-end detection engine smoke.
- App icon resources and SwiftPM `.app` packaging script.
- Ad-hoc codesigned local macOS app bundle.

### Known limits
- No OCR for screenshots/images.
- No PDF text extraction.
- No auto-redaction or clean-copy export.
- No cloud sync, accounts, telemetry, or network calls.
- Ad-hoc signed only; Developer ID signing and notarization are deferred.
