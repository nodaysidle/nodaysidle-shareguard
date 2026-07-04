# NODAYSIDLE ShareGuard

**Local-first macOS pre-share privacy scanner.**

ShareGuard gives you a last-chance leak check before you publish, send, zip, or push files. Drop in files or folders, scan locally, and review a redacted risk report for secrets, private contact details, local paths, and suspicious share targets.

**macOS 14+** · Swift 6 · SwiftUI · no network calls

---

## What You Get

| Area | Capability |
|------|------------|
| **Drag-and-drop scan** | Drop files or folders into the app and scan recursively |
| **Secret hints** | Flags token-like strings, private-key headers, and `.env` values |
| **Personal data hints** | Flags emails, phone-like strings, local `/Users/` paths, and risky URLs |
| **Suspicious files** | Calls out filenames such as `id_rsa`, `.pem`, `.p12`, `.mobileprovision`, and `.env` |
| **Manual-review media** | Surfaces PDFs and images as review items instead of pretending OCR exists |
| **Redacted findings** | Shows short masked excerpts so reports are safer to screenshot |
| **Local boundary** | No accounts, telemetry, backend, uploads, or cloud sync |

---

## Privacy Boundary

ShareGuard is intentionally local-first.

- No network calls.
- No external Swift packages.
- No API keys or accounts.
- No telemetry.
- No OCR or PDF text extraction in the first slice.
- Findings are heuristic and must be reviewed before sharing.

It is a pre-share checklist, not a formal DLP guarantee.

---

## Quick Start

1. Build and package:

   ```bash
   swift test
   ./Scripts/package_app.sh
   ```

2. Launch the packaged app:

   ```bash
   open .build/release/ShareGuard.app
   ```

3. Drag files or folders onto the drop zone.
4. Review summary cards and redacted findings before sharing the material.

Full operator guide: [USERGUIDE.md](USERGUIDE.md)

---

## Detectors

Current first-slice coverage:

- API/token-like strings, including common OpenAI, GitHub, Slack, AWS, and generic patterns
- Private key headers
- `.env` key/value secrets
- Email addresses and phone-like strings
- URLs with query tokens
- Absolute local paths under `/Users/`
- Suspicious filenames: `id_rsa`, `.pem`, `.p12`, `.mobileprovision`, `.env`

Supported text-like inputs: `.md`, `.txt`, `.json`, `.env`, `.env.*`, `.plist`, `.yaml`, `.yml`, `.csv`, `.log`

---

## Build From Source

```bash
git clone https://github.com/nodaysidle/nodaysidle-shareguard.git
cd nodaysidle-shareguard

swift build
swift test
./Scripts/package_app.sh
codesign --verify --deep --strict --verbose=2 .build/release/ShareGuard.app
```

Release notes: [CHANGELOG.md](CHANGELOG.md)

---

## Repository Map

| Path | Purpose |
|------|---------|
| `Sources/ShareGuard/` | Swift app source |
| `Tests/ShareGuardTests/` | XCTest coverage |
| `Scripts/` | Packaging scripts |
| `USERGUIDE.md` | End-user operation guide |
| `CHANGELOG.md` | Release-facing changes |
| `docs/internal/` | Planning/spec/agent notes retained for maintainers |

---

## Status

ShareGuard is an early internal NODAYSIDLE macOS utility. Current builds are ad-hoc signed for local/internal use; public distribution should add Developer ID signing and notarization first.

## License

Proprietary — NODAYSIDLE.
