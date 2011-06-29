<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="*">
    <xsl:message>
      <xsl:text>Element </xsl:text>
      <xsl:value-of select="local-name(.)" />
      <xsl:text> encountered</xsl:text>
      <xsl:if test="parent::*">
        <xsl:text> in </xsl:text>
        <xsl:value-of select="name(parent::*)" />
      </xsl:if>
      <xsl:text>, but no template matches.</xsl:text>
    </xsl:message>
  </xsl:template>

</xsl:stylesheet>