#!/usr/bin/env python3
"""Qoplama chegarasini tekshiradi.

DoD: `packages/domain/lib/src/calc/` uchun ≥95%. Qolgan qismlar uchun
umumiy chegara pastroq — ular asosan konstruktor va nusxalash kodi.
"""
import re
import sys
from pathlib import Path

CALC_THRESHOLD = 95.0
TOTAL_THRESHOLD = 80.0


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else '.coverage/lcov.info')
    if not path.exists():
        print(f'❌ {path} topilmadi')
        return 1

    total_found = total_hit = calc_found = calc_hit = 0
    for block in path.read_text().split('end_of_record'):
        name = re.search(r'SF:(.*)', block)
        if not name:
            continue
        found = int(re.search(r'LF:(\d+)', block).group(1))
        hit = int(re.search(r'LH:(\d+)', block).group(1))
        total_found += found
        total_hit += hit
        if '/calc/' in name.group(1):
            calc_found += found
            calc_hit += hit

    calc_percent = 100 * calc_hit / max(calc_found, 1)
    total_percent = 100 * total_hit / max(total_found, 1)
    print(f'calc/  : {calc_hit}/{calc_found} = {calc_percent:.1f}% '
          f'(talab ≥{CALC_THRESHOLD}%)')
    print(f'umumiy : {total_hit}/{total_found} = {total_percent:.1f}% '
          f'(talab ≥{TOTAL_THRESHOLD}%)')

    if calc_percent < CALC_THRESHOLD:
        print('❌ calc/ qoplamasi yetarli emas')
        return 1
    if total_percent < TOTAL_THRESHOLD:
        print('❌ umumiy qoplama yetarli emas')
        return 1
    print('✅ Qoplama talablari bajarildi')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
