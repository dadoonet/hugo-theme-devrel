#!/usr/bin/env bash
# Assert post series taxonomy pages, nav entry, and in-article series list.
#
# Usage:
#   scripts/assert-series.sh [public-dir]
set -euo pipefail

ROOT="${1:-public}"
fail=0

assert_file() {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "FAIL: expected generated page ${f}"
    fail=1
  else
    echo "OK: page exists ${f}"
  fi
}

assert_html_contains() {
  local f="$1"
  local needle="$2"
  local label="$3"
  if [[ ! -f "$f" ]]; then
    echo "FAIL: missing ${f} (${label})"
    fail=1
    return
  fi
  if grep -q -F -- "$needle" "$f"; then
    echo "OK: ${label} includes ${needle}"
  else
    echo "FAIL: ${label} missing ${needle}"
    fail=1
  fi
}

assert_html_omits() {
  local f="$1"
  local needle="$2"
  local label="$3"
  if [[ ! -f "$f" ]]; then
    echo "FAIL: missing ${f} (${label})"
    fail=1
    return
  fi
  if grep -q -F -- "$needle" "$f"; then
    echo "FAIL: ${label} still lists ${needle}"
    fail=1
  else
    echo "OK: ${label} omits ${needle}"
  fi
}

# Series nav block of $1 must list $2 before $3 (date-ascending).
assert_series_order() {
  local f="$1"
  local first="$2"
  local second="$3"
  if [[ ! -f "$f" ]]; then
    echo "FAIL: missing ${f} (series order)"
    fail=1
    return
  fi
  local html block
  html=$(<"$f")
  case "$html" in
    *'data-devrel-series="'*)
      block="${html#*'data-devrel-series="'}"
      block="${block%%'</nav>'*}"
      ;;
    *)
      echo "FAIL: ${f} has no series list"
      fail=1
      return
      ;;
  esac
  case "$block" in
    *"$first"*"$second"*)
      echo "OK: series list orders ${first} before ${second}"
      ;;
    *)
      echo "FAIL: series list on ${f} does not order ${first} before ${second}"
      fail=1
      ;;
  esac
}

HOME="${ROOT}/index.html"
SERIES="${ROOT}/series/index.html"
CFP="${ROOT}/series/cfp-in-three-steps/index.html"
ROAD="${ROOT}/series/on-the-road/index.html"
PART1="${ROOT}/posts/2025-10-06-cfp-the-hook/index.html"
PART2="${ROOT}/posts/2025-10-13-cfp-the-outline/index.html"
PART3="${ROOT}/posts/2025-10-20-cfp-the-submit/index.html"
ROAD_POST="${ROOT}/posts/2026-01-20-from-laptop-to-stage/index.html"
PLAIN="${ROOT}/posts/2025-06-01-hello-devrel/index.html"

assert_file "$SERIES"
assert_file "$CFP"
assert_file "$ROAD"
assert_file "$PART1"
assert_file "$PART2"
assert_file "$PART3"
assert_file "${ROOT}/posts/2025-10-06-cfp-the-hook/cover.svg"
assert_file "${ROOT}/posts/2025-10-13-cfp-the-outline/cover.svg"
assert_file "${ROOT}/posts/2025-10-20-cfp-the-submit/cover.svg"

assert_html_contains "$HOME" 'title="All Series"' "homepage series nav"
if [[ -f "$HOME" ]] && grep -Eq 'name="?albums"?' "$HOME"; then
  echo "OK: homepage series icon includes albums"
else
  echo "FAIL: homepage series icon missing albums"
  fail=1
fi
assert_html_contains "$SERIES" "cfp-in-three-steps" "all series"
assert_html_contains "$SERIES" "on-the-road" "all series"
assert_html_contains "$CFP" "2025-10-06-cfp-the-hook" "CFP series term"
assert_html_contains "$CFP" "2025-10-13-cfp-the-outline" "CFP series term"
assert_html_contains "$CFP" "2025-10-20-cfp-the-submit" "CFP series term"

assert_html_contains "$PART2" 'data-devrel-series="CFP in Three Steps"' "part 2 series list"
assert_html_contains "$PART2" "data-devrel-series-current" "part 2 highlights current"
assert_series_order "$PART2" "2025-10-06-cfp-the-hook" "2025-10-20-cfp-the-submit"

assert_html_contains "$ROAD_POST" 'data-devrel-series="On the Road"' "on the road series list"
assert_html_omits "$PLAIN" "data-devrel-series" "post without series"

exit "$fail"
