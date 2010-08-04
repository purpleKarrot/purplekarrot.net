<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="disqus.xsl" />
  <xsl:include href="navigation.xsl" />

  <xsl:template name="blog.post">

    <xsl:call-template name="write.chunk">

      <xsl:with-param name="filename">
        <xsl:text>blog/</xsl:text>
        <xsl:value-of select="@id" />
        <xsl:text>.html</xsl:text>
      </xsl:with-param>

      <xsl:with-param name="content">
        <html>
          <head>
            <title>
              <xsl:value-of select="@title" />
            </title>
            <meta charset="utf-8" />
            <link rel="stylesheet" href="/purplekarrot.css" type="text/css" />
            <script src="/purplekarrot.js" type="text/javascript">;</script>
          </head>
          <body>
            <div id="wrap">
              <xsl:call-template name="purple.header" />
              <div id="content-wrap">
                <div id="content">
                  <xsl:call-template name="blog.navigation">
                    <xsl:with-param name="class"><xsl:text>navigation1</xsl:text></xsl:with-param>
                    <xsl:with-param name="prev" select="preceding-sibling::*[1]" />
                    <xsl:with-param name="next" select="following-sibling::*[1]" />
                  </xsl:call-template>

                  <h1><xsl:value-of select="@title" /></h1>
                  <xsl:copy-of select="content/*" />
                  <xsl:call-template name="disqus.thread" />

                  <xsl:call-template name="blog.navigation">
                    <xsl:with-param name="class"><xsl:text>navigation2</xsl:text></xsl:with-param>
                    <xsl:with-param name="prev" select="preceding-sibling::*[1]" />
                    <xsl:with-param name="next" select="following-sibling::*[1]" />
                  </xsl:call-template>
                </div>
              </div>
              <xsl:call-template name="purple.footer" />
            </div>
          </body>
        </html>
      </xsl:with-param>

    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>
