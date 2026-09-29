source "https://rubygems.org"

# Same Jekyll + plugin set that GitHub Pages uses to build the live site, so
# local builds match production. Includes jekyll-remote-theme and jekyll-seo-tag.
gem "github-pages", group: :jekyll_plugins

# Jekyll 3.x needs webrick for `jekyll serve` on Ruby 3.0+
gem "webrick", "~> 1.8"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Performance-booster for watching directories on Windows (optional: if it
# fails to compile, delete this line; `jekyll serve` still works without it)
gem "wdm", "~> 0.2" if Gem.win_platform?
