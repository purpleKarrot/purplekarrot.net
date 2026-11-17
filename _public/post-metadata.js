/** Return the last tag value, as required for NIP-25 reaction targets. */
export function tag(event, name) {
  return event.tags.findLast((entry) => entry[0] === name)?.[1];
}

/** Collect reaction emoji, deduplicating copies returned by different relays. */
export function collectReactions(events, article, address) {
  const reactions = [];
  const seen = new Set();
  const segmenter = new Intl.Segmenter();
  for (const event of events) {
    if (event.kind !== 7 || seen.has(event.id)) continue;
    if (tag(event, "e") !== article.id && tag(event, "a") !== address) continue;
    seen.add(event.id);
    const label = !event.content || event.content === "+" ? "❤️" : event.content === "-" ? "👎" : event.content;
    // Only render emoji; arbitrary reaction text must not become a visible label.
    const emoji = [...segmenter.segment(label)]
      .map(({ segment }) => segment)
      .filter((segment) => /\p{Extended_Pictographic}|\p{Regional_Indicator}|\u20e3/u.test(segment)).join("");
    if (emoji) reactions.push(emoji);
  }
  return reactions;
}

/** Render reaction bubbles as a single link to the Nostr article. */
export function renderMetadata(element, reactions, pointer) {
  element.replaceChildren();
  element.href = `nostr:${pointer}`;
  for (const emoji of reactions) {
    const reaction = element.ownerDocument.createElement("span");
    reaction.textContent = emoji;
    element.append(reaction);
  }
  element.hidden = reactions.length === 0;
}

/** Fetch JSON with a bounded wait and reject unsuccessful HTTP responses. */
async function fetchJson(url) {
  const response = await fetch(url, { signal: AbortSignal.timeout(8000) });
  if (!response.ok) throw new Error("Metadata request failed");
  return response.json();
}

/** Resolve this path through NIP-AD and display a bounded relay snapshot. */
export async function loadMetadata(element, tools) {
  element.hidden = true;
  element.replaceChildren();
  const pool = new tools.SimplePool();
  try {
    const directory = await fetchJson("/.well-known/nostr.json");
    const entry = directory[window.location.pathname];
    if (!entry?.filter || !entry.relays?.length) throw new Error("No article mapping");
    const articles = await pool.querySync(entry.relays, entry.filter, { maxWait: 8000 });
    articles.sort((a, b) => b.created_at - a.created_at || a.id.localeCompare(b.id));
    const article = articles[0];
    if (!article) throw new Error("Article unavailable");
    const address = `${article.kind}:${article.pubkey}:${tag(article, "d")}`;
    const [byId, byAddress] = await Promise.all([
      pool.querySync(entry.relays, { kinds: [7], "#e": [article.id] }, { maxWait: 8000 }),
      pool.querySync(entry.relays, { kinds: [7], "#a": [address] }, { maxWait: 8000 }),
    ]);
    if (![...pool.listConnectionStatus().values()].some(Boolean)) throw new Error("Relays unavailable");
    const reactions = collectReactions([...byId, ...byAddress], article, address);
    const pointer = tools.nip19.naddrEncode({
      kind: article.kind, pubkey: article.pubkey, identifier: tag(article, "d"), relays: entry.relays,
    });
    renderMetadata(element, reactions, pointer);
  } catch {
    element.replaceChildren();
    element.hidden = true;
  } finally {
    pool.destroy();
  }
}

if (typeof document !== "undefined") {
  const element = document.querySelector("[data-nostr-metadata]");
  if (element && globalThis.NostrTools) loadMetadata(element, globalThis.NostrTools);
}
