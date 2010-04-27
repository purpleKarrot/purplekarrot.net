<?xml version="1.0" encoding="ASCII"?>
<!--This file was created automatically by html2xhtml-->
<!--from the HTML stylesheets.-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- ********************************************************************
     $Id: division.xsl 8421 2009-05-04 07:49:49Z bobstayton $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://docbook.sf.net/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->

<xsl:template match="part">
  <div>
    <xsl:apply-templates select="." mode="common.html.attributes"/>
    <xsl:if test="$generate.id.attributes != 0">
      <xsl:attribute name="id">
        <xsl:call-template name="object.id"/>
      </xsl:attribute>
    </xsl:if>

    <xsl:call-template name="part.titlepage"/>

    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="not(partintro) and contains($toc.params, 'toc')">
      <xsl:call-template name="division.toc"/>
    </xsl:if>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="part" mode="make.part.toc">
  <xsl:call-template name="division.toc"/>
</xsl:template>

<xsl:template match="reference" mode="make.part.toc">
  <xsl:call-template name="division.toc"/>
</xsl:template>

<xsl:template match="part/docinfo"/>
<xsl:template match="part/partinfo"/>
<xsl:template match="part/info"/>
<xsl:template match="part/title"/>
<xsl:template match="part/titleabbrev"/>
<xsl:template match="part/subtitle"/>

<xsl:template match="partintro">
  <div>
    <xsl:call-template name="common.html.attributes"/>
    <xsl:if test="$generate.id.attributes != 0">
      <xsl:attribute name="id">
        <xsl:call-template name="object.id"/>
      </xsl:attribute>
    </xsl:if>

    <xsl:call-template name="partintro.titlepage"/>
    <xsl:apply-templates/>

    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="node" select="parent::*"/>
        <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="contains($toc.params, 'toc')">
      <!-- not ancestor::part because partintro appears in reference -->
      <xsl:apply-templates select="parent::*" mode="make.part.toc"/>
    </xsl:if>
    <xsl:call-template name="process.footnotes"/>
  </div>
</xsl:template>

<xsl:template match="partintro/title"/>
<xsl:template match="partintro/titleabbrev"/>
<xsl:template match="partintro/subtitle"/>

<xsl:template match="partintro/title" mode="partintro.title.mode">
  <h2>
    <xsl:apply-templates/>
  </h2>
</xsl:template>

<xsl:template match="partintro/subtitle" mode="partintro.title.mode">
  <h3>
    <i><xsl:apply-templates/></i>
  </h3>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="book" mode="division.number">
  <xsl:number from="set" count="book" format="1."/>
</xsl:template>

<xsl:template match="part" mode="division.number">
  <xsl:number from="book" count="part" format="I."/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="division.title">
  <xsl:param name="node" select="."/>

  <h1>
    <xsl:attribute name="class">title</xsl:attribute>
    <xsl:if test="$generate.id.attributes = 0">
      <xsl:call-template name="anchor">
	<xsl:with-param name="node" select="$node"/>
	<xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
    </xsl:if>
      <xsl:apply-templates select="$node" mode="object.title.markup">
      <xsl:with-param name="allow-anchors" select="1"/>
    </xsl:apply-templates>
  </h1>
</xsl:template>

</xsl:stylesheet>
