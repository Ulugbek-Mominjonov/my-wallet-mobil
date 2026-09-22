#!/usr/bin/env bash
# E20-T07: CHANGELOG.md dan bitta versiya bo'limi (reliz izohi uchun).
#
#   tool/changelog_section.sh 1.0.0
set -euo pipefail
cd "$(dirname "$0")/.."

version="${1:?versiya kerak, masalan 1.0.0}"
section="$(awk -v v="$version" '
  $0 ~ "^## \\[" v "\\]" { found = 1; next }
  found && /^## \[/ { exit }
  found { print }
' CHANGELOG.md)"
if [ -z "${section//[[:space:]]/}" ]; then
  echo "CHANGELOG.md da [$version] bo'limi yo'q" >&2
  exit 1
fi
printf '%s\n' "$section"
