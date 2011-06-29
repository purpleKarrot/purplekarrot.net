<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="itemizedlist">
    <ul>
      <xsl:apply-templates />
    </ul>
  </xsl:template>

  <xsl:template match="orderedlist">
    <ol>
      <xsl:apply-templates />
    </ol>
  </xsl:template>

  <xsl:template match="listitem">
    <li>
      <xsl:apply-templates />
    </li>
  </xsl:template>

  <xsl:template match="variablelist">
    <dl>
      <xsl:apply-templates />
    </dl>
  </xsl:template>

  <xsl:template match="varlistentry">
    <dt>
      <xsl:apply-templates select="term" />
    </dt>
    <dd>
      <xsl:apply-templates select="listitem" />
    </dd>
  </xsl:template>

  <xsl:template match="varlistentry/term|varlistentry/listitem">
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>
