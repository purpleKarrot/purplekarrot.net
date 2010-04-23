<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common">

  <xsl:template name="write.chunk">

    <xsl:param name="filename" select="''" />
    <xsl:param name="content" />

    <xsl:message>
      <xsl:text> -- </xsl:text>
      <xsl:value-of select="$filename" />
    </xsl:message>

    <exsl:document href="{$filename}" method="xml" indent="yes" omit-xml-declaration="yes">
      <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;&#10;</xsl:text>
      <xsl:copy-of select="$content" />
    </exsl:document>

  </xsl:template>

</xsl:stylesheet>
