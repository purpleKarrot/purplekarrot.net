<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="purple.footer">
    <xsl:param name="copyright">
      <xsl:text>Copyright &#169; 2010, 2011 </xsl:text>
      <strong>Daniel Pfeifer</strong>
    </xsl:param>

    <footer>
      <div class="float-left">
        <xsl:copy-of select="$copyright" />
      </div>
      <div class="float-right">
        <xsl:text>Valid </xsl:text>
        <a href="http://validator.w3.org/check/referer">
          <strong>HTML5</strong>
        </a>
        <xsl:text> | </xsl:text>
        <a href="http://jigsaw.w3.org/css-validator/check/referer?profile=css3">
          <strong>CSS3</strong>
        </a>
      </div>
    </footer>

  </xsl:template>
</xsl:stylesheet>
