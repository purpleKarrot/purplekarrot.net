<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:import href="../xsl-html5/common.xsl" />
  <xsl:include href="impl/header.xsl" />
  <xsl:include href="impl/footer.xsl" />
  <xsl:include href="impl/disqus.xsl" />
  <xsl:include href="impl/sidebar.xsl" />

  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

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

  <xsl:template name="blog.navigation">
    <xsl:param name="class" select="navigation2" />
    <xsl:param name="prev" />
    <xsl:param name="next" />
    <div>
      <xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute>
      <!-- prev -->
      <xsl:if test="count($prev) > 0">
        <a class="prev">
          <xsl:attribute name="title"><xsl:value-of select="$prev/@title" /></xsl:attribute>
          <xsl:attribute name="href"><xsl:value-of select="$prev/@id" />.html</xsl:attribute>
          <xsl:value-of select="$prev/@title" />
        </a>
      </xsl:if>
      <!-- next -->
      <xsl:if test="count($next) > 0">
        <a class="next">
          <xsl:attribute name="title"><xsl:value-of select="$next/@title" /></xsl:attribute>
          <xsl:attribute name="href"><xsl:value-of select="$next/@id" />.html</xsl:attribute>
          <xsl:value-of select="$next/@title" />
        </a>
      </xsl:if>
    </div>
  </xsl:template>

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
        <xsl:when test="$month=1">
          Jan
        </xsl:when>
        <xsl:when test="$month=2">
          Feb
        </xsl:when>
        <xsl:when test="$month=3">
          Mar
        </xsl:when>
        <xsl:when test="$month=4">
          Apr
        </xsl:when>
        <xsl:when test="$month=5">
          May
        </xsl:when>
        <xsl:when test="$month=6">
          Jun
        </xsl:when>
        <xsl:when test="$month=7">
          Jul
        </xsl:when>
        <xsl:when test="$month=8">
          Aug
        </xsl:when>
        <xsl:when test="$month=9">
          Sep
        </xsl:when>
        <xsl:when test="$month=10">
          Oct
        </xsl:when>
        <xsl:when test="$month=11">
          Nov
        </xsl:when>
        <xsl:when test="$month=12">
          Dec
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat($month.name, ' ', $day, ', ', $year)" />
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

  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!doctype html&gt;&#10;</xsl:text>
    <html lang="en">
      <head>
        <title>
          <xsl:text>purpleKarrot</xsl:text>
        </title>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <link rel="shortcut icon" href="/favicon.png" />
        <link rel="stylesheet" href="/purplekarrot.css" type="text/css" />
        <script src="/purplekarrot.js" type="text/javascript">/**/</script>
      </head>
      <body>
        <div id="wrap">
          <xsl:call-template name="purple.header" />
          <div id="content-wrap">
            <div id="content">
              <div id="main">

                <xsl:for-each select="exsl:node-set($blog)//post[10 >= position()]">

                  <xsl:variable name="link">
                    <xsl:text>blog/</xsl:text>
                    <xsl:value-of select="@id" />
                    <xsl:text>.html</xsl:text>
                  </xsl:variable>

                  <xsl:variable name="commentslink">
                    <xsl:text>blog/</xsl:text>
                    <xsl:value-of select="@id" />
                    <xsl:text>.html#disqus_thread</xsl:text>
                  </xsl:variable>

                  <article>
                    <h1>
                      <xsl:value-of select="@title" />
                    </h1>

                    <xsl:copy-of select="summary/*" />

                    <p class="post-footer align-right">
                      <a href="{$link}" class="readmore">Read more</a>
                      <a href="{$commentslink}" class="comments">Comments</a>
                      <span class="date">
                        <xsl:call-template name="blog.date">
                          <xsl:with-param name="text" select="@date" />
                        </xsl:call-template>
                      </span>
                    </p>

                  </article>
                </xsl:for-each>

              </div>
              <xsl:call-template name="purple.sidebar" />
            </div>
          </div>
          <xsl:call-template name="purple.footer" />
        </div>
        <xsl:call-template name="disqus.script" />
      </body>
    </html>

    <xsl:for-each select="exsl:node-set($blog)/post">
      <exsl:document href="blog/{@id}.html" method="xml" indent="yes"
        omit-xml-declaration="yes">
        <xsl:text disable-output-escaping='yes'>&lt;!doctype html&gt;&#10;</xsl:text>
        <html>
          <head>
            <meta http-equiv="content-type" content="text/html; charset=utf-8" />
            <link rel="shortcut icon" href="/favicon.png" />
            <link rel="stylesheet" href="/purplekarrot.css" type="text/css" />
            <script src="/purplekarrot.js" type="text/javascript">/**/</script>
          </head>
          <body>
            <div id="wrap">
              <xsl:call-template name="purple.header" />
              <div id="content-wrap">
                <div id="content">
                  <xsl:call-template name="blog.navigation">
                    <xsl:with-param name="class">
                      <xsl:text>navigation1</xsl:text>
                    </xsl:with-param>
                    <xsl:with-param name="prev" select="following-sibling::*[1]" />
                    <xsl:with-param name="next" select="preceding-sibling::*[1]" />
                  </xsl:call-template>
                  <h1>
                    <xsl:value-of select="@title" />
                  </h1>
                  <xsl:copy-of select="content/*" />

                  <xsl:call-template name="blog.navigation">
                    <xsl:with-param name="class">
                      <xsl:text>navigation2</xsl:text>
                    </xsl:with-param>
                    <xsl:with-param name="prev" select="following-sibling::*[1]" />
                    <xsl:with-param name="next" select="preceding-sibling::*[1]" />
                  </xsl:call-template>
                </div>
              </div>
              <xsl:call-template name="disqus.thread" />
              <xsl:call-template name="purple.footer" />
            </div>
          </body>
        </html>
      </exsl:document>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
