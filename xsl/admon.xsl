<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">

<xsl:template match="note|important|warning|caution|tip">
  <div>
    <xsl:attribute name="class">admonition <xsl:value-of select="local-name(.)"/></xsl:attribute>
    <h3 class="title">
      <xsl:choose>
        <xsl:when test="local-name(.)='note'">Note</xsl:when>
        <xsl:when test="local-name(.)='important'">Important</xsl:when>
        <xsl:when test="local-name(.)='warning'">Warning</xsl:when>
        <xsl:when test="local-name(.)='caution'">Caution</xsl:when>
        <xsl:when test="local-name(.)='tip'">Tip</xsl:when>
      </xsl:choose>
    </h3>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="note/title"/>
<xsl:template match="important/title"/>
<xsl:template match="warning/title"/>
<xsl:template match="caution/title"/>
<xsl:template match="tip/title"/>

</xsl:stylesheet>
