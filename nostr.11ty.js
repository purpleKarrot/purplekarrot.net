export const data = { permalink: "/.well-known/nostr.json" };

export function render({ collections, metadata }) {
  const articles = { kinds: [30023], authors: [metadata.npub] };
  const directory = { names: { _: metadata.npub }, "/": { filter: articles } };

  for (const post of collections.posts) {
    directory[post.url] = {
      filter: { ...articles, "#d": [post.fileSlug], limit: 1 },
    };
  }

  return JSON.stringify(directory, null, 2) + "\n";
}
