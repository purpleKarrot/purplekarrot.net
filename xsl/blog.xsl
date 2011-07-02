<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:import href="../xsl-html5/common.xsl" />

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

  <xsl:variable name="blog">
    <xsl:for-each select="/part/chapter">
      <xsl:sort select="@last-revision|chapterinfo/date" order="descending" />
      <post>
        <xsl:attribute name="id">
          <xsl:call-template name="blog.post.id" />
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="title|chapterinfo/title" />
        </xsl:attribute>
        <xsl:attribute name="date">
          <xsl:value-of select="@last-revision|chapterinfo/date" />
        </xsl:attribute>
        <summary>
          <xsl:apply-templates select="(para|simpara)[1]" />
        </summary>
        <content>
          <xsl:apply-templates />
        </content>
      </post>
    </xsl:for-each>
  </xsl:variable>

  <!-- <xsl:call-template name="blog.index"> <xsl:with-param name="nodes" select="exsl:node-set($blog)//post[10 
    >= position()]" /> </xsl:call-template> -->

  <xsl:template match="/">
    <xsl:for-each select="exsl:node-set($blog)/post">
      <exsl:document href="blog/{@id}.html" method="xml" indent="yes"
        omit-xml-declaration="yes">
        <xsl:text disable-output-escaping='yes'>&lt;!doctype html&gt;&#10;</xsl:text>
        <html>
          <head>
            <meta http-equiv="content-type" content="text/html; charset=utf-8" />
          </head>
          <body>
            <div id="wrap">
<!--               <xsl:call-template name="purple.header" />
 -->              <div id="content-wrap">
                <div id="content">
<!--                   <xsl:call-template name="blog.navigation">
                    <xsl:with-param name="class"><xsl:text>navigation1</xsl:text></xsl:with-param>
                    <xsl:with-param name="prev" select="following-sibling::*[1]" />
                    <xsl:with-param name="next" select="preceding-sibling::*[1]" />
                  </xsl:call-template>
                  <h1><xsl:value-of select="@title" /></h1>
 -->
                  <xsl:copy-of select="content/*" />

<!--                   <xsl:call-template name="blog.navigation">
                    <xsl:with-param name="class"><xsl:text>navigation2</xsl:text></xsl:with-param>
                    <xsl:with-param name="prev" select="following-sibling::*[1]" />
                    <xsl:with-param name="next" select="preceding-sibling::*[1]" />
                  </xsl:call-template>
 -->                  
                </div>
              </div>
<!--               <xsl:call-template name="disqus.thread" />
              <xsl:call-template name="purple.footer" />
 -->            </div>
          </body>
        </html>
      </exsl:document>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
