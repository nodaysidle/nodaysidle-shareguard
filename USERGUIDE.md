# ShareGuard Guide

ShareGuard is a local-first macOS pre-share privacy scanner for files and folders. It helps catch obvious leaks before you send a ZIP, publish screenshots, push a repo, or share notes.

## What it does

ShareGuard scans selected files and folders locally and reports risky content with redacted excerpts.

Current first-slice coverage:

- API/token-like strings
- Private key headers
- `.env` key/value secrets
- Email addresses
- Phone-like strings
- URLs with query tokens
- Absolute local paths under `/Users/`
- Suspicious filenames such as `id_rsa`, `.pem`, `.p12`, `.mobileprovision`, `.env`
- Image/PDF presence as manual-review items

It does **not** upload, sync, index remotely, or call a backend.

## Installed app

The local installed app path is:

```text
/Applications/ShareGuard.app
```

Launch it with:

```bash
open -n /Applications/ShareGuard.app
```

The Dock/Finder icon is a void-black rounded square with silver-metal `SG` letters.

## Basic usage

1. Open ShareGuard.
2. Drag files or folders into the drop zone.
3. Press the scan action.
4. Review the summary cards and findings list.
5. Treat findings as a pre-share checklist:
   - remove or rotate secrets
   - redact private contact details
   - replace absolute local paths
   - avoid sharing private keys or provisioning files

## Supported inputs

Text-like files:

```text
.md, .txt, .json, .env, .env.*, .plist, .yaml, .yml, .csv, .log
```

Manual-review binary files:

```text
.pdf, .png, .jpg, .jpeg
```

Folders are scanned recursively.

## Ignored folders

ShareGuard skips noisy build/vendor folders:

```text
.git
.build
node_modules
target
DerivedData
.swiftpm
.idea
.vscode
__pycache__
```

Security-relevant hidden files are intentionally scanned, including examples such as:

```text
.env
.env.local
.ssh/id_rsa
```

## Redaction model

ShareGuard should never display full matched secrets in findings. It keeps short context and masks the matched value.

Examples:

```text
OPENAI_API_KEY=du•••••••••
sk-12•••••••••abcd
```

Caveat: this is heuristic redaction, not a formal DLP guarantee. Review findings before sharing screenshots of the app itself.

## First-slice limits

ShareGuard is useful now, but still early.

Known limits:

- No OCR yet. Text visible inside screenshots is not read.
- No full PDF text extraction yet. PDFs are flagged for manual review.
- Detectors are heuristic and can miss secrets or produce false positives.
- No auto-redaction/export-clean-copy workflow yet.
- No hardened runtime notarized distribution yet; current local install is ad-hoc signed.
- Drag/drop is the primary intake path; a file picker can be added later.

## Build from source

From the repo root:

```bash
cd /Volumes/omarchyuser/projekti/nodaysidle-shareguard
swift test
./Scripts/package_app.sh
```

The packaged app is written to:

```text
.build/release/ShareGuard.app
```

## Install locally

```bash
rm -rf /Applications/ShareGuard.app
cp -R .build/release/ShareGuard.app /Applications/ShareGuard.app
xattr -dr com.apple.quarantine /Applications/ShareGuard.app 2>/dev/null || true
open -n /Applications/ShareGuard.app
```

## Verification commands

Run the local quality gate:

```bash
swift test
./Scripts/package_app.sh
codesign --verify --deep --strict --verbose=2 .build/release/ShareGuard.app
/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' .build/release/ShareGuard.app/Contents/Info.plist
file .build/release/ShareGuard.app/Contents/Resources/AppIcon.icns
```

Expected current proof:

- tests pass
- `ShareGuard.app` exists
- `CFBundleIconFile` is `AppIcon`
- `AppIcon.icns` exists in bundle resources
- codesign verification passes

## Git hygiene

Generated build artifacts must not be committed.

Check before committing:

```bash
git ls-files .build | wc -l
git status --short
```

Expected:

```text
0
```

for tracked `.build` files.

## Recommended next slice

The next useful product slice should add:

1. file/folder picker fallback
2. OCR for screenshots using Apple Vision
3. PDF text extraction with PDFKit
4. integration scan test for hidden `.env` and `.ssh/id_rsa`
5. optional clean-report export
6. a proper internal DMG package

Do not add cloud sync, accounts, telemetry, or broad remediation until the local scanner is stronger.
