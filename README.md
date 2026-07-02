# NODAYSIDLE ShareGuard

Local-first macOS pre-share privacy/safety scanner. Drag files or folders onto the dark Volt UI and get a local leak-risk report before publishing, sending, or pushing to GitHub.

Target source repository: `https://github.com/nodaysidle/nodaysidle-shareguard`

## Build

Requires macOS 14+ and Swift 6.

```bash
cd /Volumes/omarchyuser/projekti/nodaysidle-shareguard
swift build
```

## Test

```bash
swift test
```

## Package into ShareGuard.app

```bash
./Scripts/package_app.sh
```

Produces `.build/release/ShareGuard.app`.

## Run the app

```bash
open .build/release/ShareGuard.app
```

Or run directly:

```bash
swift run ShareGuard
```

For installed-app usage, supported inputs, redaction caveats, and local verification commands, see [USERGUIDE.md](USERGUIDE.md).

Release notes are tracked in [CHANGELOG.md](CHANGELOG.md).

## First-slice detectors

- API / token-like strings (OpenAI, GitHub, Slack, AWS, generic)
- Private keys (`BEGIN ... PRIVATE KEY`)
- `.env` key/value secrets
- Emails
- Phone-ish strings
- URLs with query tokens
- Absolute local paths under `/Users/`
- Suspicious filenames (`id_rsa`, `.pem`, `.p12`, `.mobileprovision`, `.env`)

## Supported file types

Text: `.md`, `.txt`, `.json`, `.env`, `.env.*`, `.plist`, `.yaml`, `.yml`, `.csv`, `.log`
Binary (metadata/info only): `.pdf`, `.png`, `.jpg`, `.jpeg`

## Ignored directories

`.git`, `.build`, `node_modules`, `target`, `DerivedData`, `.swiftpm`, `.idea`, `.vscode`, `__pycache__`

## First-slice limits (honest)

- **No OCR.** Images are scanned for metadata only; visible text in screenshots is not read.
- **No PDF text extraction.** PDFs are flagged for manual review.
- **No cloud/network calls.** Entirely local.
- **Heuristic detectors.** May miss some secrets and produce false positives.
- **No remediation actions** such as auto-redact or delete.
- **No sandboxing / Developer ID signing / notarization** beyond ad-hoc signing.
- **No API keys, telemetry, or entitlements** are needed for the first-slice local privacy scan.

## Distribution / signing

The first slice is ad-hoc signed for local/internal use. It does not use cloud services, API keys, telemetry, sandbox entitlements, Developer ID signing, or notarization. Future public distribution should add Developer ID signing and notarization before release assets are published.

## License

Proprietary — NODAYSIDLE.
