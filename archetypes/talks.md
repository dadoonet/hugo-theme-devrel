---
title: 'Talk name'
conference:
  name: '{{ replace (substr .File.ContentBaseName 11) "-" " " | title }}'
#  url: ""
  city: ""
  country: ""
  country_code: "" # online, fr, us, etc.
#  latitude: ""
#  longitude: ""
authors:
  - author: '{{ site.Params.author }}'
#   avatar: '{{ site.Params.avatar }}'  # optional; inferred from author name
#   link: "https://www.linkedin.com/in/username"
date: '{{ substr .File.ContentBaseName 0 10 }}'
talk-lang: en # fr or en
nolastmod: true
draft: true
pdf: "{{ substr .File.ContentBaseName 0 4 }}/{{ .File.ContentBaseName }}.pdf"
#cover: "hero.avif"  # optional; a cover.* file in the bundle is used automatically

# talk: Talk template name (groups occurrences + links to /talks/templates/<slug>)

#youtube: ""      # YouTube video ID
#links:
#  - title: ""
#    url: ""
#    description: ""

#social:
#  - "https://x.com/USERNAME/status/TWEET_ID"
#  - "https://bsky.app/profile/HANDLE.bsky.social/post/POST_RKEY"
#  - "https://www.linkedin.com/embed/feed/update/urn:li:activity:ACTIVITY_ID"
---

Write your abstract here.
