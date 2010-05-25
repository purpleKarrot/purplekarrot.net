<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="copyright.years">
    <xsl:param name="years" />
    <xsl:param name="firstyear" select="0" />
    <xsl:param name="nextyear" select="0" />

    <xsl:choose>
      <xsl:when test="count($years) = 0">
        <xsl:variable name="lastyear" select="$nextyear - 1" />
        <xsl:choose>
          <xsl:when test="$firstyear = 0">
            <!-- there weren't any years at all -->
          </xsl:when>
          <!-- Just output a year with range in its text -->
          <xsl:when test="contains($firstyear, '-') or contains($firstyear, ',')">
            <xsl:value-of select="$firstyear" />
          </xsl:when>
          <xsl:when test="$firstyear = $lastyear">
            <xsl:value-of select="$firstyear" />
          </xsl:when>
          <xsl:when test="$lastyear = $firstyear + 1">
            <xsl:value-of select="$firstyear" />
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$lastyear" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$firstyear" />
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$lastyear" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains($firstyear, '-') or contains($firstyear, ',')">
        <!-- Just output a year with range in its text -->
        <xsl:value-of select="$firstyear" />
        <xsl:if test="count($years) != 0">
          <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:call-template name="copyright.years">
          <xsl:with-param name="years" select="$years[position() &gt; 1]" />
          <xsl:with-param name="firstyear" select="$years[1]" />
          <xsl:with-param name="nextyear" select="$years[1] + 1" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$firstyear = 0">
        <xsl:call-template name="copyright.years">
          <xsl:with-param name="years" select="$years[position() &gt; 1]" />
          <xsl:with-param name="firstyear" select="$years[1]" />
          <xsl:with-param name="nextyear" select="$years[1] + 1" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$nextyear = $years[1]">
        <xsl:call-template name="copyright.years">
          <xsl:with-param name="years" select="$years[position() &gt; 1]" />
          <xsl:with-param name="firstyear" select="$firstyear" />
          <xsl:with-param name="nextyear" select="$nextyear + 1" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- we have years left, but they aren't in the current range -->
        <xsl:choose>
          <xsl:when test="$nextyear = $firstyear + 1">
            <xsl:value-of select="$firstyear" />
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:when test="$nextyear = $firstyear + 2">
            <xsl:value-of select="$firstyear" />
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$nextyear - 1" />
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$firstyear" />
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$nextyear - 1" />
            <xsl:text>, </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="copyright.years">
          <xsl:with-param name="years" select="$years[position() &gt; 1]" />
          <xsl:with-param name="firstyear" select="$years[1]" />
          <xsl:with-param name="nextyear" select="$years[1] + 1" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="copyright">
    <xsl:param name="node" select="." />

    <xsl:variable name="copyright" select="$node//copyright" />
    <xsl:variable name="parent" select="$node//.." />

    <xsl:choose>
      <xsl:when test="$copyright">
        <xsl:text>Copyright &#169; </xsl:text>
        <xsl:call-template name="copyright.years">
          <xsl:with-param name="years" select="$copyright/year" />
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:for-each select="$copyright/holder">
          <strong>
            <xsl:value-of select="." />
          </strong>
          <xsl:if test="position() &lt; last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$parent">
        <xsl:call-template name="copyright">
          <xsl:with-param name="node" select="$parent" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>error: no copyright info found!</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
