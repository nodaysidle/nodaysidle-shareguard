#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SVG="${REPO_ROOT}/Resources/AppIcon.svg"
ICONSET="${REPO_ROOT}/.build/AppIcon.iconset"
ICNS="${REPO_ROOT}/Resources/AppIcon.icns"
PNG1024="${REPO_ROOT}/.build/AppIcon-1024.png"

if [[ ! -f "${SVG}" ]]; then
  echo "ERROR: ${SVG} missing"
  exit 1
fi

mkdir -p "${REPO_ROOT}/.build"
rm -rf "${ICONSET}"
mkdir -p "${ICONSET}"

if command -v qlmanage >/dev/null 2>&1; then
  rm -rf "${REPO_ROOT}/.build/AppIcon-1024.png" "${REPO_ROOT}/.build/AppIcon.svg.png"
  qlmanage -t -s 1024 -o "${REPO_ROOT}/.build" "${SVG}" >/dev/null 2>&1 || true
  if [[ -f "${REPO_ROOT}/.build/AppIcon.svg.png" ]]; then
    mv "${REPO_ROOT}/.build/AppIcon.svg.png" "${PNG1024}"
  fi
fi

if [[ ! -f "${PNG1024}" ]]; then
  echo "ERROR: failed to render SVG to PNG with qlmanage"
  exit 1
fi

make_icon() {
  local size="$1"
  local scale="$2"
  local pixels=$((size * scale))
  local suffix="icon_${size}x${size}"
  if [[ "${scale}" == "2" ]]; then
    suffix="${suffix}@2x"
  fi
  sips -z "${pixels}" "${pixels}" "${PNG1024}" --out "${ICONSET}/${suffix}.png" >/dev/null
}

make_icon 16 1
make_icon 16 2
make_icon 32 1
make_icon 32 2
make_icon 128 1
make_icon 128 2
make_icon 256 1
make_icon 256 2
make_icon 512 1
make_icon 512 2

iconutil -c icns "${ICONSET}" -o "${ICNS}"
echo "Generated ${ICNS}"
