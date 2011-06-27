<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="blog.date">
    <xsl:param name="text" />

    <!-- Grab the year -->
    <xsl:variable name="year" select="substring-before($text, '-')" />
    <xsl:variable name="text.noyear" select="substring-after($text, '-')" />

    <!-- Grab the month -->
    <xsl:variable name="month" select="substring-before($text.noyear, '-')" />
    <xsl:variable name="text.nomonth" select="substring-after($text.noyear, '-')" />

    <!-- Grab the day -->
    <xsl:variable name="day" select="substring-before($text.nomonth, ' ')" />

    <xsl:variable name="month.name">
      <xsl:choose>
        <xsl:when test="$month=1">Jan</xsl:when>
        <xsl:when test="$month=2">Feb</xsl:when>
        <xsl:when test="$month=3">Mar</xsl:when>
        <xsl:when test="$month=4">Apr</xsl:when>
        <xsl:when test="$month=5">May</xsl:when>
        <xsl:when test="$month=6">Jun</xsl:when>
        <xsl:when test="$month=7">Jul</xsl:when>
        <xsl:when test="$month=8">Aug</xsl:when>
        <xsl:when test="$month=9">Sep</xsl:when>
        <xsl:when test="$month=10">Oct</xsl:when>
        <xsl:when test="$month=11">Nov</xsl:when>
        <xsl:when test="$month=12">Dec</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat($month.name, ' ', $day, ', ', $year)" />
  </xsl:template>

  <xsl:template name="blog.post.id">
    <xsl:choose>
      <xsl:when test="@id">
        <xsl:value-of select="@id" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="ok" select="'__abcdefghijklmnopqrstuvwxyz'" />
        <xsl:variable name="no" select="' .ABCDEFGHIJKLMNOPQRSTUVWXYZ()'" />
        <xsl:variable name="title" select="title|chapterinfo/title" />
        <xsl:value-of select="translate($title, $no, $ok)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>