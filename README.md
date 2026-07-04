# NODAYSIDLE ShareGuard

**Local-first macOS pre-share privacy scanner.**

ShareGuard gives you a last-chance leak check before you publish, send, zip, or push files. Drop in files or folders, scan locally, and review a redacted risk report for secrets, private contact details, local paths, and suspicious share targets.

**v0.1.0** · macOS 14+ · Swift 6 · SwiftUI · no network calls

---

## Install

Download the latest release:

[Download ShareGuard v0.1.0](https://github.com/nodaysidle/nodaysidle-shareguard/releases/download/v0.1.0/ShareGuard-v0.1.0-macos.zip)

> ⚠️ **Verify the download**
>
> Always verify the SHA256 checksum of the downloaded zip before unzipping and running.
>
> | Asset | SHA256 |
> |-------|--------|
> | `ShareGuard-v0.1.0-macos.zip` | `a14e01aa0aa077173d447abe8f2492507d5660e38c881daf0bad86d4d3038088` |
>
> ```bash
> shasum -a 256 ShareGuard-v0.1.0-macos.zip
> ```
>
> The output must match the checksum above exactly.

1. Unzip the downloaded archive.
2. Drag `ShareGuard.app` to `/Applications`.

> **Note on signing:** ShareGuard is ad-hoc signed. macOS Gatekeeper may block it on first launch.
> To open:
>
> 1. Right-click (or Control-click) `ShareGuard.app` in Finder
> 2. Select **Open** from the context menu
> 3. Click **Open** in the Gatekeeper dialog
>
> This is a one-time step. Developer ID signing and notarization are on the roadmap.

---

## Quick Start

1. Launch ShareGuard.app.
2. Drag files or folders onto the drop zone.
3. Review summary cards and redacted findings before sharing the material.

Full operator guide: [USERGUIDE.md](USERGUIDE.md)

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

---

## Status

ShareGuard v0.1.0 is a public pre-share privacy scanner for macOS, actively developed by NODAYSIDLE. The current release is ad-hoc signed; Developer ID signing and notarization are planned for a future release.

See [CHANGELOG.md](CHANGELOG.md) for release history and known limitations.

## License

[Proprietary](LICENSE) — Copyright © 2026 NODAYSIDLE. All rights reserved.
