---
title: Blogging with NIP-23
summary: Moving my blog from GitHub Pages to Nostr Long-form Content notes
tags: [blog, nostr, nip23]
---

What I like about GitHub Pages is that it allows me to manage all my blog posts as markdown files in a git repository. I can write, edit, and version my posts just like code, and publishing is as easy as pushing to master.

However, there are a few things I don't like about the GitHub Pages setup. For one, I find it frustrating that stylesheets live in the same repository as my posts. I prefer to keep my content and design separate, but this arrangement makes it harder to focus solely on writing. Another drawback is the lack of a central feed -- there is no built-in way to aggregate posts from different blogs or authors, which limits discoverability and the sense of community. Finally, the absence of a commenting system means interaction is strictly one-way; readers can't easily leave feedback or start a discussion, which makes the blog feel isolated.

Of course, Jekyll can generate Atom feeds, it is possible to integrate an external commenting system with JavaScript, there are widgets for displaying 👍 or ⭐ from external services, [IndieWeb](https://spec.indieweb.org/) has a list of standard protocols for cross-referencing different sites, but all these approaches have drawbacks. Am I responsible for content that is displayed on my website when it is dynamically aggregated from an external source? The biggest problem is that they need to be integrated and maintained in the project that should concentrate on content. Fiddling with JavaScript and CSS is a distraction from what matters more to me: writing blogs, books, or "real" code.

With [NIP-23](https://nips.nostr.com/23), I found a solution that works for me. I wrote a [Python script](https://github.com/purpleKarrot/purplekarrot.net/blob/master/publish) that deduces metadata from filename and frontmatter, just like Jekyll does for GitHub Pages. It then sends blog posts as kind 30023 events to multiple Nostr relays, configurable in a simple `config.yml`. That means I still have a git repository as the single source of truth for all posts and don't use an approach where I edit files through a web frontend like [Habla](https://habla.news/), even though I might add support for that in the future with a `pull` command which fetches my posts from relays and stores potential changes locally.

Basically, I have outsourced the design of my blog. It now can be read on multiple web sites and apps, and it supports bookmarks, comments, repost, upvotes, and the like and people can even send payments if they prefer. I am not fully satisfied with the look on many pages (syntax highlighting of code blocks is a feature that I miss), but I am sure it is only a matter of time until that gets resolved. I am very happy that the design is outside my control, and outside my responsibility.
