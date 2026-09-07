# hugo-theme-devrel

**DevRel overlay** for the [Dream](https://github.com/g1eny0ung/hugo-theme-dream) Hugo theme.

This is **not** a standalone theme. It imports Dream as a Hugo module dependency and overlays layouts for posts, talks, talk templates, map, videos, and about. End users only import `devrel` — Dream is pulled automatically.

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

Archetypes fill `author` / `avatar` from `site.Params.author` / `site.Params.avatar`.

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
  - author: "Your Name"
    avatar: "/about/you.avif"
date: YYYY-MM-DD
talk-lang: en
pdf: "YYYY/YYYY-MM-DD-event.pdf"   # relative to params.talks.pdf_base_url, or site-relative if empty
talk: "Topic Name"                 # groups occurrences + links to template
youtube: "VIDEO_ID"                # optional
links: []                          # optional resources
social: []                         # optional X / Bluesky / LinkedIn URLs
```

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

| Path | Front matter |
|------|----------------|
| `content/talks/all/_index.md` | `layout: "all"` |
| `content/talks/map/_index.md` | `layout: "map"` |
| `content/talks/videos/_index.md` | `layout: "videos"` |
| `content/talks/templates/_index.md` | `layout: "templates"` |

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

| Param | Role |
|-------|------|
| `params.author` / `params.avatar` | Default speaker identity (archetypes + fallbacks) |
| `params.talks.pdf_base_url` | Prefix for talk `pdf:` paths; empty = local URLs |
| `params.search.enabled` | Pagefind UI (`/search` + Ctrl/Cmd+K); default `true` |
| `params.navItems.talks` / `about_me` | Dream nav entries (defaults provided) |
| `params.advanced.customCSS` | Includes theme `css/custom.css` by default |

Taxonomies provided by the theme: `tags`, `categories`, `series`, `cities`, `languages`.

## Dream coupling

Overlays assume Dream’s structure: `{{ define "main" }}`, `dream-grid` / daisyUI classes, and Dream partials (`paginator.html`, `socials.html`, `commentSystemHeads.html`, CSS pipeline via `assets/css/output.css`).

## exampleSite

Fictional demo content (not a real speaker’s talks):

```sh
cd exampleSite
hugo mod tidy
hugo --minify
npx --yes pagefind@1.5.0 --site public
hugo server
```

Use a `replace` in `exampleSite/go.mod` pointing at the parent theme while developing.

Pagefind indexes pages marked with `data-pagefind-body` (posts, talks, talk templates, about). Filters: `section:posts`, `section:talks`, `section:templates`, `section:videos`, `section:about`. Cover images (front matter, `cover.*`, or YouTube thumbnail) are exposed as result images. Indexed pages emit `data-pagefind-sort="date:YYYY-MM-DD"`; empty queries (browse / filter alone) sort by date descending, while non-empty queries keep Pagefind relevance scoring. The nav shows a search icon that opens a centered modal; the section filter appears on the same row as the query once you type. Contextual presets apply on `/posts*` and `/talks*` (including templates/videos). A basic `/search` page remains; a richer dedicated search UI may come later.

## License

MIT — see [`LICENSE`](LICENSE). Includes Dream under MIT — see [`LICENSE-DREAM`](LICENSE-DREAM).
