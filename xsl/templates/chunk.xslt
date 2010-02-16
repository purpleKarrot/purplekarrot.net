<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="chunk.section.depth" select="1"/>
<xsl:param name="chunk.first.sections" select="0"/>

<!-- returns 1 if $node is a chunk -->
<xsl:template name="chunk">
  <xsl:param name="node" select="."/>

  <!-- ==================================================================== -->
  <!-- What's a chunk?

       The root element
       appendix
       article
       bibliography  in article or part or book
       book
       chapter
       colophon
       glossary      in article or part or book
       index         in article or part or book
       part
       preface
       refentry
       reference
       sect{1,2,3,4,5}  if position()>1 && depth < chunk.section.depth
       section          if position()>1 && depth < chunk.section.depth
       set
       setindex
                                                                            -->
  <!-- ==================================================================== -->

   <xsl:choose>
	  <xsl:when test="$node/parent::*/processing-instruction('dbhtml')[normalize-space(.) = 'stop-chunking']">0</xsl:when>
    <xsl:when test="not($node/parent::*)">1</xsl:when>

    <xsl:when test="local-name($node) = 'sect1' and $chunk.section.depth >= 1 and ($chunk.first.sections != 0 or count($node/preceding-sibling::sect1) > 0)">
      <xsl:text>1</xsl:text>
    </xsl:when>
    <xsl:when test="local-name($node) = 'sect2' and $chunk.section.depth >= 2 and ($chunk.first.sections != 0 or count($node/preceding-sibling::sect2) > 0)">
      <xsl:call-template name="chunk">
        <xsl:with-param name="node" select="$node/parent::*"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="local-name($node) = 'sect3' and $chunk.section.depth >= 3 and ($chunk.first.sections != 0 or count($node/preceding-sibling::sect3) > 0)">
      <xsl:call-template name="chunk">
        <xsl:with-param name="node" select="$node/parent::*"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="local-name($node) = 'sect4' and $chunk.section.depth >= 4 and ($chunk.first.sections != 0 or count($node/preceding-sibling::sect4) > 0)">
      <xsl:call-template name="chunk">
        <xsl:with-param name="node" select="$node/parent::*"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="local-name($node) = 'sect5' and $chunk.section.depth >= 5 and ($chunk.first.sections != 0 or count($node/preceding-sibling::sect5) > 0)">
      <xsl:call-template name="chunk">
        <xsl:with-param name="node" select="$node/parent::*"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="local-name($node) = 'section' and $chunk.section.depth >= count($node/ancestor::section)+1 and ($chunk.first.sections != 0 or count($node/preceding-sibling::section) > 0)">
      <xsl:call-template name="chunk">
        <xsl:with-param name="node" select="$node/parent::*"/>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="local-name($node)='preface'">1</xsl:when>
    <xsl:when test="local-name($node)='chapter'">1</xsl:when>
    <xsl:when test="local-name($node)='appendix'">1</xsl:when>
    <xsl:when test="local-name($node)='article'">1</xsl:when>
    <xsl:when test="local-name($node)='part'">1</xsl:when>
    <xsl:when test="local-name($node)='reference'">1</xsl:when>
    <xsl:when test="local-name($node)='refentry'">1</xsl:when>
    <xsl:when test="local-name($node)='index' and ($generate.index != 0 or count($node/*) > 0) and (local-name($node/parent::*) = 'article'  or local-name($node/parent::*) = 'book' or local-name($node/parent::*) = 'part')">1</xsl:when>
    <xsl:when test="local-name($node)='bibliography' and (local-name($node/parent::*) = 'article' or local-name($node/parent::*) = 'book' or local-name($node/parent::*) = 'part')">1</xsl:when>
    <xsl:when test="local-name($node)='glossary' and (local-name($node/parent::*) = 'article' or local-name($node/parent::*) = 'book'or local-name($node/parent::*) = 'part')">1</xsl:when>
    <xsl:when test="local-name($node)='colophon'">1</xsl:when>
    <xsl:when test="local-name($node)='book'">1</xsl:when>
    <xsl:when test="local-name($node)='set'">1</xsl:when>
    <xsl:when test="local-name($node)='setindex'">1</xsl:when>
    <xsl:when test="local-name($node)='legalnotice' and $generate.legalnotice.link != 0">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="make-relative-filename">
  <xsl:param name="base.dir" select="'./'" />
  <xsl:param name="base.name" select="''" />
  <xsl:choose>
    <xsl:when test="count(parent::*) = 0">
      <xsl:value-of select="concat($base.dir,$base.name)" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$base.name" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- returns the filename of a chunk -->
<xsl:template match="*" mode="chunk-filename">
  <xsl:apply-templates select="." mode="recursive-chunk-filename"/>
</xsl:template>

<xsl:template match="*" mode="recursive-chunk-filename">
  <xsl:param name="recursive" select="false()"/>

  <!-- returns the filename of a chunk -->
  <xsl:variable name="ischunk">
    <xsl:call-template name="chunk"/>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="not(parent::*)">
        <xsl:text>index.html</xsl:text>
      </xsl:when>
      <!-- if there's no dbhtml filename, and if we're to use IDs as -->
      <!-- filenames, then use the ID to generate the filename. -->
      <xsl:when test="(@id or @xml:id)">
        <xsl:value-of select="(@id|@xml:id)[1]"/>
        <xsl:text>.html</xsl:text>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$ischunk='0'">
      <!-- if called on something that isn't a chunk, walk up... -->
      <xsl:choose>
        <xsl:when test="count(parent::*) > 0">
          <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
            <xsl:with-param name="recursive" select="$recursive"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- unless there is no up, in which case return "" -->
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="not($recursive) and $filename != ''">
      <!-- if this chunk has an explicit name, use it -->
      <xsl:if test="parent::part">
        <xsl:value-of select="parent::part/@id" />
        <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:value-of select="$filename" />
    </xsl:when>

    <xsl:otherwise>
      <xsl:text>chunk-filename-error-</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:number level="any" format="01" from="set"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
