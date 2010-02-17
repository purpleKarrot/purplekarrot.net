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

</xsl:stylesheet>
