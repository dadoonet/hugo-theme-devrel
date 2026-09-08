---
title: "Why I open-sourced my speaker site (fictionally)"
description: "Why a Developer Advocate might extract talks, posts, and search into a reusable Hugo theme."
author: "Alex Rivera"
tags:
  - hugo
  - opensource
  - community
categories:
  - meta
date: 2026-04-08
nolastmod: true
draft: false
---

Speaker sites rot in the same way slide decks rot: a custom layout, a private convention, and a promise to “clean it up after the next conference.”

<!--more-->

`hugo-theme-devrel` is the cleanup. It is a **Dream overlay**, not a fork: you import one module, and talks / templates / map / videos / Pagefind search come along.

This example site is intentionally fake so you can see every content type without cloning someone else’s biography:

- Blog posts with tags, an optional series, and auto-detected `cover.*` files
- Talks in several cities (for the map) and online (for the 🌎 icon)
- Recurring topics grouped by `talk:`
- Multilingual templates (`versions:`)
- A co-speaker on one session
- YouTube IDs so the videos page is not empty

Replace Alex Rivera with your name, point `params.talks.pdf_base_url` at your slide bucket, and delete this paragraph. That is the migration.
