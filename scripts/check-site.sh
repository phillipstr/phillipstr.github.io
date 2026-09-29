#!/usr/bin/env bash
# Sanity-check a built copy of the site.
#
#   bash scripts/check-site.sh [site_dir]     (default: _site)
#
# Jekyll can "succeed" while the theme is silently missing (this repo has been
# there: a missing layout only produces a warning). These checks make that
# failure loud. They deliberately don't depend on what the content says.
set -euo pipefail

site="${1:-_site}"
config="_config.yml"

fail() {
  echo "check-site: FAIL: $*" >&2
  exit 1
}

[ -s "$site/index.html" ] || fail "$site/index.html is missing or empty"

# Present only if the theme's default layout was applied to the page.
grep -q 'class="page-content"' "$site/index.html" ||
  fail "theme layout not applied to index.html (is remote_theme loading?)"

# Compiled from assets/main.scss, which imports the theme's Sass.
[ -s "$site/assets/main.css" ] ||
  fail "$site/assets/main.css is missing or empty (theme styles not built)"

# The name from _config.yml should be rendered on the page.
name="$(sed -n 's/^name:[[:space:]]*//p' "$config" | head -n 1)"
[ -n "$name" ] || fail "no 'name:' found in $config"
grep -qF "$name" "$site/index.html" ||
  fail "site name '$name' from $config not found in index.html"

echo "check-site: OK ($site)"
