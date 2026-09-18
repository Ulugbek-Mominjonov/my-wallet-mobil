#!/usr/bin/env bash
# contracts/ qo'lda o'zgartirilmaganini tekshiradi: fayllar sha256 i
# contracts.lock dagi bilan mos bo'lishi kerak (CI).
#
#   tool/check_contracts.sh          — tekshirish
#   tool/check_contracts.sh --hash   — joriy hash'ni chiqarish (sync uchun)
set -euo pipefail
cd "$(dirname "$0")/.."

# LC_ALL=C: fayllar tartibi lokalga bog'liq bo'lmasin (CI va lokal bir xil hash).
current_hash() {
  (cd contracts && find . -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum) \
    | sha256sum | cut -d' ' -f1
}

if [ "${1:-}" = "--hash" ]; then
  current_hash
  exit 0
fi

expected="$(grep '^sha256=' contracts.lock | cut -d= -f2)"
if [ "$(current_hash)" != "$expected" ]; then
  echo "::error::contracts/ contracts.lock bilan mos emas — qo'lda o'zgartirmang, tool/sync_contracts.sh ishlating"
  exit 1
fi
echo "contracts/ yaxlit (admin $(grep '^admin_commit=' contracts.lock | cut -d= -f2 | cut -c1-7))"
