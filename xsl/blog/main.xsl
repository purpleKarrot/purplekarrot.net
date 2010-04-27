<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common">

  <xsl:include href="summary.xsl" />
  <xsl:include href="index.xsl" />
  <xsl:include href="post.xsl" />

  <xsl:template match="*" mode="make.blog">

    <xsl:variable name="nodes">
      <xsl:for-each select="chapter">
        <xsl:sort select="@last-revision" order="descending" />
        <post>
          <xsl:attribute name="id"><xsl:value-of select="@id" /></xsl:attribute>
          <xsl:attribute name="title"><xsl:value-of select="title" /></xsl:attribute>
          <xsl:attribute name="date"><xsl:value-of select="@last-revision" /></xsl:attribute>
          <summary>
            <xsl:call-template name="blog.summary" />
          </summary>
          <content>
            <xsl:apply-templates />
          </content>
        </post>
      </xsl:for-each>
    </xsl:variable>

    <xsl:call-template name="blog.index">
      <xsl:with-param name="nodes" select="exsl:node-set($nodes)//post[position() &lt;= 10]" />
    </xsl:call-template>

    <xsl:for-each select="exsl:node-set($nodes)//post">
      <xsl:call-template name="blog.post" />
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>
