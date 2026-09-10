#!/usr/bin/env bash
# SVG covers used as <img> must be UTF-8 XML. A Latin-1 middle dot (0xB7)
# is invalid in UTF-8, so browsers report an encoding error and show a
# broken image (often described as a 404).
#
# Usage:
#   scripts/assert-svg-utf8.sh [dir]
set -euo pipefail

ROOT="${1:-content}"
if [[ ! -d "$ROOT" ]]; then
  echo "FAIL: directory ${ROOT} does not exist"
  exit 1
fi

python3 -c '
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

root = Path(sys.argv[1])
svgs = sorted(p for p in root.rglob("*.svg") if p.is_file())
if not svgs:
    print(f"FAIL: no SVG files under {root}")
    sys.exit(1)

fail = 0
for path in svgs:
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError as exc:
        print(f"FAIL: {path} is not UTF-8 ({exc})")
        fail = 1
        continue
    try:
        ET.fromstring(text)
    except ET.ParseError as exc:
        print(f"FAIL: {path} is not well-formed XML ({exc})")
        fail = 1
        continue
    print(f"OK: {path}")
sys.exit(fail)
' "$ROOT"
