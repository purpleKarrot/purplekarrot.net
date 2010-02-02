<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/footnote.xsl"/>

<xsl:template name="process.footnotes">
  <xsl:variable name="footnotes" select=".//footnote"/>
  <xsl:variable name="table.footnotes" select=".//tgroup//footnote"/>

  <!-- Only bother to do this if there's at least one non-table footnote -->
  <xsl:if test="count($footnotes)&gt;count($table.footnotes)">
    <div class="footnotes">
      <xsl:apply-templates select="$footnotes" mode="process.footnote.mode"/>
    </div>
  </xsl:if>

</xsl:template>
	
</xsl:stylesheet>
