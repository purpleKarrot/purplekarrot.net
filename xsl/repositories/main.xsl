<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output omit-xml-declaration="yes" />

  <xsl:variable name="smallcase" select="'-abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uppercase" select="'_ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <xsl:template match="/">
    <xsl:for-each select="repositories/repository">
      <xsl:text>add_repository(</xsl:text>
      <xsl:apply-templates />
      <xsl:text>)

</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*">
    <xsl:value-of select="translate(local-name(.), $smallcase, $uppercase)" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="." />
    <xsl:text> </xsl:text>
  </xsl:template>

</xsl:stylesheet>
