<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="header.navigation">
  <xsl:param name="prev" select="/foo" />
  <xsl:param name="next" select="/foo" />
  <xsl:param name="nav.context" />

  <xsl:variable name="home" select="/*[1]" />
  <xsl:variable name="up" select="parent::*" />

  <div class="navigation1">
    <!-- prev -->
    <xsl:if test="count($prev)>0">
      <a class="prev">
        <xsl:attribute name="title">
          <xsl:apply-templates select="$prev" mode="object.title.markup"/>
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$prev" />
          </xsl:call-template>
        </xsl:attribute>
        <xsl:text>Prev</xsl:text>
      </a>
    </xsl:if>
    <!-- up -->
    <xsl:if test="count($up)>0">
      <a class="up">
        <xsl:attribute name="title">
          <xsl:apply-templates select="$up" mode="object.title.markup"/>
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$up" />
          </xsl:call-template>
        </xsl:attribute>
        <xsl:text>Up</xsl:text>
      </a>
    </xsl:if>
    <!-- home -->
    <xsl:if test="$home != . or $nav.context = 'toc'">
      <a class="home">
        <xsl:attribute name="title">
          <xsl:apply-templates select="$home" mode="object.title.markup"/>
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$home" />
          </xsl:call-template>
        </xsl:attribute>
        <xsl:text>Home</xsl:text>
      </a>
    </xsl:if>
    <!-- next -->
    <xsl:if test="count($next)>0">
      <a class="next">
        <xsl:attribute name="title">
          <xsl:apply-templates select="$next" mode="object.title.markup"/>
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$next" />
          </xsl:call-template>
        </xsl:attribute>
        <xsl:text>Next</xsl:text>
      </a>
    </xsl:if>
  </div>
</xsl:template>

</xsl:stylesheet>
