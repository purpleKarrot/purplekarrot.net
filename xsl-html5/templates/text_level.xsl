<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="ulink">
    <a>
      <xsl:attribute name="href"><xsl:value-of select="@url" /></xsl:attribute>
      <xsl:apply-templates />
    </a>
  </xsl:template>

  <xsl:template match="emphasis">
    <em>
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="computeroutput|literallayout">
    <code>
      <xsl:apply-templates />
    </code>
  </xsl:template>

  <xsl:template match="quote">
    <q>
      <xsl:apply-templates />
    </q>
  </xsl:template>

</xsl:stylesheet>
