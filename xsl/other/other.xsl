<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

  <xsl:include href="../templates/html.head.xsl" />
  <xsl:include href="../templates/header.xsl" />
  <xsl:include href="../templates/footer.xsl" />

  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;&#10;</xsl:text>
    <html>
      <head>
        <meta charset="utf-8" />
        <xsl:copy>
          <xsl:copy-of select="/html/head/*" />
        </xsl:copy>
        <link rel="stylesheet" href="/purplekarrot.css" type="text/css" />
        <script src="/purplekarrot.js" type="text/javascript">;</script>
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