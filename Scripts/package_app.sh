#!/usr/bin/env bash
set -euo pipefail

# package_app.sh — build a release .app bundle for ShareGuard
# Usage: ./Scripts/package_app.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/.build"
RELEASE_DIR="${BUILD_DIR}/release"
APP_NAME="ShareGuard"
APP_BUNDLE="${RELEASE_DIR}/${APP_NAME}.app"
EXECUTABLE_NAME="ShareGuard"
BUNDLE_ID="com.nodaysidle.ShareGuard"
MACOS_MIN="14.0"

echo "==> Building release executable…"
swift build -c release \
    --package-path "${REPO_ROOT}" \
    --build-path "${BUILD_DIR}" \
    -Xswiftc -strict-concurrency=complete

EXECUTABLE="${BUILD_DIR}/arm64-apple-macosx/release/${EXECUTABLE_NAME}"
if [[ ! -f "${EXECUTABLE}" ]]; then
    # Fallback for non-arm64 toolchain paths
    EXECUTABLE="${BUILD_DIR}/release/${EXECUTABLE_NAME}"
fi
if [[ ! -f "${EXECUTABLE}" ]]; then
    echo "ERROR: release executable not found at expected path"
    exit 1
fi

echo "==> Generating app icon…"
if [[ -f "${REPO_ROOT}/Scripts/generate_app_icon.sh" ]]; then
    bash "${REPO_ROOT}/Scripts/generate_app_icon.sh"
fi

echo "==> Cleaning previous bundle…"
rm -rf "${APP_BUNDLE}"

echo "==> Creating .app bundle layout…"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${EXECUTABLE}" "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"

echo "==> Writing Info.plist…"
cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>${MACOS_MIN}</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

echo "==> Writing PkgInfo…"
printf 'APPL????' > "${APP_BUNDLE}/Contents/PkgInfo"

echo "==> Copying Resources if present…"
if [[ -d "${REPO_ROOT}/Resources" ]]; then
    cp -R "${REPO_ROOT}/Resources/"* "${APP_BUNDLE}/Contents/Resources/" 2>/dev/null || true
fi
if [[ -f "${APP_BUNDLE}/Contents/Resources/AppIcon.icns" ]]; then
    echo "==> App icon bundled: AppIcon.icns"
else
    echo "ERROR: AppIcon.icns missing from bundle resources"
    exit 1
fi

echo "==> Ad-hoc signing bundle…"
codesign --force --deep --sign - --options runtime "${APP_BUNDLE}"

echo "==> Verifying signature…"
codesign --verify --verbose "${APP_BUNDLE}"

echo "==> Bundle created at: ${APP_BUNDLE}"
echo "==> Done."
