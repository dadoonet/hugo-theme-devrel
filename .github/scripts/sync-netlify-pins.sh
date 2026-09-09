#!/usr/bin/env bash
# Keep netlify.toml HUGO_VERSION / GO_VERSION / NODE_VERSION aligned with
# .github/versions.env.
#
#   sync-netlify-pins.sh check   # exit 1 on mismatch
#   sync-netlify-pins.sh write   # rewrite pins from versions.env
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT}/.github/versions.env"
TOML_FILE="${ROOT}/netlify.toml"

# shellcheck disable=SC1090
source "${ENV_FILE}"

mode="${1:-check}"

check_toml() {
  python3 - "${TOML_FILE}" "${HUGO_VERSION}" "${GO_VERSION}" "${NODE_VERSION}" <<'PY'
from pathlib import Path
import re
import sys

path, hugo, go, node = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
text = Path(path).read_text()
expected = {
    "HUGO_VERSION": hugo,
    "GO_VERSION": go,
    "NODE_VERSION": node,
}
errors = []
for key, val in expected.items():
    match = re.search(rf'^\s*{re.escape(key)}\s*=\s*"([^"]*)"', text, re.M)
    if not match:
        errors.append(f"{key}: missing in netlify.toml")
        continue
    if match.group(1) != val:
        errors.append(
            f"{key}: netlify.toml has {match.group(1)!r}, "
            f".github/versions.env has {val!r}"
        )
if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
print("netlify.toml pins match .github/versions.env")
PY
}

write_toml() {
  python3 - "${TOML_FILE}" "${HUGO_VERSION}" "${GO_VERSION}" "${NODE_VERSION}" <<'PY'
from pathlib import Path
import re
import sys

path, hugo, go, node = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
text = Path(path).read_text()
values = {
    "HUGO_VERSION": hugo,
    "GO_VERSION": go,
    "NODE_VERSION": node,
}
for key, val in values.items():
    text, n = re.subn(
        rf'^(\s*{re.escape(key)}\s*=\s*")[^"]*("\s*)$',
        rf"\g<1>{val}\2",
        text,
        count=1,
        flags=re.M,
    )
    if n != 1:
        raise SystemExit(f"netlify.toml: expected 1 match for {key}, got {n}")
Path(path).write_text(text)
PY
}

case "${mode}" in
  check)
    check_toml
    ;;
  write)
    write_toml
    check_toml
    ;;
  *)
    echo "usage: $0 check|write" >&2
    exit 2
    ;;
esac
