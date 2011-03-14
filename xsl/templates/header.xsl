<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="purple.part" select="''" />

  <xsl:template name="purple.header">
    <header>
      <h1>purple<span class="gray">Karrot</span></h1>
      <nav>
        <a href="/index.html">
          <xsl:if test="$purple.part = 'blog'">
            <xsl:attribute name="id">current</xsl:attribute>
          </xsl:if>
          <xsl:text>Blog</xsl:text>
        </a>
        <a href="/projects.html">
          <xsl:if test="$purple.part = 'projects'">
            <xsl:attribute name="id">current</xsl:attribute>
          </xsl:if>
          <xsl:text>Projects</xsl:text>
        </a>
        <a href="/downloads.html">
          <xsl:if test="$purple.part = 'downloads'">
            <xsl:attribute name="id">current</xsl:attribute>
          </xsl:if>
          <xsl:text>Downloads</xsl:text>
        </a>
        <a href="/search.html">
          <xsl:if test="$purple.part = 'search'">
            <xsl:attribute name="id">current</xsl:attribute>
          </xsl:if>
          <xsl:text>Search</xsl:text>
        </a>
        <a href="/about.html">
          <xsl:if test="$purple.part = 'about'">
            <xsl:attribute name="id">current</xsl:attribute>
          </xsl:if>
          <xsl:text>About</xsl:text>
        </a>
      </nav>
    </header>
  </xsl:template>
</xsl:stylesheet>
