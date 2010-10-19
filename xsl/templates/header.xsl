<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="purple.part" select="''" />

  <xsl:template name="purple.header">
    <div id="header">
      <h1 id="logo">
        <xsl:text>purple</xsl:text>
        <span class="gray">Karrot</span>
      </h1>
      <ul>
        <li>
          <a href="/index.html">
            <xsl:if test="$purple.part = 'blog'">
              <xsl:attribute name="id">current</xsl:attribute>
            </xsl:if>
            <xsl:text>Blog</xsl:text>
          </a>
        </li>
        <li>
          <a href="/projects.html">
            <xsl:if test="$purple.part = 'projects'">
              <xsl:attribute name="id">current</xsl:attribute>
            </xsl:if>
            <xsl:text>Projects</xsl:text>
          </a>
        </li>
        <li>
          <a href="/downloads.html">
            <xsl:if test="$purple.part = 'downloads'">
              <xsl:attribute name="id">current</xsl:attribute>
            </xsl:if>
            <xsl:text>Downloads</xsl:text>
          </a>
        </li>
        <li>
          <a href="/forum.html">
            <xsl:if test="$purple.part = 'forum'">
              <xsl:attribute name="id">current</xsl:attribute>
            </xsl:if>
            <xsl:text>Forum</xsl:text>
          </a>
        </li>
        <li>
          <a href="/about.html">
            <xsl:if test="$purple.part = 'about'">
              <xsl:attribute name="id">current</xsl:attribute>
            </xsl:if>
            <xsl:text>About</xsl:text>
          </a>
        </li>
      </ul>
    </div>
  </xsl:template>
</xsl:stylesheet>
