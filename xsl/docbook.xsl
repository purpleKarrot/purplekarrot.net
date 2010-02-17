<?xml version="1.0" encoding="ASCII"?>
<!--This file was created automatically by html2xhtml-->
<!--from the HTML stylesheets.-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ng="http://docbook.org/docbook-ng" xmlns:db="http://docbook.org/ns/docbook" xmlns:exsl="http://exslt.org/common" xmlns:exslt="http://exslt.org/common" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="db ng exsl exslt" version="1.0">

<xsl:output method="xml" encoding="UTF-8" indent="no" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

<!-- ********************************************************************
     $Id: docbook.xsl 8399 2009-04-08 07:37:42Z bobstayton $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://docbook.sf.net/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->

<!-- ==================================================================== -->

<xsl:include href="param.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/lib/lib.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/l10n.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/common.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/utility.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/labels.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/titles.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/subtitles.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/gentext.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/targets.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/olink.xsl"/>
<xsl:include href="http://docbook.sourceforge.net/release/xsl/current/common/pi.xsl"/>
<xsl:include href="autotoc.xsl"/>
<xsl:include href="autoidx.xsl"/>
<xsl:include href="lists.xsl"/>
<xsl:include href="callout.xsl"/>
<xsl:include href="verbatim.xsl"/>
<xsl:include href="graphics.xsl"/>
<xsl:include href="xref.xsl"/>
<xsl:include href="formal.xsl"/>
<xsl:include href="table.xsl"/>
<xsl:include href="htmltbl.xsl"/>
<xsl:include href="sections.xsl"/>
<xsl:include href="inline.xsl"/>
<xsl:include href="footnote.xsl"/>
<xsl:include href="html.xsl"/>
<xsl:include href="division.xsl"/>
<xsl:include href="index.xsl"/>
<xsl:include href="refentry.xsl"/>
<xsl:include href="math.xsl"/>
<xsl:include href="admon.xsl"/>
<xsl:include href="component.xsl"/>
<xsl:include href="block.xsl"/>
<xsl:include href="synop.xsl"/>
<xsl:include href="titlepage.xsl"/>
<xsl:include href="titlepage.templates.xsl"/>
<xsl:include href="pi.xsl"/>
<xsl:include href="chunker.xsl"/>
<xsl:include href="annotations.xsl"/>

<xsl:param name="stylesheet.result.type" select="'xhtml'"/>
<xsl:param name="htmlhelp.output" select="0"/>

<!-- ==================================================================== -->

<xsl:key name="id" match="*" use="@id|@xml:id"/>
<xsl:key name="gid" match="*" use="generate-id()"/>

<!-- ==================================================================== -->

<xsl:template match="*">
  <xsl:message>
    <xsl:text>Element </xsl:text>
    <xsl:value-of select="local-name(.)"/>
    <xsl:text> in namespace '</xsl:text>
    <xsl:value-of select="namespace-uri(.)"/>
    <xsl:text>' encountered</xsl:text>
    <xsl:if test="parent::*">
      <xsl:text> in </xsl:text>
      <xsl:value-of select="name(parent::*)"/>
    </xsl:if>
    <xsl:text>, but no template matches.</xsl:text>
  </xsl:message>
</xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template name="body.attributes">
<!-- no apply-templates; make it empty -->
</xsl:template>

<xsl:template name="head.content">
  <xsl:param name="node" select="."/>
  <xsl:param name="title">
    <xsl:apply-templates select="$node" mode="object.title.markup.textonly"/>
  </xsl:param>

  <title>
    <xsl:copy-of select="$title"/>
  </title>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="system.head.content">
  <xsl:param name="node" select="."/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="user.preroot">
  <!-- Pre-root output, can be used to output comments and PIs. -->
  <!-- This must not output any element content! -->
</xsl:template>

<xsl:template name="user.head.content">
  <xsl:param name="node" select="."/>
  <link rel="stylesheet" href="../purplekarrot.css" type="text/css"/>
</xsl:template>

<xsl:template name="root.messages">
  <!-- redefine this any way you'd like to output messages -->
  <!-- DO NOT OUTPUT ANYTHING FROM THIS TEMPLATE -->
</xsl:template>

</xsl:stylesheet>
