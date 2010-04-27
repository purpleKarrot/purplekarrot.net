<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="blog.navigation">
    <xsl:param name="prev" />
    <xsl:param name="next" />

    <div class="navigation2">
      <!-- prev -->
      <xsl:if test="count($prev) > 0">
        <a class="prev">
          <xsl:attribute name="href"><xsl:value-of select="$prev/@id" />.html</xsl:attribute>
          <xsl:value-of select="$prev/@title" />
        </a>
      </xsl:if>
      <!-- next -->
      <xsl:if test="count($next) > 0">
        <a class="next">
          <xsl:attribute name="href"><xsl:value-of select="$next/@id" />.html</xsl:attribute>
          <xsl:value-of select="$next/@title" />
        </a>
      </xsl:if>
    </div>
  </xsl:template>

</xsl:stylesheet>
