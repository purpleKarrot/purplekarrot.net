<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

  <xsl:include href="impl/header.xsl" />
  <xsl:include href="impl/footer.xsl" />

  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!doctype html&gt;&#10;</xsl:text>
    <html lang="en">
      <head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <title>
          <xsl:value-of select="/html/head/title" />
          <xsl:text> - purpleKarrot</xsl:text>
        </title>
        <xsl:copy>
          <xsl:copy-of select="/html/head/*[not(self::title)]" />
        </xsl:copy>
        <link rel="shortcut icon" href="/favicon.png" />
        <link rel="stylesheet" href="/purplekarrot.css" type="text/css" />
        <script src="/purplekarrot.js" type="text/javascript">/**/</script>
      </head>
      <body>
        <div id="wrap">
          <xsl:call-template name="purple.header" />
          <div id="content-wrap">
            <div id="content">
              <xsl:copy>
                <xsl:copy-of select="/html/body/*" />
              </xsl:copy>
            </div>
          </div>
          <xsl:call-template name="purple.footer" />
        </div>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
