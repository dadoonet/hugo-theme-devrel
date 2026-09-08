---
title: How this About page is built
---

The About layout lists socials from `data/socials.toml`, then each Markdown file in `content/about/` except `index.md`, sorted by filename. That is why the files are named `10-me.md`, `20-details.md`, `30-speaking.md`.

Add a file, pick a title in front matter, write Markdown. No extra template work.
