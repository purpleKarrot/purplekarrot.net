<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">

  <xsl:import href="date.xsl" />
  <xsl:import href="disqus.xsl" />

  <xsl:template name="blog.index">
    <xsl:param name="nodes" />

    <xsl:call-template name="write.chunk">

      <xsl:with-param name="filename">
        <xsl:text>index.html</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="content">
        <html>
          <head>
            <title>
              <xsl:value-of select="purpleKarrot" />
            </title>
            <link rel="stylesheet" href="/stylesheet.css" type="text/css" />
          </head>
          <body>
            <div id="wrap">
              <xsl:call-template name="purple.header" />
              <div id="content-wrap">
                <div id="content">
                  <xsl:call-template name="purple.sidebar" />
                  <div id="main">

                    <xsl:for-each select="$nodes">

                      <xsl:variable name="link">
                        <xsl:text>blog/</xsl:text>
                        <xsl:value-of select="@id" />
                        <xsl:text>.html</xsl:text>
                      </xsl:variable>

                      <xsl:variable name="commentslink">
                        <xsl:text>blog/</xsl:text>
                        <xsl:value-of select="@id" />
                        <xsl:text>.html#disqus_thread</xsl:text>
                      </xsl:variable>

                      <div class="post">
                        <h1>
                          <xsl:value-of select="@title" />
                        </h1>

                        <xsl:copy-of select="summary/*" />

                        <p class="post-footer align-right">
                          <a href="{$link}" class="readmore">Read more</a>
                          <a href="{$commentslink}" class="comments">Comments</a>
                          <span class="date">
                            <xsl:call-template name="blog.date">
                              <xsl:with-param name="text" select="@date" />
                            </xsl:call-template>
                          </span>
                        </p>

                      </div>
                    </xsl:for-each>

                  </div>
                </div>
              </div>
              <xsl:call-template name="purple.footer" />
            </div>
            <xsl:call-template name="disqus.script" />
          </body>
        </html>
      </xsl:with-param>

    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>
