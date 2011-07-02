<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str">

  <xsl:import href="common.xsl" />

  <xsl:param name="chunk.depth" select="1" />

  <!-- =================================================================== -->

  <xsl:template name="is_chunk">
    <xsl:param name="node" select="." />
    <xsl:apply-templates select="$node" mode="is_chunk" />
  </xsl:template>

  <xsl:template match="*" mode="is_chunk" />

  <xsl:template
    match="set|book|part|preface|chapter|appendix|article|reference|refentry"
    mode="is_chunk">
    <xsl:text>1</xsl:text>
  </xsl:template>

  <xsl:template match="section|sect1|sect2|sect3|sect4|sect5" mode="is_chunk">
    <xsl:if test="$chunk.depth >= count(./ancestor::*)">
      <xsl:apply-templates select="./parent::*" mode="is_chunk" />
    </xsl:if>
  </xsl:template>

  <!-- =================================================================== -->

  <xsl:key name="genid" match="*" use="generate-id()" />

  <xsl:variable name="chunk.hierarchy">
    <xsl:apply-templates select="/*" mode="find.chunks" />
  </xsl:variable>

  <xsl:template match="*" mode="find.chunks">
    <xsl:variable name="this_is_chunk">
      <xsl:call-template name="is_chunk" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$this_is_chunk = '1'">
        <chunk name="{str:tokenize(@id,'.')[last()]}" id="{generate-id()}">
          <xsl:apply-templates select="*" mode="find.chunks" />
        </chunk>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*" mode="find.chunks" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="chunk.set" select="exsl:node-set($chunk.hierarchy)//chunk" />

  <!-- =================================================================== -->

  <xsl:template name="process-chunk-element">
    <xsl:variable name="genid" select="generate-id()" />

    <xsl:variable name="this_chunk" select="$chunk.set[@id=$genid]" />
    <xsl:variable name="prev_chunk"
      select="($this_chunk/preceding-sibling::chunk|$this_chunk/preceding::chunk|$this_chunk/parent::chunk)[last()]" />
    <xsl:variable name="next_chunk"
      select="($this_chunk/following-sibling::chunk|$this_chunk/following::chunk|$this_chunk/chunk)[1]" />

    <xsl:variable name="prev" select="key('genid', $prev_chunk/@id[1])" />
    <xsl:variable name="next" select="key('genid', $next_chunk/@id[1])" />

    <xsl:variable name="filename">
      <xsl:if test="$this_chunk/parent::chunk">
        <xsl:value-of select="$this_chunk/parent::chunk/@name" />
        <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:value-of select="$this_chunk/@name" />
      <xsl:text>.html</xsl:text>
    </xsl:variable>

    <exsl:document href="{$filename}" method="xml" indent="yes"
      omit-xml-declaration="yes">
      <xsl:text disable-output-escaping='yes'>&lt;!doctype html&gt;&#10;</xsl:text>
      <html>
        <head>
          <meta http-equiv="content-type" content="text/html; charset=utf-8" />
          <!-- <xsl:call-template name="head.content" /> -->
        </head>
        <body>
          <xsl:apply-imports />
        </body>
      </html>
    </exsl:document>
  </xsl:template>


  <xsl:template
    match="set|book|part|preface|chapter|appendix|article|reference|refentry">
    <xsl:call-template name="process-chunk-element" />
  </xsl:template>

  <xsl:template match="section|sect1|sect2|sect3|sect4|sect5">
    <xsl:variable name="this_is_chunk">
      <xsl:call-template name="is_chunk" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$this_is_chunk = '1'">
        <xsl:call-template name="process-chunk-element" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
