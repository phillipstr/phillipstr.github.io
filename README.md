# phillipstr.github.io

Trey Phillips' resume site, published at <https://phillipstr.github.io>.

It is a [Jekyll](https://jekyllrb.com) site using the
[modern-resume-theme](https://github.com/sproogen/modern-resume-theme), built and
published to GitHub Pages by GitHub Actions. There is no custom HTML/CSS in this
repo: **all content lives in `_config.yml`**, and the theme turns it into the page.

## How it fits together

| File | Purpose |
| --- | --- |
| `_config.yml` | Everything you edit: name, title, links, About text, and the Presentations / Education / (future) Experience sections |
| `index.md` | Just front matter (`layout: default`); the theme's layout renders the sections from `_config.yml` |
| `assets/main.scss` | Imports the theme's styles; add CSS overrides here |
| `images/` | Images referenced from `_config.yml` (profile photo, etc.) |
| `Gemfile` / `Gemfile.lock` | Local preview only. GitHub Pages ignores them and uses its own gem set |
| `.github/workflows/` | CI, publish, security scans and link check (see [Automation](#automation-github-actions)) |
| `.github/dependabot.yml` | Keeps the pinned actions and gems up to date |
| `scripts/check-site.sh` | Sanity check on a built `_site`; CI runs it, and you can too |
| `.yamllint.yml`, `.markdownlint.yaml` | Lint rules used by CI |

The theme's layouts, includes, styles and favicon are **not** in this repo. They
are fetched from GitHub at build time via `remote_theme` in `_config.yml`.

## Picking the project back up: TODO

Search for `TODO` in `_config.yml` to find each spot.

- [ ] **Experience**: the section is commented out in `_config.yml`; fill it in and uncomment it
- [ ] **About text**: the current text is a placeholder drafted only from facts already in the config; rewrite it
- [ ] **Profile photo**: add one to `images/` and set `about_profile_image`
- [ ] Presentations: add Red Hat Summit 2022 (or other talks), or leave as is
- [ ] Optional: Education description, a Skills section, extra links (`additional_links`, Twitter, etc.)
- [ ] `images/landscape-trees.jpg` is the theme's sample image and is now unused; delete it or replace it
- [ ] When ready to go live: do the one-time [GitHub setup](#one-time-github-setup) (mainly switching **Settings → Pages → Source** to *GitHub Actions*), then merge to `main`

## Previewing locally (Windows)

Local preview is optional: every pull request builds the site in CI and attaches
the result as a downloadable `site-preview` artifact, and pushing to `main`
publishes it. To preview changes on your machine before pushing:

1. Install Ruby **with DevKit** from <https://rubyinstaller.org/downloads/> (3.2 or 3.3 recommended; newer versions are untested with the Pages gems). Let the installer run `ridk install` when it finishes.
2. From this folder:

   ```bash
   bundle update
   bundle exec jekyll serve
   ```

3. Open <http://localhost:4000>.

The first build needs internet access to download the theme. Restart
`jekyll serve` after editing `_config.yml`; other files reload on refresh.

**Why `bundle update` the first time?** `Gemfile.lock` was generated in 2021
and pins old native gems (`nokogiri 1.10`, `ffi 1.11`, ...) that will not
install on a current Ruby. `bundle update` re-resolves to the current
`github-pages` release. Commit the refreshed `Gemfile.lock` afterwards.

If `wdm` fails to compile, delete its line from the `Gemfile`. It only speeds
up file watching.

## Automation (GitHub Actions)

| Workflow | Runs on | What it does |
| --- | --- | --- |
| `ci.yml` | PRs, pushes to `main` | **Lint**: yamllint (`_config.yml`, workflows), markdownlint (README), actionlint (workflow syntax). **Build**: Jekyll build with GitHub's own Pages builder, then `scripts/check-site.sh` (fails if the theme silently didn't apply). Uploads the built site as an artifact |
| `pages.yml` | pushes to `main`, manual | Builds, runs the same sanity check, and **publishes** to GitHub Pages. This is the only workflow that publishes, and both its jobs are skipped on any ref other than `main`, even when started manually |
| `security.yml` | PRs, pushes to `main`, weekly | **CodeQL** on the workflow files, **gitleaks** secret scan over full history, and **dependency review** of `Gemfile.lock` changes on PRs (fails on high severity) |
| `links.yml` | weekly, manual | Builds the site and checks every link and image, including external ones |
| Dependabot | weekly (actions), monthly (gems) | Opens PRs to update pinned actions and gems |

Every action is pinned to a full commit SHA with the version in a trailing
comment. Dependabot updates both together.

To run the same site check locally after a build: `bash scripts/check-site.sh _site`.

### One-time GitHub setup

These are repo settings that a workflow file cannot change:

1. **Settings → Pages → Build and deployment → Source: GitHub Actions.** Required for `pages.yml`. Until you switch it, the deploy job fails. Switching it before the first Publish run leaves the site unpublished until that run finishes.
2. **Restrict publishing to `main`:** *Settings → Environments → github-pages → Deployment branches and tags → Selected branches and tags*, then add `main`. The `if:` guards in `pages.yml` are only a convenience: a branch can edit its own copy of the workflow, but it cannot change this setting, so this is what actually stops a non-`main` deploy. GitHub usually creates the environment with this restriction already, but check. The environment exists only after the first Publish run (or once you create it by hand).
3. **CodeQL:** if *Settings → Code security → CodeQL analysis* is set to **Default setup**, it conflicts with the CodeQL job in `security.yml`. Either switch it to *Advanced* or delete that job.
4. Optional, and free on public repos: turn on **Dependabot alerts** and **Secret scanning → Push protection**. Also consider a branch protection rule on `main` requiring the `Lint` and `Build site` checks.

Note that `Gemfile.lock` is stale, so GitHub will show Dependabot alerts for its
old gems until you run `bundle update` and commit the result. This does not
affect the published site.

## Notes

- To stop the theme changing under you, pin it: `remote_theme: sproogen/modern-resume-theme@<tag-or-commit>`.
- Dark mode is set with `darkmode` in `_config.yml` (`true`, `false`, or `never`).
