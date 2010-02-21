<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" xmlns="http://www.w3.org/1999/xhtml"
  version="1.0">

  <xsl:template name="write.chunk">
    <xsl:param name="filename" select="''" />
    <xsl:param name="content" />
    <xsl:message>
      <xsl:text> -- </xsl:text>
      <xsl:value-of select="name(.)" />
      <xsl:text> -> </xsl:text>
      <xsl:value-of select="$filename" />
    </xsl:message>
    <exsl:document href="{$filename}" method="xml" encoding="UTF-8"
      indent="yes" omit-xml-declaration="no" cdata-section-elements=""
      doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
      <xsl:copy-of select="$content" />
    </exsl:document>
  </xsl:template>

</xsl:stylesheet>
