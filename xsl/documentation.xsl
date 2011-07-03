<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../xsl-html5/chunked.xsl" />
  <xsl:include href="impl/header.xsl" />
  <xsl:include href="impl/footer.xsl" />

  <xsl:template name="html.head">
    <link rel="shortcut icon" href="/favicon.png" />
    <link rel="stylesheet" href="/purplekarrot.css" type="text/css" />
    <script src="/purplekarrot.js" type="text/javascript">/**/</script>
  </xsl:template>

  <xsl:template name="page.wrap">
    <xsl:param name="content" />
    <div id="wrap">
      <xsl:call-template name="purple.header" />
      <div id="content-wrap">
        <div id="content">
          <xsl:copy-of select="$content" />
        </div>
      </div>
      <xsl:call-template name="purple.footer" />
    </div>
  </xsl:template>

</xsl:stylesheet>
