<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output indent="yes" />

  <xsl:include href="templates/chunk.xslt" />

  <xsl:template match="text()" />

  <xsl:template
    match="set|book|part|preface|chapter|appendix|article|reference|refentry|sect1|sect2|sect3|sect4|sect5|section|book/glossary|article/glossary|part/glossary|book/bibliography|article/bibliography|part/bibliography|colophon">
    <xsl:variable name="ischunk">
      <xsl:call-template name="chunk" />
    </xsl:variable>
    <xsl:if test="$ischunk='1'">
      <url>
        <loc>
          <xsl:text>http://purplekarrot.net/</xsl:text>
          <xsl:apply-templates select="." mode="chunk-filename" />
        </loc>
        <lastmod>2010-01-22</lastmod>
      </url>
    </xsl:if>
    <xsl:apply-templates select="*" />
  </xsl:template>

  <xsl:template match="/">
    <urlset xmlns="http://www.google.com/schemas/sitemap/0.84">
      <xsl:apply-templates />
    </urlset>
  </xsl:template>

</xsl:stylesheet>
