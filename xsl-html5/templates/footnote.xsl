<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="object.id">
    <xsl:param name="object" select="." />
    <xsl:choose>
      <xsl:when test="$object/@id">
        <xsl:value-of select="$object/@id" />
      </xsl:when>
      <xsl:when test="$object/@xml:id">
        <xsl:value-of select="$object/@xml:id" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="generate-id($object)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="footnote.number">
    <xsl:choose>
      <xsl:when test="string-length(@label) != 0">
        <xsl:value-of select="@label" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(preceding::footnote[not(@label)]) + 1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="footnote">
    <xsl:variable name="name">
      <xsl:call-template name="object.id" />
    </xsl:variable>
    <xsl:variable name="href">
      <xsl:text>#ftn.</xsl:text>
      <xsl:call-template name="object.id" />
    </xsl:variable>
    <sup class="footnote">
      <a id="{$name}" href="{$href}">
        <xsl:call-template name="footnote.number" />
      </a>
    </sup>
  </xsl:template>

</xsl:stylesheet>
