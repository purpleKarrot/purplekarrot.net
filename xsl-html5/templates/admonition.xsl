<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="note|important|warning|caution|tip">
    <div>
      <xsl:attribute name="class">
        <xsl:text>admonition </xsl:text>
        <xsl:value-of select="local-name(.)" />
      </xsl:attribute>
      <h3 class="title">
        <xsl:choose>
          <xsl:when test="local-name(.)='note'">
            <xsl:text>Note</xsl:text>
          </xsl:when>
          <xsl:when test="local-name(.)='important'">
            <xsl:text>Important</xsl:text>
          </xsl:when>
          <xsl:when test="local-name(.)='warning'">
            <xsl:text>Warning</xsl:text>
          </xsl:when>
          <xsl:when test="local-name(.)='caution'">
            <xsl:text>Caution</xsl:text>
          </xsl:when>
          <xsl:when test="local-name(.)='tip'">
            <xsl:text>Tip</xsl:text>
          </xsl:when>
        </xsl:choose>
      </h3>
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="note/title" />
  <xsl:template match="important/title" />
  <xsl:template match="warning/title" />
  <xsl:template match="caution/title" />
  <xsl:template match="tip/title" />

</xsl:stylesheet>
