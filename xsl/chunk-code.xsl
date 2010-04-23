<?xml version="1.0" encoding="ASCII"?>
<!--This file was created automatically by html2xhtml-->
<!--from the HTML stylesheets.-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:cf="http://docbook.sourceforge.net/xmlns/chunkfast/1.0"
  xmlns:ng="http://docbook.org/docbook-ng"
  xmlns:db="http://docbook.org/ns/docbook"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl cf ng db"
  version="1.0">

<xsl:include href="blog/main.xsl"/>

<!-- ********************************************************************
     $Id: chunk-code.xsl 8345 2009-03-16 06:44:07Z bobstayton $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://docbook.sf.net/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->

<xsl:template match="*" mode="find.chunks">
  <xsl:variable name="chunk">
    <xsl:call-template name="chunk"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$chunk != 0">
      <cf:div id="{generate-id()}">
        <xsl:apply-templates select="." mode="class.attribute"/>
        <xsl:apply-templates select="*" mode="find.chunks"/>
      </cf:div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*" mode="find.chunks"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- xsl:template match="/">
  <xsl:apply-templates select="part[@id='projects']" />
</xsl:template -->

<!-- ====================================================================== -->

<xsl:template match="set|book|part|preface|chapter|appendix|article|reference|refentry|book/glossary|article/glossary|part/glossary|book/bibliography|article/bibliography|part/bibliography|colophon">
  <xsl:call-template name="process-chunk-element"/>
</xsl:template>

<xsl:template match="sect1|sect2|sect3|sect4|sect5|section">
  <xsl:variable name="ischunk">
    <xsl:call-template name="chunk"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="not(parent::*)">
      <xsl:call-template name="process-chunk-element"/>
    </xsl:when>
    <xsl:when test="$ischunk = 0">
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="process-chunk-element"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="setindex|book/index|article/index|part/index">
  <!-- some implementations use completely empty index tags to indicate -->
  <!-- where an automatically generated index should be inserted. so -->
  <!-- if the index is completely empty, skip it. -->
  <xsl:if test="count(*) > 0 or $generate.index != '0'">
    <xsl:call-template name="process-chunk-element"/>
  </xsl:if>
</xsl:template>

<!-- Resolve xml:base attributes -->
<xsl:template match="@fileref">
  <!-- need a check for absolute urls -->
  <xsl:choose>
    <xsl:when test="contains(., ':')">
      <!-- it has a uri scheme so it is an absolute uri -->
      <xsl:value-of select="."/>
    </xsl:when>
    <xsl:when test="$keep.relative.image.uris != 0">
      <!-- leave it alone -->
      <xsl:value-of select="."/>
    </xsl:when>
    <xsl:otherwise>
      <!-- its a relative uri -->
      <xsl:call-template name="relative-uri">
        <xsl:with-param name="destdir">
          <xsl:call-template name="dbhtml-dir">
            <xsl:with-param name="context" select=".."/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
