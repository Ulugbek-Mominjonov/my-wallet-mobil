#!/usr/bin/env bash
# Admin repodagi contracts/ ni shu repoga ko'chiradi va contracts.lock yozadi
# (ADR-14). Mobil repoda contracts/ qo'lda o'zgartirilmaydi.
#
#   tool/sync_contracts.sh <to'liq-commit-sha|branch|teg>  — GitHub admin repodan
#   tool/sync_contracts.sh ../my-wallet-admin    — lokal klondan (joriy HEAD)
set -euo pipefail
cd "$(dirname "$0")/.."

source_ref="${1:-}"
if [ -z "$source_ref" ]; then
  echo "Foydalanish: $0 <commit|branch|teg|lokal-papka>" >&2
  exit 2
fi
repo_url="${ADMIN_REPO_URL:-https://github.com/Ulugbek-Mominjonov/my-wallet-admin.git}"

if [ -d "$source_ref/contracts" ]; then
  admin_dir="$source_ref"
else
  admin_dir="$(mktemp -d)"
  trap 'rm -rf "$admin_dir"' EXIT
  git -C "$admin_dir" init -q
  git -C "$admin_dir" remote add origin "$repo_url"
  git -C "$admin_dir" fetch -q --depth 1 origin "$source_ref"
  git -C "$admin_dir" checkout -q FETCH_HEAD
fi
commit="$(git -C "$admin_dir" rev-parse HEAD)"

rm -rf contracts
cp -R "$admin_dir/contracts" contracts
{
  echo "admin_commit=$commit"
  echo "sha256=$(tool/check_contracts.sh --hash)"
} > contracts.lock
echo "contracts/ yangilandi: admin $commit"
