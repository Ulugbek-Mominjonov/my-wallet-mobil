#!/usr/bin/env bash
# E13-T07: sinxron integratsiya testlari — haqiqiy lokal Supabase (admin repo,
# contracts.lock dagi commit) bilan, host'da (emulyatorsiz).
#
#   make integration      — lokal: ../my-wallet-admin da `supabase start`
#   ADMIN_DIR=admin make integration                 — CI (admin checkout)
#   SUPABASE_URL=… SUPABASE_PUBLISHABLE_KEY=… SUPABASE_SECRET_KEY=… make integration
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -z "${SUPABASE_PUBLISHABLE_KEY:-}" ]; then
  admin_dir="${ADMIN_DIR:-../my-wallet-admin}"
  if [ ! -d "$admin_dir" ]; then
    echo "Admin repo topilmadi: $admin_dir (ADMIN_DIR yoki SUPABASE_* bering)" >&2
    exit 2
  fi
  locked="$(sed -n 's/^admin_commit=//p' contracts.lock)"
  actual="$(git -C "$admin_dir" rev-parse HEAD)"
  if [ "$locked" != "$actual" ]; then
    echo "OGOHLANTIRISH: admin $actual, shartnoma esa $locked (contracts.lock)" >&2
  fi
  status="$(cd "$admin_dir" && pnpm exec supabase status -o env | tr -d '"')"
  SUPABASE_URL="$(echo "$status" | sed -n 's/^API_URL=//p')"
  SUPABASE_PUBLISHABLE_KEY="$(echo "$status" | sed -n 's/^PUBLISHABLE_KEY=//p')"
  SUPABASE_SECRET_KEY="$(echo "$status" | sed -n 's/^SECRET_KEY=//p')"
  export SUPABASE_URL SUPABASE_PUBLISHABLE_KEY SUPABASE_SECRET_KEY
fi

flutter test integration "$@"
