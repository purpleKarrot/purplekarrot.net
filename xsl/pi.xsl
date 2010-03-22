<?xml version="1.0" encoding="ASCII"?>
<!--This file was created automatically by html2xhtml-->
<!--from the HTML stylesheets.-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://nwalsh.com/xsl/documentation/1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="doc" version="1.0">

<!-- ********************************************************************
     $Id: pi.xsl 8394 2009-04-02 20:31:30Z mzjn $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://docbook.sf.net/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->

<!-- ==================================================================== -->

<xsl:template name="pi.dbhtml_background-color">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'background-color'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_dir">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'dir'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_filename">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'filename'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_funcsynopsis-style">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'funcsynopsis-style'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_img.src.path">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'img.src.path'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_linenumbering.everyNth">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'linenumbering.everyNth'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_linenumbering.separator">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'linenumbering.separator'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_linenumbering.width">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'linenumbering.width'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_list-presentation">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'list-presentation'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_list-width">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'list-width'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_row-height">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'row-height'"/>
  </xsl:call-template>
</xsl:template> 

<xsl:template name="pi.dbhtml_start">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="pi-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'start'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_table-summary">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'table-summary'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_table-width">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'table-width'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_term-presentation">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'term-presentation'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_term-separator">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'term-separator'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_term-width">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'term-width'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbhtml_toc">
  <xsl:param name="node" select="."/>
  <xsl:call-template name="dbhtml-attribute">
    <xsl:with-param name="pis" select="$node/processing-instruction('dbhtml')"/>
    <xsl:with-param name="attribute" select="'toc'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="pi.dbcmdlist">
  <xsl:variable name="cmdsynopses" select="..//cmdsynopsis"/>
  <xsl:if test="count($cmdsynopses)&lt;1">
    <xsl:message><xsl:text>No cmdsynopsis elements matched dbcmdlist PI, perhaps it's nested too deep?</xsl:text>
    </xsl:message>
  </xsl:if>
  <dl>
    <xsl:call-template name="process.cmdsynopsis.list">
      <xsl:with-param name="cmdsynopses" select="$cmdsynopses"/>
    </xsl:call-template>
  </dl>
</xsl:template>

<xsl:template name="pi.dbfunclist">
  <xsl:variable name="funcsynopses" select="..//funcsynopsis"/>
  <xsl:if test="count($funcsynopses)&lt;1">
    <xsl:message><xsl:text>No funcsynopsis elements matched dbfunclist PI, perhaps it's nested too deep?</xsl:text>
    </xsl:message>
  </xsl:if>
  <dl>
    <xsl:call-template name="process.funcsynopsis.list">
      <xsl:with-param name="funcsynopses" select="$funcsynopses"/>
    </xsl:call-template>
  </dl>
</xsl:template>

<xsl:template name="pi.dbhtml-include">
  <xsl:param name="href">
    <xsl:call-template name="dbhtml-attribute">
      <xsl:with-param name="pis" select="."/>
      <xsl:with-param name="attribute">href</xsl:with-param>
    </xsl:call-template>
  </xsl:param>
  <xsl:choose>
    <xsl:when test="$href != ''">
      <xsl:variable name="content" select="document($href,/)"/>
      <xsl:choose>
        <xsl:when test="$content/*">
          <xsl:choose>
            <xsl:when test="$content/*[1][self::html]">
              <!-- include just the children of html wrapper -->
              <xsl:copy-of select="$content/*[1]/node()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$content"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>ERROR: dbhtml-include processing instruction </xsl:text>
            <xsl:text>href has no content.</xsl:text>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>
        <xsl:text>ERROR: dbhtml-include processing instruction has </xsl:text>
        <xsl:text>missing or empty href value.</xsl:text>
      </xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="dbhtml-attribute">
  <!-- * dbhtml-attribute is an interal utility template for retrieving -->
  <!-- * pseudo-attributes/parameters from PIs -->
  <xsl:param name="pis" select="processing-instruction('dbhtml')"/>
  <xsl:param name="attribute">filename</xsl:param>
  <xsl:call-template name="pi-attribute">
    <xsl:with-param name="pis" select="$pis"/>
    <xsl:with-param name="attribute" select="$attribute"/>
  </xsl:call-template>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="dbhtml-dir">
  <xsl:param name="context" select="."/>
  <!-- directories are now inherited from previous levels -->
  <xsl:variable name="ppath">
    <xsl:if test="$context/parent::*">
      <xsl:call-template name="dbhtml-dir">
        <xsl:with-param name="context" select="$context/parent::*"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="path">
    <xsl:call-template name="pi.dbhtml_dir">
      <xsl:with-param name="node" select="$context"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$path = ''">
      <xsl:if test="$ppath != ''">
        <xsl:value-of select="$ppath"/>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="$ppath != ''">
        <xsl:value-of select="$ppath"/>
        <xsl:if test="substring($ppath, string-length($ppath), 1) != '/'">
          <xsl:text>/</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:value-of select="$path"/>
      <xsl:text>/</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
