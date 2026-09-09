# hugo-theme-devrel

**DevRel overlay** for the [Dream](https://github.com/g1eny0ung/hugo-theme-dream) Hugo theme.

This is **not** a standalone theme. It imports Dream as a Hugo module dependency and overlays layouts for posts, talks, talk templates, map, videos, and about. End users only import `devrel` — Dream is pulled automatically.

**Live demos:**
- Production site: [david.pilato.fr](https://david.pilato.fr/)
- Theme `exampleSite` on GitHub Pages: [devrel.hugo.pilato.fr](https://devrel.hugo.pilato.fr/)

![Talks page](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/screenshot.png)

```toml
[[module.imports]]
  path = "github.com/dadoonet/hugo-theme-devrel"
```

Do **not** set `theme = ["devrel", "dream"]`. Do **not** vendor or fork Dream into this repo.

Dream is MIT-licensed (Copyright © 2019 Yue Yang). Attribution is preserved in [`LICENSE-DREAM`](LICENSE-DREAM) and the site footer.

## Features

- Blog posts (`content/posts/…`)
- Talks with conference metadata, PDF slides, YouTube, social embeds
- Talk templates (multilingual abstracts + “Played N times”)
- Talks map (derived from `conference.latitude` / `longitude`)
- Full-text search via [Pagefind](https://pagefind.app) Component UI (nav loupe → modal, Cmd/Ctrl+K)
- Videos listing
- About page assembled from numbered Markdown sections + `data/socials.toml`

## Screenshots

Captured from the production site [david.pilato.fr](https://david.pilato.fr/) (no browser chrome). Gallery files follow the [Hugo themes](https://github.com/gohugoio/hugoThemesSiteBuilder#media) spec: `images/screenshot.png` is 1500×1000 (3:2) and `images/tn.png` is 900×600 (3:2). README images use absolute `raw.githubusercontent.com` URLs so they also render on [themes.gohugo.io](https://themes.gohugo.io/).

### Talks hub — `/talks`

Featured cards for the latest sessions, then a compact archive, video strip, template previews, and a map summary. This is `images/screenshot.png`.

![Talks hub](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/screenshot.png)

### All talks — `/talks/all`

The full archive: decade/year jump links with per-year counts, then a card grid (cover, language, slides/video badges, conference, date). Each year also gets its own Leaflet map so you can see where that year happened, not only the global map.

![All talks](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/talks-all.png)

![All talks — per-year map](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/talks-all-year.png)

### Videos — `/talks/videos`

Only talks with a `youtube:` id. Year navigation (red pills), 16:9 cards with YouTube thumbnails, language flag, event name, and a jump to `#video` on the talk page.

![Videos](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/talks-videos.png)

### Talk templates — `/talks/templates` and `/talks/templates/<slug>`

The catalog lists every recurring topic, sorted by last played date, with “Played N times”. Open a template for stats (first/last, video count), EN/FR tabs, **Talk** vs **Raw** (CFP paste), and the chronological list of conferences.

![Talk templates](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/talks-templates.png)

![One talk template](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/talk-template.png)

### Search, a talk page, the global map

| Search (Ctrl/Cmd+K)                                                                            | Talk page                                                                                         |
|------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| ![Search](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/search.png) | ![Talk](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/talk-single.png) |

![Talks map](https://raw.githubusercontent.com/dadoonet/hugo-theme-devrel/main/images/talks-map.png)

Also in [`images/`](images/): homepage (`home.png`), About (`about.png`), and the dedicated `/search` page (`search-page.png`).

## Quick start

1. Initialize your site as a Hugo module (if needed):

   ```sh
   hugo mod init github.com/you/your-site
   ```

2. Import the theme in `hugo.toml`:

   ```toml
   [module]
     [[module.imports]]
       path = "github.com/dadoonet/hugo-theme-devrel"
   ```

3. Set your identity and optional integrations:

   ```toml
   [params]
     author = "Your Name"
     avatar = "/about/you.avif"
     headerTitle = "Your Name"
     motto = "Developer Advocate"
     email = "you@example.org"
     siteStartYear = 2024

   [params.talks]
     # Optional remote PDF base (GCS, S3, CDN). Empty = local / page-bundle PDFs.
     pdf_base_url = ""

   # Pagefind search (enabled by default). Build index after hugo:
   #   npx pagefind --site public
   # [params.search]
   #   enabled = true
   ```

4. Search is shipped by the theme (`content/search/_index.md`). Override that file in your site if you need a custom title or body. Disable with `params.search.enabled = false`.

5. Wire Pagefind into your build (site repo, not the theme):

   ```json
   {
     "scripts": {
       "build": "hugo --minify && npx pagefind --site public",
       "index": "npx pagefind --site public"
     },
     "devDependencies": { "pagefind": "^1.5.0" }
   }
   ```

   Optional Hugo mount so `hugo server` can reuse the last index:

   ```toml
   [[module.mounts]]
     source = "public/pagefind"
     target = "static/pagefind"
     disableWatch = true
   ```

6. Create content using the conventions below.

### Local development against a clone

```toml
# go.mod
replace github.com/dadoonet/hugo-theme-devrel => ../hugo-theme-devrel
```

## Content conventions

### Posts

```text
content/posts/YYYY-MM-DD-slug/index.md
```

```sh
hugo new posts/YYYY-MM-DD-something-awesome/index.md
```

Archetypes fill `author` from `site.Params.author`. `avatar` and `cover` are optional: see inferred fields below.

### Talks

```text
content/talks/YYYY/YYYY-MM-DD-event/index.md
content/talks/YYYY/YYYY-MM-DD-event/cover.*   # optional cover image
```

```sh
hugo new talks/YYYY/YYYY-MM-DD-conference-name/index.md
```

Front matter (essentials):

```yaml
title: "Talk Title"
conference:
  name: "Conference Name"
  city: "City"
  country: "Country"
  country_code: "fr"       # ISO or "online"
  url: "https://…"         # optional
  latitude: "48.856614"    # optional — used by the map
  longitude: "2.352222"
authors:
  - author: "Your Name"            # avatar inferred; set avatar: only to override
date: YYYY-MM-DD
talk-lang: en
pdf: "YYYY/YYYY-MM-DD-event.pdf"   # relative to params.talks.pdf_base_url, or site-relative if empty
talk: "Topic Name"                 # groups occurrences + links to template
youtube: "VIDEO_ID"                # optional
links: []                          # optional resources
social: []                         # optional X / Bluesky / LinkedIn post URLs
```

Drop `cover:` when the bundle contains `cover.*`. Drop `avatar:` when the speaker is `params.author` (uses `params.avatar`) or when a file exists at `static/speakers/firstname_lastname.{avif,svg,webp,png,jpg,jpeg}`. Set those fields only to use a different filename — `exampleSite` does this on FOSDEM (`cover: hero.svg`) and for Jordan Blake (`avatar: speakers/jordan.svg`).

`social` is a list of public post URLs. The theme embeds X, Bluesky, and LinkedIn (see JavaZone in `exampleSite`).

### Talk templates

```text
content/talks/templates/<slug>/index.md
```

```yaml
layout: "template"   # required
talk: "Topic Name"   # must match talk: on occurrences
versions:
  - label: "EN"
    flag: "gb"
    title: "…"
    abstract: |
      …
```

```sh
hugo new talks/templates/my-talk/index.md
# then set layout: template and talk: …
```

### Satellite talk pages

Ship these `_index.md` files (also in `exampleSite/`):

| Path                                | Front matter          | What it shows                                        |
|-------------------------------------|-----------------------|------------------------------------------------------|
| `content/talks/all/_index.md`       | `layout: "all"`       | Every talk, grouped by year, plus a map **per year** |
| `content/talks/map/_index.md`       | `layout: "map"`       | One global map of all talks with coordinates         |
| `content/talks/videos/_index.md`    | `layout: "videos"`    | Talks that have `youtube:`, year filters, 16:9 cards |
| `content/talks/templates/_index.md` | `layout: "templates"` | Recurring topics sorted by last played date          |

### About

```text
content/about/index.md      # shell page
content/about/10-me.md      # sections sorted by filename
content/about/20-details.md
content/about/you.avif      # avatar
data/socials.toml           # Dream socials format
```

The About layout lists socials, then each `*.md` section (except `index.md`) by name order.

## Params reference

| Param                                | Role                                                 |
|--------------------------------------|------------------------------------------------------|
| `params.author` / `params.avatar`    | Default speaker identity (archetypes + fallbacks)    |
| `params.talks.pdf_base_url`          | Prefix for talk `pdf:` paths; empty = local URLs     |
| `params.search.enabled`              | Pagefind UI (`/search` + Ctrl/Cmd+K); default `true` |
| `params.navItems.talks` / `about_me` | Dream nav entries (defaults provided)                |
| `params.advanced.customCSS`          | Includes theme `css/custom.css` by default           |

Taxonomies provided by the theme: `tags`, `categories`, `series`, `cities`, `languages`.

## Dream coupling

Overlays assume Dream’s structure: `{{ define "main" }}`, `dream-grid` / daisyUI classes, and Dream partials (`paginator.html`, `socials.html`, `commentSystemHeads.html`, CSS pipeline via `assets/css/output.css`).

## exampleSite

Fictional demo content for **Alex Rivera** (not a real speaker). Live at [devrel.hugo.pilato.fr](https://devrel.hugo.pilato.fr/). For a production site using this theme, see [david.pilato.fr](https://david.pilato.fr/).

The example site ships enough pages to exercise every layout:

| Kind       | What is in `exampleSite/`                                                                                      |
|------------|----------------------------------------------------------------------------------------------------------------|
| Posts      | 5 page bundles; one dated 2099 (generated, not listed or indexed)                                              |
| Talks      | 8 sessions; one dated 2099 (Upcoming card, not indexed); FOSDEM sets `cover: hero.svg`                         |
| Templates  | 3 recurring topics (`Search that scales`, `Observability for humans`, `Communities that last`) with EN/FR copy |
| Videos     | 2 talks with YouTube ids so `/talks/videos/` is not empty                                                      |
| Social     | JavaZone lists public X, Bluesky, and LinkedIn URLs for the three embed types                                  |
| About      | Numbered sections (`10-`, `20-`, `30-`) plus `data/socials.toml`                                               |
| Co-speaker | J on the Beach; Jordan sets `avatar: speakers/jordan.svg` (not `firstname_lastname`)                           |

A GitHub Actions workflow (`.github/workflows/pages.yml`) builds `exampleSite` (Hugo + Pagefind) and deploys it to GitHub Pages on every push to `main`. Pull requests are not built there: Netlify serves the deploy preview (`netlify.toml`).

**One-time Pages + DNS setup** (needed because `david.pilato.fr` is already the custom domain of the user site `dadoonet.github.io`, which would otherwise redirect project URLs to a 404):

1. DNS: `CNAME` `devrel.hugo.pilato.fr` → `dadoonet.github.io`
2. Repo **Settings → Pages → Source = GitHub Actions**
3. Repo **Settings → Pages → Custom domain** = `devrel.hugo.pilato.fr`, then enable **Enforce HTTPS**
4. Confirm `exampleSite/static/CNAME` contains `devrel.hugo.pilato.fr` (shipped in this repo)

**One-time Netlify setup** (this is the only `exampleSite` build on PRs; same pattern as [david.pilato.fr](https://david.pilato.fr/)):

1. In Netlify: **Add new project → Import an existing project** → GitHub → `dadoonet/hugo-theme-devrel`
2. Leave build settings to `netlify.toml` (command, publish directory, env)
3. Deploy. The first production build is skipped on purpose (`ignore = "exit 0"` on `main` and branch deploys). After that, each PR gets a preview URL from the Netlify GitHub App

### Keeping CI tools up to date

| What                    | How                                                                              |
|-------------------------|----------------------------------------------------------------------------------|
| GitHub Actions          | Dependabot (`.github/dependabot.yml`), weekly                                    |
| `pagefind` (npm)        | Dependabot on `exampleSite/`, weekly                                             |
| Go modules (Dream, ...) | Dependabot on `/` and `exampleSite/`, weekly                                     |
| Hugo / Go / Node pins   | `.github/versions.env` and `netlify.toml` via `update-tool-versions`, weekly PR  |

Dependabot cannot rewrite arbitrary `HUGO_VERSION=` strings in workflows; those pins are centralized in `versions.env` (and copied to `netlify.toml`) by the scheduled workflow above.

```sh
cd exampleSite
hugo mod tidy
hugo --minify
npx --yes pagefind --site public
bash scripts/assert-pagefind-skips-future.sh public
hugo server
```

Use a `replace` in `exampleSite/go.mod` pointing at the parent theme while developing.

Pagefind indexes pages marked with `data-pagefind-body` (posts, talks, talk templates, about). Future-dated posts and talks omit that attribute in production, so `--buildFuture` can still generate their URLs (upcoming talks, scheduled posts) without leaking them in search — the same date filter already used on the homepage, archives, category/tag lists, and RSS. Talk templates and about pages are always indexed. The home RSS omits future talks as well; `/talks/index.xml` still lists upcoming sessions. Filters: `section:posts`, `section:talks`, `section:templates`, `section:videos`, `section:about`. Cover images (front matter, `cover.*`, or YouTube thumbnail) are exposed as result images. Indexed pages emit `data-pagefind-sort="date:YYYY-MM-DD"`; empty queries (browse / filter alone) sort by date descending, while non-empty queries keep Pagefind relevance scoring. The nav shows a search icon that opens a centered modal; the section filter appears on the same row as the query once you type. Contextual presets apply on `/posts*` and `/talks*` (including templates/videos). A basic `/search` page remains; a richer dedicated search UI may come later.

## License

MIT — see [`LICENSE`](LICENSE). Includes Dream under MIT — see [`LICENSE-DREAM`](LICENSE-DREAM).
