<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="html.head">
    <xsl:param name="prev" select="/foo" />
    <xsl:param name="next" select="/foo" />
    <xsl:variable name="this" select="." />
    <xsl:variable name="home" select="/*[1]" />
    <xsl:variable name="up" select="parent::*" />

    <head>
      <meta charset="utf-8" />
      <xsl:call-template name="head.content" />

      <xsl:if test="$home">
        <link rel="home">
          <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$home" />
          </xsl:call-template>
        </xsl:attribute>
          <xsl:attribute name="title">
          <xsl:apply-templates select="$home"
            mode="object.title.markup.textonly" />
        </xsl:attribute>
        </link>
      </xsl:if>

      <xsl:if test="$up">
        <link rel="up">
          <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$up" />
          </xsl:call-template>
        </xsl:attribute>
          <xsl:attribute name="title">
          <xsl:apply-templates select="$up"
            mode="object.title.markup.textonly" />
        </xsl:attribute>
        </link>
      </xsl:if>

      <xsl:if test="$prev">
        <link rel="prev">
          <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$prev" />
          </xsl:call-template>
        </xsl:attribute>
          <xsl:attribute name="title">
          <xsl:apply-templates select="$prev"
            mode="object.title.markup.textonly" />
        </xsl:attribute>
        </link>
      </xsl:if>

      <xsl:if test="$next">
        <link rel="next">
          <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$next" />
          </xsl:call-template>
        </xsl:attribute>
          <xsl:attribute name="title">
          <xsl:apply-templates select="$next"
            mode="object.title.markup.textonly" />
        </xsl:attribute>
        </link>
      </xsl:if>

      <xsl:if test="$html.extra.head.links != 0">
        <xsl:for-each
          select="//part                             |//reference                             |//preface                             |//chapter                             |//article                             |//refentry                             |//appendix[not(parent::article)]|appendix                             |//glossary[not(parent::article)]|glossary                             |//index[not(parent::article)]|index">
          <link rel="{local-name(.)}">
            <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="context" select="$this" />
              <xsl:with-param name="object" select="." />
            </xsl:call-template>
          </xsl:attribute>
            <xsl:attribute name="title">
            <xsl:apply-templates select="."
              mode="object.title.markup.textonly" />
          </xsl:attribute>
          </link>
        </xsl:for-each>

        <xsl:for-each select="section|sect1|refsection|refsect1">
          <link>
            <xsl:attribute name="rel">
            <xsl:choose>
              <xsl:when
              test="local-name($this) = 'section'                               or local-name($this) = 'refsection'">
                <xsl:value-of select="'subsection'" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'section'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
            <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="context" select="$this" />
              <xsl:with-param name="object" select="." />
            </xsl:call-template>
          </xsl:attribute>
            <xsl:attribute name="title">
            <xsl:apply-templates select="."
              mode="object.title.markup.textonly" />
          </xsl:attribute>
          </link>
        </xsl:for-each>

        <xsl:for-each select="sect2|sect3|sect4|sect5|refsect2|refsect3">
          <link rel="subsection">
            <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="context" select="$this" />
              <xsl:with-param name="object" select="." />
            </xsl:call-template>
          </xsl:attribute>
            <xsl:attribute name="title">
            <xsl:apply-templates select="."
              mode="object.title.markup.textonly" />
          </xsl:attribute>
          </link>
        </xsl:for-each>
      </xsl:if>

      <link rel="stylesheet" href="/purplekarrot.css" type="text/css" />
      <script src="/purplekarrot.js" type="text/javascript">/**/</script>
    </head>
  </xsl:template>

</xsl:stylesheet>
