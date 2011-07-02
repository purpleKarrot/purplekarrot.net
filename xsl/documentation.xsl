<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="common.xsl" />

  <xsl:output method="xml" encoding="UTF-8" indent="yes"
    omit-xml-declaration="yes" />

  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!doctype html&gt;&#10;</xsl:text>
    <html lang="en">
      <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <!-- <xsl:call-template name="head.content" /> -->
      </head>
      <body>
        <xsl:apply-templates />
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
