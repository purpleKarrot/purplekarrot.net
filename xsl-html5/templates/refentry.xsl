<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="refentry">
    <section>
      <xsl:apply-templates />
    </section>
  </xsl:template>

  <xsl:template match="refmeta">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="refsynopsisdiv">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="refentrytitle">
    <h2>
      <xsl:apply-templates />
    </h2>
  </xsl:template>

  <xsl:template match="refsection|refsect1|refsect2|refsect3">
    <section>
      <xsl:apply-templates select="(title|info/title)[1]" />
      <xsl:apply-templates select="node()[not(self::title) and not(self::info)]" />
    </section>
  </xsl:template>

  <xsl:template match="manvolnum" />
  <xsl:template match="refmiscinfo" />

  <xsl:template match="refnamediv">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="refname">
    <xsl:if test="not(preceding-sibling::refdescriptor)">
      <xsl:apply-templates />
      <xsl:if test="following-sibling::refname">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="refpurpose">
    <xsl:if test="node()">
      <xsl:text> -- </xsl:text>
      <xsl:apply-templates />
    </xsl:if>
  </xsl:template>

  <xsl:template match="refdescriptor">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="refclass">
    <xsl:if test="$refclass.suppress = 0">
      <b>
        <xsl:if test="@role">
          <xsl:value-of select="@role" />
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:apply-templates />
      </b>
    </xsl:if>
  </xsl:template>

  <xsl:template match="refsynopsisdivinfo" />
  <xsl:template match="refsynopsisdiv/title" />

  <xsl:template match="refsection/title|refsection/info/title">
    <xsl:variable name="level" select="count(ancestor-or-self::refsection)" />
    <xsl:variable name="refsynopsisdiv">
      <xsl:text>0</xsl:text>
      <xsl:if test="ancestor::refsynopsisdiv">
        1
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="hlevel">
      <xsl:choose>
        <xsl:when test="$level + $refsynopsisdiv > 5">
          6
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$level + 1 + $refsynopsisdiv" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="h{$hlevel}">
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template match="refsect1/title|refsect1/info/title">
    <h2>
      <xsl:apply-templates />
    </h2>
  </xsl:template>

  <xsl:template match="refsect2/title|refsect2/info/title">
    <h3>
      <xsl:apply-templates />
    </h3>
  </xsl:template>

  <xsl:template match="refsect3/title|refsect3/info/title">
    <h4>
      <xsl:apply-templates />
    </h4>
  </xsl:template>

</xsl:stylesheet>
