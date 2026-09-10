#!/usr/bin/env bash
# Assert future-dated posts/talks are generated (buildFuture) but stay off
# public lists (home, archives, categories, tags), RSS, post prev/next nav,
# and the Pagefind index.
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

FUTURE_POST="${ROOT}/posts/2099-01-15-not-yet-published/index.html"
FUTURE_TALK="${ROOT}/talks/2099/2099-03-20-futureconf/index.html"
PAST_POST="${ROOT}/posts/2025-06-01-hello-devrel/index.html"
LATEST_POST="${ROOT}/posts/2026-04-08-why-open-source-your-speaker-site/index.html"
MID_POST="${ROOT}/posts/2026-01-20-from-laptop-to-stage/index.html"
PAST_TALK="${ROOT}/talks/2025/2025-03-15-devfest-example/index.html"
TEMPLATE="${ROOT}/talks/templates/search-that-scales/index.html"
HOME="${ROOT}/index.html"
ARCHIVES="${ROOT}/posts/index.html"

assert_file "$FUTURE_POST"
assert_file "$FUTURE_TALK"
assert_file "$PAST_POST"
assert_file "$LATEST_POST"
assert_file "$MID_POST"
assert_file "$PAST_TALK"
assert_file "$TEMPLATE"

assert_no_attr "$FUTURE_POST"
assert_no_attr "$FUTURE_TALK"
assert_has_attr "$PAST_POST"
assert_has_attr "$PAST_TALK"
assert_has_attr "$TEMPLATE"

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

assert_html_omits "$HOME" "2099-01-15-not-yet-published" "homepage"
assert_html_omits "$ARCHIVES" "2099-01-15-not-yet-published" "archives"
assert_html_omits "$LATEST_POST" "2099-01-15-not-yet-published" "latest post prev/next"
assert_html_contains "$LATEST_POST" "2026-01-20-from-laptop-to-stage" "latest post prev/next"
assert_html_omits "$MID_POST" "2099-01-15-not-yet-published" "mid post prev/next"
assert_html_contains "$MID_POST" "2026-04-08-why-open-source-your-speaker-site" "mid post next nav"
assert_html_contains "$FUTURE_POST" "2026-04-08-why-open-source-your-speaker-site" "future post prev nav"
assert_html_omits "${ROOT}/categories/index.html" "2099-01-15-not-yet-published" "all categories"
assert_html_omits "${ROOT}/tags/index.html" "2099-01-15-not-yet-published" "all tags"
assert_html_omits "${ROOT}/categories/meta/index.html" "2099-01-15-not-yet-published" "category meta"
assert_html_omits "${ROOT}/tags/hugo/index.html" "2099-01-15-not-yet-published" "tag hugo"
assert_html_contains "${ROOT}/categories/index.html" "hello-devrel" "all categories"
assert_html_contains "${ROOT}/tags/index.html" "hello-devrel" "all tags"

assert_html_omits "${ROOT}/index.xml" "2099-01-15-not-yet-published" "home RSS"
assert_html_omits "${ROOT}/index.xml" "2099-03-20-futureconf" "home RSS"
assert_html_omits "${ROOT}/posts/index.xml" "2099-01-15-not-yet-published" "posts RSS"
assert_html_omits "${ROOT}/categories/meta/index.xml" "2099-01-15-not-yet-published" "category RSS"
assert_html_omits "${ROOT}/tags/hugo/index.xml" "2099-01-15-not-yet-published" "tag RSS"
assert_html_contains "${ROOT}/index.xml" "hello-devrel" "home RSS"
assert_html_contains "${ROOT}/posts/index.xml" "hello-devrel" "posts RSS"
assert_html_contains "${ROOT}/talks/index.xml" "2025-03-15-devfest-example" "talks RSS"
assert_html_contains "${ROOT}/talks/index.xml" "2099-03-20-futureconf" "talks RSS"

load_index_text || true

assert_index_omits "ZXQ-future-post-not-yet-public" "future post marker"
assert_index_omits "ZXQ-future-talk-not-yet-public" "future talk marker"
assert_index_omits "/posts/2099-01-15-not-yet-published/" "future post URL"
assert_index_omits "/talks/2099/2099-03-20-futureconf/" "future talk URL"
assert_index_contains "Hello from the DevRel theme" "published post title"
assert_index_contains "/posts/2025-06-01-hello-devrel/" "published post URL"

exit "$fail"
