#!/usr/bin/env bash
# Assert upcoming talks are generated from their announcement date (no
# buildFuture required) while staying off Pagefind and home RSS until
# conference.date.
#
# Usage:
#   scripts/assert-pagefind-skips-future.sh [public-dir]
#   scripts/assert-pagefind-skips-future.sh [public-dir] --buildFuture
#
# Default build (CI / Netlify / GitHub Pages): scheduled posts are absent
# because Hugo did not generate them. --buildFuture: Hugo generated the
# post, and the theme must list it everywhere (home, archives, taxonomies,
# RSS, Pagefind, prev/next). Talks still follow conference.date.
set -euo pipefail

ROOT="public"
BUILD_FUTURE=0
for arg in "$@"; do
  case "$arg" in
    --buildFuture|--build-future)
      BUILD_FUTURE=1
      ;;
    *)
      ROOT="$arg"
      ;;
  esac
done

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

assert_no_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    echo "FAIL: ${f} should not be generated without buildFuture"
    fail=1
  else
    echo "OK: page absent ${f}"
  fi
}

assert_has_attr() {
  local f="$1"
  if grep -q 'data-pagefind-body' "$f"; then
    echo "OK: ${f} is marked for Pagefind"
  else
    echo "FAIL: ${f} should be indexed (missing data-pagefind-body)"
    fail=1
  fi
}

assert_no_attr() {
  local f="$1"
  if grep -q 'data-pagefind-body' "$f"; then
    echo "FAIL: ${f} should not be indexed (has data-pagefind-body)"
    fail=1
  else
    echo "OK: ${f} has no data-pagefind-body"
  fi
}

# Pagefind stores result JSON in gzipped *.pf_fragment files.
# Dump once so grep -q does not SIGPIPE gzip under pipefail.
INDEX_TEXT=""
load_index_text() {
  local f
  if [[ ! -d "${ROOT}/pagefind/fragment" ]]; then
    echo "FAIL: Pagefind fragments missing at ${ROOT}/pagefind/fragment"
    fail=1
    return 1
  fi
  INDEX_TEXT=""
  shopt -s nullglob
  for f in "${ROOT}/pagefind/fragment/"*.pf_fragment; do
    INDEX_TEXT+="$(gzip -dc "$f")"$'\n'
  done
}

assert_index_omits() {
  local needle="$1"
  local label="$2"
  if [[ "$INDEX_TEXT" == *"$needle"* ]]; then
    echo "FAIL: Pagefind index contains ${label} (${needle})"
    fail=1
  else
    echo "OK: Pagefind index omits ${label}"
  fi
}

assert_index_contains() {
  local needle="$1"
  local label="$2"
  if [[ "$INDEX_TEXT" == *"$needle"* ]]; then
    echo "OK: Pagefind index contains ${label}"
  else
    echo "FAIL: Pagefind index missing ${label} (${needle})"
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

FUTURE_POST="${ROOT}/posts/2099-01-15-not-yet-published/index.html"
FUTURE_TALK="${ROOT}/talks/2099/2099-03-20-futureconf/index.html"
PAST_POST="${ROOT}/posts/2025-06-01-hello-devrel/index.html"
LATEST_POST="${ROOT}/posts/2026-04-08-why-open-source-your-speaker-site/index.html"
MID_POST="${ROOT}/posts/2026-01-20-from-laptop-to-stage/index.html"
PAST_TALK="${ROOT}/talks/2025/2025-03-15-devfest-example/index.html"
FOSDEM="${ROOT}/talks/2026/2026-02-01-fosdem/index.html"
TEMPLATE="${ROOT}/talks/templates/search-that-scales/index.html"
HOME="${ROOT}/index.html"
ARCHIVES="${ROOT}/posts/index.html"
TALKS="${ROOT}/talks/index.html"
ALL_TALKS="${ROOT}/talks/all/index.html"

# Upcoming talk is announced (date in the past) so Hugo generates it without
# buildFuture. Scheduled posts stay unpublished in the default build; with
# --buildFuture Hugo emits them and the theme must not hide them.
if [[ "$BUILD_FUTURE" -eq 1 ]]; then
  assert_file "$FUTURE_POST"
  assert_has_attr "$FUTURE_POST"
else
  assert_no_file "$FUTURE_POST"
fi
assert_file "$FUTURE_TALK"
assert_file "$PAST_POST"
assert_file "$LATEST_POST"
assert_file "$MID_POST"
assert_file "$PAST_TALK"
assert_file "$FOSDEM"
assert_file "$TEMPLATE"

assert_no_attr "$FUTURE_TALK"
assert_has_attr "$PAST_POST"
assert_has_attr "$PAST_TALK"
assert_has_attr "$TEMPLATE"

if [[ "$BUILD_FUTURE" -eq 1 ]]; then
  assert_html_contains "$HOME" "2099-01-15-not-yet-published" "homepage"
  assert_html_contains "$ARCHIVES" "2099-01-15-not-yet-published" "archives"
  assert_html_contains "$LATEST_POST" "2099-01-15-not-yet-published" "latest post prev/next"
  assert_html_contains "${ROOT}/categories/index.html" "2099-01-15-not-yet-published" "all categories"
  assert_html_contains "${ROOT}/tags/index.html" "2099-01-15-not-yet-published" "all tags"
  assert_html_contains "${ROOT}/categories/meta/index.html" "2099-01-15-not-yet-published" "category meta"
  assert_html_contains "${ROOT}/tags/hugo/index.html" "2099-01-15-not-yet-published" "tag hugo"
  assert_html_contains "${ROOT}/index.xml" "2099-01-15-not-yet-published" "home RSS"
  assert_html_contains "${ROOT}/posts/index.xml" "2099-01-15-not-yet-published" "posts RSS"
  assert_html_contains "${ROOT}/categories/meta/index.xml" "2099-01-15-not-yet-published" "category RSS"
  assert_html_contains "${ROOT}/tags/hugo/index.xml" "2099-01-15-not-yet-published" "tag RSS"
else
  assert_html_omits "$HOME" "2099-01-15-not-yet-published" "homepage"
  assert_html_omits "$ARCHIVES" "2099-01-15-not-yet-published" "archives"
  assert_html_omits "$LATEST_POST" "2099-01-15-not-yet-published" "latest post prev/next"
  assert_html_omits "${ROOT}/categories/index.html" "2099-01-15-not-yet-published" "all categories"
  assert_html_omits "${ROOT}/tags/index.html" "2099-01-15-not-yet-published" "all tags"
  assert_html_omits "${ROOT}/categories/meta/index.html" "2099-01-15-not-yet-published" "category meta"
  assert_html_omits "${ROOT}/tags/hugo/index.html" "2099-01-15-not-yet-published" "tag hugo"
  assert_html_omits "${ROOT}/index.xml" "2099-01-15-not-yet-published" "home RSS"
  assert_html_omits "${ROOT}/posts/index.xml" "2099-01-15-not-yet-published" "posts RSS"
  assert_html_omits "${ROOT}/categories/meta/index.xml" "2099-01-15-not-yet-published" "category RSS"
  assert_html_omits "${ROOT}/tags/hugo/index.xml" "2099-01-15-not-yet-published" "tag RSS"
fi
assert_html_contains "$LATEST_POST" "2026-01-20-from-laptop-to-stage" "latest post prev/next"
assert_html_omits "$MID_POST" "2099-01-15-not-yet-published" "mid post prev/next"
assert_html_contains "$MID_POST" "2026-04-08-why-open-source-your-speaker-site" "mid post next nav"
assert_html_contains "${ROOT}/categories/index.html" "hello-devrel" "all categories"
assert_html_contains "${ROOT}/tags/index.html" "hello-devrel" "all tags"

assert_html_omits "${ROOT}/index.xml" "2099-03-20-futureconf" "home RSS"
assert_html_contains "${ROOT}/index.xml" "hello-devrel" "home RSS"
assert_html_contains "${ROOT}/posts/index.xml" "hello-devrel" "posts RSS"
assert_html_contains "${ROOT}/talks/index.xml" "2025-03-15-devfest-example" "talks RSS"
assert_html_contains "${ROOT}/talks/index.xml" "2099-03-20-futureconf" "talks RSS"

# Event date (conference.date), not the January 2026 announcement.
assert_html_contains "$FUTURE_TALK" "Mar. 2099" "future talk page event month"
assert_html_contains "$TALKS" "upcoming-table" "talks hub upcoming table"
assert_html_contains "$TALKS" "March 20, 2099" "talks hub upcoming event date"
assert_html_contains "$TALKS" "FutureConf" "talks hub upcoming conference"
assert_html_contains "$ALL_TALKS" "hidden-link" "all talks masked permalink"
assert_html_contains "$ALL_TALKS" "2099-03-20-futureconf" "all talks upcoming card"
assert_html_contains "$FOSDEM" "Feb. 2026" "FOSDEM event month (not announcement)"

# FOSDEM was announced in 2025 for a 2026 event — group under 2026.
# Pure bash: `python3 -` reads the program from stdin and can hang on CI
# images that keep fd 0 open.
year_id_pos() {
  local html="$1"
  local year="$2"
  local needle prefix
  for needle in "id=year-${year}" "id=\"year-${year}\"" "id='year-${year}'"; do
    case "$html" in
      *"$needle"*)
        prefix="${html%%"${needle}"*}"
        echo "${#prefix}"
        return 0
        ;;
    esac
  done
  echo -1
}

if [[ ! -f "$ALL_TALKS" ]]; then
  echo "FAIL: missing ${ALL_TALKS} (all talks year grouping)"
  fail=1
else
  _all_html=$(<"$ALL_TALKS")
  idx_2099=$(year_id_pos "$_all_html" 2099)
  idx_2026=$(year_id_pos "$_all_html" 2026)
  idx_2025=$(year_id_pos "$_all_html" 2025)
  if [[ "$idx_2026" -lt 0 ]]; then
    echo "FAIL: missing year-2026 section on /talks/all/"
    fail=1
  fi
  if [[ "$idx_2025" -lt 0 ]]; then
    echo "FAIL: missing year-2025 section on /talks/all/"
    fail=1
  fi
  body_2026=""
  body_2025=""
  body_2099=""
  if [[ "$idx_2026" -ge 0 ]]; then
    if [[ "$idx_2025" -gt "$idx_2026" ]]; then
      body_2026="${_all_html:idx_2026:$((idx_2025 - idx_2026))}"
    else
      body_2026="${_all_html:idx_2026}"
    fi
  fi
  if [[ "$idx_2025" -ge 0 ]]; then
    body_2025="${_all_html:idx_2025}"
  fi
  if [[ "$idx_2099" -ge 0 ]]; then
    if [[ "$idx_2026" -gt "$idx_2099" ]]; then
      body_2099="${_all_html:idx_2099:$((idx_2026 - idx_2099))}"
    else
      body_2099="${_all_html:idx_2099}"
    fi
  fi
  if [[ "$body_2026" != *2026-02-01-fosdem* ]]; then
    echo "FAIL: FOSDEM missing from 2026 year group on /talks/all/"
    fail=1
  else
    echo "OK: FOSDEM grouped under 2026"
  fi
  if [[ "$body_2025" == *2026-02-01-fosdem* ]]; then
    echo "FAIL: FOSDEM wrongly listed under 2025 (announcement year)"
    fail=1
  else
    echo "OK: FOSDEM omitted from 2025 year group"
  fi
  if [[ "$body_2025" != *2025-03-15-devfest-example* ]]; then
    echo "FAIL: DevFest (no conference.date) missing from 2025 year group"
    fail=1
  else
    echo "OK: DevFest fallback date grouped under 2025"
  fi
  if [[ "$idx_2099" -ge 0 && "$body_2099" != *2099-03-20-futureconf* ]]; then
    echo "FAIL: FutureConf missing from 2099 year group"
    fail=1
  elif [[ "$idx_2099" -ge 0 ]]; then
    echo "OK: FutureConf grouped under 2099"
  fi
  unset _all_html body_2026 body_2025 body_2099 idx_2099 idx_2026 idx_2025
fi

load_index_text || true

if [[ "$BUILD_FUTURE" -eq 1 ]]; then
  assert_index_contains "ZXQ-future-post-not-yet-public" "future post marker"
  assert_index_contains "/posts/2099-01-15-not-yet-published/" "future post URL"
else
  assert_index_omits "ZXQ-future-post-not-yet-public" "future post marker"
  assert_index_omits "/posts/2099-01-15-not-yet-published/" "future post URL"
fi
assert_index_omits "ZXQ-future-talk-not-yet-public" "future talk marker"
assert_index_omits "/talks/2099/2099-03-20-futureconf/" "future talk URL"
assert_index_contains "Hello from the DevRel theme" "published post title"
assert_index_contains "/posts/2025-06-01-hello-devrel/" "published post URL"

exit "$fail"
