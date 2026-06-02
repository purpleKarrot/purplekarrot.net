import syntaxHighlight from "@11ty/eleventy-plugin-syntaxhighlight";

export default function (eleventyConfig) {
  eleventyConfig.addPlugin(syntaxHighlight);

  eleventyConfig.addPassthroughCopy({ "_public/": "/" });
  eleventyConfig.addPassthroughCopy("images");

  eleventyConfig.addWatchTarget("**/*.css");
  eleventyConfig.addBundle("css", {
    bundleHtmlContentFromSelector: "style",
  });
}
