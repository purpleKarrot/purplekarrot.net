import syntaxHighlight from "@11ty/eleventy-plugin-syntaxhighlight";

export default function (eleventyConfig) {
  eleventyConfig.addPlugin(syntaxHighlight);

  eleventyConfig.amendLibrary("md", (markdown) => {
    markdown.renderer.rules.link_open = (tokens, index, options, env, renderer) => {
      const token = tokens[index];
      const href = token.attrGet("href");
      if (href?.startsWith("nostr:")) {
        token.attrSet("href", "https://njump.me/" + href.slice(6));
      }
      return renderer.renderToken(tokens, index, options);
    };
  });

  eleventyConfig.addPassthroughCopy({ "_public/": "/" });
  eleventyConfig.addPassthroughCopy("images");
  eleventyConfig.addPassthroughCopy({
    "node_modules/nostr-tools/lib/nostr.bundle.js": "nostr-tools.js",
  });

  eleventyConfig.addWatchTarget("**/*.css");
  eleventyConfig.addBundle("css", {
    bundleHtmlContentFromSelector: "style",
  });
}
