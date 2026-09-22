#!/usr/bin/env bash
# E20-T02: sovuq start o'lchovi (docs/PERF.md) — `flutter run --profile
# --trace-startup` N marta, har biri yangi jarayon; mediana.
#
#   tool/measure_startup.sh <nom> <marta> [qurilma]   # masalan: new 5 emulator-5554
set -euo pipefail
cd "$(dirname "$0")/.."
out=build/startup
device=${3:-emulator-5554}
mkdir -p "$out"
for i in $(seq 1 "$2"); do
  adb -s "$device" shell am force-stop uz.mywallet.app.dev || true
  flutter run --profile --trace-startup --flavor dev -t lib/main_dev.dart \
    -d "$device" --dart-define-from-file=env/dev.json < /dev/null > "$out/$1-$i.log" 2>&1
  cp build/start_up_info.json "$out/$1-$i.json"
done
python3 - "$out" "$1" <<'PY'
import json, glob, statistics, sys
out, label = sys.argv[1], sys.argv[2]
rows = [json.load(open(f)) for f in sorted(glob.glob(f"{out}/{label}-*.json"))]
for key in ("timeToFrameworkInitMicros", "timeAfterFrameworkInitMicros", "timeToFirstFrameMicros", "timeToFirstFrameRasterizedMicros"):
    vals = [r[key] / 1000 for r in rows if key in r]
    if vals:
        print(f"{label} {key}: median {statistics.median(vals):.0f} ms  (min {min(vals):.0f}, max {max(vals):.0f}, n={len(vals)})")
PY
