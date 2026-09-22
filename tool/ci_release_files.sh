#!/usr/bin/env bash
# E20-T05: CI'da imzo va muhit fayllari — GitHub sirlari/o'zgaruvchilaridan
# (DEPLOY.md 4-bo'lim). Fayllar repoga tushmaydi (.gitignore), qiymatlar
# logga chiqarilmaydi.
#
#   tool/ci_release_files.sh <staging|prod>
set -euo pipefail
cd "$(dirname "$0")/.."

flavor="${1:?flavor kerak: staging yoki prod}"
case "$flavor" in
  staging | prod) ;;
  *) echo "Noma'lum flavor: $flavor" >&2; exit 2 ;;
esac

missing=()
for name in KEYSTORE_BASE64 KEYSTORE_PASSWORD KEY_ALIAS KEY_PASSWORD \
  SUPABASE_URL SUPABASE_PUBLISHABLE_KEY; do
  [ -n "${!name:-}" ] || missing+=("$name")
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo "Sozlanmagan: ${missing[*]} (DEPLOY.md 4-bo'lim)" >&2
  exit 1
fi

# Imzo kaliti (runner vaqtinchalik papkasida) va key.properties.
keystore="${RUNNER_TEMP:-/tmp}/upload.jks"
echo "$KEYSTORE_BASE64" | base64 -d > "$keystore"
umask 077
cat > android/key.properties <<EOF
storeFile=$keystore
storePassword=$KEYSTORE_PASSWORD
keyAlias=$KEY_ALIAS
keyPassword=$KEY_PASSWORD
EOF

case "$flavor" in
  staging) scheme="mywallet-stg" ;;
  prod) scheme="mywallet" ;;
esac

# --dart-define-from-file uchun (Firebase bo'sh bo'lsa — push o'chiq).
python3 - "$flavor" "$scheme" > "env/$flavor.json" <<'PY'
import json, os, sys
flavor, scheme = sys.argv[1], sys.argv[2]
print(json.dumps({
    "APP_ENV": flavor,
    "SUPABASE_URL": os.environ["SUPABASE_URL"],
    "SUPABASE_PUBLISHABLE_KEY": os.environ["SUPABASE_PUBLISHABLE_KEY"],
    "GOOGLE_WEB_CLIENT_ID": os.environ.get("GOOGLE_WEB_CLIENT_ID", ""),
    "AUTH_REDIRECT": f"{scheme}://auth-callback",
    "TELEGRAM_BOT_USERNAME": os.environ.get("TELEGRAM_BOT_USERNAME", ""),
    "FIREBASE_API_KEY": os.environ.get("FIREBASE_API_KEY", ""),
    "FIREBASE_APP_ID": os.environ.get("FIREBASE_APP_ID", ""),
    "FIREBASE_MESSAGING_SENDER_ID": os.environ.get("FIREBASE_MESSAGING_SENDER_ID", ""),
    "FIREBASE_PROJECT_ID": os.environ.get("FIREBASE_PROJECT_ID", ""),
}, indent=2))
PY
echo "Imzo va env/$flavor.json tayyor."
