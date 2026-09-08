---
title: '{{ replace .File.ContentBaseName "-" " " | title }}'
description: "CONTENT"
author: '{{ site.Params.author }}'
#avatar: '{{ site.Params.avatar }}'  # optional; inferred from author name / params.avatar
tags:
  - TAG
categories:
  - CATEGORY
series:
  - SERIE
date: '{{ .Date }}'
nolastmod: true
#cover: image.avif  # optional; a cover.* file in the bundle is used automatically
draft: true
---

Write your content here.

<!--more-->

## Use H2 Title

Even more content here.
