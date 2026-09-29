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
| `Gemfile` | Local preview only. GitHub Pages ignores it and uses its own gem set. There is deliberately no committed `Gemfile.lock` (see [Previewing locally](#previewing-locally-windows)) |
| `.github/workflows/` | CI, publish, security scans and link check (see [Automation](#automation-github-actions)) |
| `.github/dependabot.yml` | Keeps the pinned actions up to date |
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
   bundle install
   bundle exec jekyll serve
   ```

3. Open <http://localhost:4000>.

The first build needs internet access to download the theme. Restart
`jekyll serve` after editing `_config.yml`; other files reload on refresh.

**Why is there no `Gemfile.lock`?** GitHub Pages ignores it and builds with its
own gem set, so a committed lockfile can't affect the published site. The one
this repo used to have was left over from the theme's own gemspec setup: it
didn't match the `Gemfile`, pinned 2021-era gems that won't install on a current
Ruby, made Dependabot fail, and produced dozens of security alerts for gems the
site never used. `bundle install` now generates a fresh lockfile on your machine,
and `.gitignore` keeps it out of the repo.

If `wdm` fails to compile, delete its line from the `Gemfile`. It only speeds
up file watching.

## Automation (GitHub Actions)

| Workflow | Runs on | What it does |
| --- | --- | --- |
| `ci.yml` | PRs, pushes to `main` | **Lint**: yamllint (`_config.yml`, workflows), markdownlint (README), actionlint (workflow syntax). **Build**: Jekyll build with GitHub's own Pages builder, then `scripts/check-site.sh` (fails if the theme silently didn't apply). Uploads the built site as an artifact |
| `pages.yml` | pushes to `main`, manual | Builds, runs the same sanity check, and **publishes** to GitHub Pages. This is the only workflow that publishes, and both its jobs are skipped on any ref other than `main`, even when started manually |
| `security.yml` | PRs, pushes to `main`, weekly | **CodeQL** on the workflow files, **gitleaks** secret scan over full history, and **dependency review** of dependency changes on PRs, i.e. the pinned actions (fails on high severity) |
| `links.yml` | weekly, manual | Builds the site and checks every link and image, including external ones |
| `dependabot-auto-merge.yml` | Dependabot PRs | Turns on auto-merge for the safe update PRs (see [Dependency updates](#dependency-updates)) |
| Dependabot | weekly | Opens PRs to update the pinned actions |

Every action is pinned to a full commit SHA with the version in a trailing
comment. Dependabot updates both together.

To run the same site check locally after a build: `bash scripts/check-site.sh _site`.

### Dependency updates

The aim is that this repo needs no routine attention. Dependabot (`.github/dependabot.yml`) opens update PRs, CI checks them, and GitHub merges the safe ones once the required checks pass:

| Update | What happens |
| --- | --- |
| Actions, minor and patch (one grouped PR, weekly) | Auto-merged when checks pass |
| Actions, **major** | Separate PR that waits for you: a new major can change an action's inputs |
| Any PR with a failing check, or with commits pushed by a human | Not merged. It sits open and GitHub notifies you |

Updates are held back for 7 days after a release (`cooldown`), so a broken or
compromised release is likely to be caught before it reaches you. Security
updates skip that delay.

Not covered by Dependabot, because they are inline in `ci.yml` rather than
declared in a manifest: the pinned `yamllint` and `actionlint` versions. An old
version keeps working; bump them by hand if you ever want new lint rules. The
theme (`remote_theme`) is unpinned, so it follows the upstream default branch.

### One-time GitHub setup

These are repo settings that a workflow file cannot change. Status for
this repo as of 2026-09-29: all of them are done (via the `gh` CLI) and item 5
does not apply. Use this list if you ever recreate the repo or find one of these
settings has been switched back.

1. **Settings → Pages → Build and deployment → Source: GitHub Actions.** Required for `pages.yml`. Until you switch it, the deploy job fails. Switching it before the first Publish run leaves the site unpublished until that run finishes.
2. **Restrict publishing to `main`:** *Settings → Environments → github-pages → Deployment branches and tags → Selected branches and tags*, then add `main`. The `if:` guards in `pages.yml` are only a convenience: a branch can edit its own copy of the workflow, but it cannot change this setting, so this is what actually stops a non-`main` deploy. GitHub usually creates the environment with this restriction already; on this repo it was already limited to `main`. The environment exists only after the first Publish run (or once you create it by hand).
3. **Allow auto-merge:** *Settings → General → Pull Requests → Allow auto-merge*. Without it, `dependabot-auto-merge.yml` fails when it tries to enable auto-merge.
4. **Require checks on `main`:** *Settings → Rules → Rulesets → New branch ruleset*, target the default branch, and turn on **Require status checks to pass** with these four checks: `Lint`, `Build site`, `Secret scan`, `Dependency review`. Do **not** require approvals, or every Dependabot PR will wait for you. This step is what makes auto-merge safe: GitHub only merges once these pass. Two things to know: the checks only appear in the picker after they have run once (open a PR first), and status checks apply to *everything* merged into `main`, so add yourself as a bypass actor if you want to keep pushing to `main` directly. CodeQL is deliberately not required: it can't upload results on Dependabot PRs (read-only token), so it is skipped there.
5. **CodeQL:** if *Settings → Code security → CodeQL analysis* is set to **Default setup**, it conflicts with the CodeQL job in `security.yml`. Either switch it to *Advanced* or delete that job.
6. **Dependency graph / Dependabot alerts (required):** turn on *Settings → Code security → Dependabot alerts* (this also enables the dependency graph). The `Dependency review` check, which item 4 requires, fails with "Dependency review is not supported on this repository" without it. Also worth turning on, free on public repos: **Dependabot security updates**, **Secret scanning** and **Push protection**.

Dependabot and the auto-merge workflow read their config from `main`, so
changes to [Dependency updates](#dependency-updates) only take effect once
merged there.

## Notes

- To stop the theme changing under you, pin it: `remote_theme: sproogen/modern-resume-theme@<tag-or-commit>`.
- Dark mode is set with `darkmode` in `_config.yml` (`true`, `false`, or `never`).
