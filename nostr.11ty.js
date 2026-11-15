export const data = { permalink: "/.well-known/nostr.json" };

export function render({ collections, config }) {
  const relays = config.relays.filter(({ write = true }) => write).map(({ url }) => url);
  const articles = { kinds: [30023], authors: [config.pubkey] };
  const directory = { names: { _: config.pubkey }, "/": { filter: articles, relays } };

  for (const post of collections.posts) {
    directory[post.url] = {
      filter: { ...articles, "#d": [post.fileSlug], limit: 1 },
      relays,
    };
  }

  return JSON.stringify(directory, null, 2) + "\n";
}
