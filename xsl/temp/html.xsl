<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/chunk.xsl"/>

<xsl:import href="admon.xsl"/>
<xsl:import href="footnote.xsl"/>

<xsl:import href="templates/header.xsl"/>
<xsl:import href="templates/footer.xsl"/>
<xsl:import href="templates/sidebar.xsl"/>
<xsl:import href="templates/disqus.xsl"/>

<xsl:template match="*" mode="process.root">
  <xsl:variable name="doc" select="self::*"/>

  <xsl:call-template name="user.preroot"/>
  <xsl:call-template name="root.messages"/>

  <html>
    <head>
      <xsl:call-template name="system.head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <xsl:call-template name="head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <xsl:call-template name="user.head.content">
        <xsl:with-param name="node" select="$doc"/>
      </xsl:call-template>
      <link rel="stylesheet" href="/css/purpleKarrot.css" type="text/css"/>
    </head>
    <body>
      <div id="wrap">
        <xsl:call-template name="purple.header"/>
        <div id="content-wrap">
          <div id="content">
            <xsl:call-template name="purple.sidebar"/>
            <div id="main">
              <xsl:apply-templates select="."/>
              <xsl:call-template name="disqus.thread"/>
            </div>
          </div>
        </div>
        <xsl:call-template name="purple.footer"/>
      </div>
      <xsl:call-template name="disqus.script"/>
    </body>
  </html>

  <xsl:value-of select="$html.append"/>
</xsl:template>

<xsl:template match="article">
  <h1><xsl:value-of select="./title"/></h1>
  <xsl:apply-templates/>
  <xsl:call-template name="process.footnotes"/>
</xsl:template>

<xsl:template match="programlisting">
  <pre class="programlisting">
    <xsl:apply-templates/>
  </pre>
</xsl:template>

</xsl:stylesheet>
