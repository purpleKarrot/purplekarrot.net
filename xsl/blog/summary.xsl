<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="blog.summary">
    <xsl:choose>
      <!-- If there is a purpose for this article, use it as summary -->
      <xsl:when test="chapterinfo/articlepurpose">
        <p>
          <xsl:value-of select="chapterinfo/articlepurpose" />
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="summary" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="summary">
    <xsl:apply-templates select="." />
  </xsl:template>

  <xsl:template match="note|important|warning|caution|tip" mode="summary" />

</xsl:stylesheet>
