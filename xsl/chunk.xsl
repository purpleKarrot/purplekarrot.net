<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common"
  xmlns:cf="http://docbook.sourceforge.net/xmlns/chunkfast/1.0"
  version="1.0" exclude-result-prefixes="cf exsl">

  <xsl:import href="docbook.xsl" />
  <xsl:import href="chunk-common.xsl" />
  <xsl:include href="chunk-code.xsl" />

  <xsl:param name="chunk.fast" select="1" />

  <xsl:variable name="chunks" select="exsl:node-set($chunk.hierarchy)//cf:div" />

  <xsl:template name="process-chunk-element">
    <xsl:variable name="genid" select="generate-id()" />

    <xsl:variable name="div" select="$chunks[@id=$genid or @xml:id=$genid]" />

    <xsl:variable name="prevdiv" select="($div/preceding-sibling::cf:div|$div/preceding::cf:div|$div/parent::cf:div)[last()]" />
    <xsl:variable name="prev" select="key('genid', ($prevdiv/@id|$prevdiv/@xml:id)[1])" />

    <xsl:variable name="nextdiv" select="($div/following-sibling::cf:div|$div/following::cf:div|$div/cf:div)[1]" />
    <xsl:variable name="next" select="key('genid', ($nextdiv/@id|$nextdiv/@xml:id)[1])" />

    <xsl:call-template name="process-chunk">
      <xsl:with-param name="prev" select="$prev" />
      <xsl:with-param name="next" select="$next" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
