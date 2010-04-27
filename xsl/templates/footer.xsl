<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="purple.footer">
  <xsl:param name="copyright">
    Copyright &#169; 2010 <strong>Daniel Pfeifer</strong>
  </xsl:param>

<div id="footer">

  <div class="float-left">
   <p>
     <xsl:copy-of select="$copyright"/> |
     Design by: <a href="http://www.styleshout.com/"><strong>styleshout</strong></a>
   </p>
  </div>

  <div class="float-right">
   <p>
    Valid <a href="http://validator.w3.org/check/referer"><strong>HTML5</strong></a> | 
    <a href="http://jigsaw.w3.org/css-validator/check/referer"><strong>CSS</strong></a>
   </p>
  </div>

</div>

</xsl:template>
</xsl:stylesheet>
