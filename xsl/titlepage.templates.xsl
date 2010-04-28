<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="article.titlepage">
    <xsl:choose>
      <xsl:when test="articleinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="articleinfo/title" />
      </xsl:when>
      <xsl:when test="artheader/title">
        <xsl:apply-templates mode="titlepage.mode" select="artheader/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="articleinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="articleinfo/subtitle" />
      </xsl:when>
      <xsl:when test="artheader/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="artheader/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="articleinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="artheader/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="set.titlepage">
    <xsl:choose>
      <xsl:when test="setinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="setinfo/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="setinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="setinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="setinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="book.titlepage">
    <xsl:choose>
      <xsl:when test="bookinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="bookinfo/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="bookinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="bookinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="bookinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="part.titlepage">
    <div xsl:use-attribute-sets="part.titlepage.recto.style">
      <xsl:call-template name="division.title">
        <xsl:with-param name="node" select="ancestor-or-self::part[1]" />
      </xsl:call-template>
    </div>
    <xsl:choose>
      <xsl:when test="partinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="partinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="partinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="partintro.titlepage">
    <xsl:choose>
      <xsl:when test="partintroinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/title" />
      </xsl:when>
      <xsl:when test="docinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="partintroinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="partintroinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="reference.titlepage">
    <xsl:choose>
      <xsl:when test="referenceinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/title" />
      </xsl:when>
      <xsl:when test="docinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="referenceinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="referenceinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="refentry.titlepage" />

  <xsl:template name="dedication.titlepage">
    <div xsl:use-attribute-sets="dedication.titlepage.recto.style">
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::dedication[1]" />
      </xsl:call-template>
    </div>
    <xsl:choose>
      <xsl:when test="dedicationinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="dedicationinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="acknowledgements.titlepage">
    <div xsl:use-attribute-sets="acknowledgements.titlepage.recto.style">
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::acknowledgements[1]" />
      </xsl:call-template>
    </div>
    <xsl:choose>
      <xsl:when test="acknowledgementsinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="acknowledgementsinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="preface.titlepage">
    <xsl:choose>
      <xsl:when test="prefaceinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/title" />
      </xsl:when>
      <xsl:when test="docinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="prefaceinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="prefaceinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="chapter.titlepage">
    <xsl:choose>
      <xsl:when test="chapterinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/title" />
      </xsl:when>
      <xsl:when test="docinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="chapterinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="chapterinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="appendix.titlepage">
    <xsl:choose>
      <xsl:when test="appendixinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/title" />
      </xsl:when>
      <xsl:when test="docinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="appendixinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="appendixinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="section.titlepage">
    <xsl:choose>
      <xsl:when test="sectioninfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="sectioninfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="sectioninfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="sect1.titlepage">
    <xsl:choose>
      <xsl:when test="sect1info/title">
        <xsl:apply-templates mode="titlepage.mode" select="sect1info/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="sect1info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="sect1info/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="sect1info/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="sect2.titlepage">
    <xsl:choose>
      <xsl:when test="sect2info/title">
        <xsl:apply-templates mode="titlepage.mode" select="sect2info/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="sect2info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="sect2info/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="sect2info/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="sect3.titlepage">
    <xsl:choose>
      <xsl:when test="sect3info/title">
        <xsl:apply-templates mode="titlepage.mode" select="sect3info/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="sect3info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="sect3info/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="sect3info/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="sect4.titlepage">
    <xsl:choose>
      <xsl:when test="sect4info/title">
        <xsl:apply-templates mode="titlepage.mode" select="sect4info/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="sect4info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="sect4info/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="sect4info/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="sect5.titlepage">
    <xsl:choose>
      <xsl:when test="sect5info/title">
        <xsl:apply-templates mode="titlepage.mode" select="sect5info/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="sect5info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="sect5info/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="sect5info/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="simplesect.titlepage">
    <xsl:choose>
      <xsl:when test="simplesectinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/title" />
      </xsl:when>
      <xsl:when test="docinfo/title">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/title" />
      </xsl:when>
      <xsl:when test="info/title">
        <xsl:apply-templates mode="titlepage.mode" select="info/title" />
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates mode="titlepage.mode" select="title" />
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="simplesectinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="info/corpauthor" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="info/authorgroup" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/author" />
    <xsl:apply-templates mode="titlepage.mode" select="info/author" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="info/othercredit" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="info/releaseinfo" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="info/copyright" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="info/legalnotice" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="info/pubdate" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revision" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="info/revhistory" />
    <xsl:apply-templates mode="titlepage.mode" select="simplesectinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="docinfo/abstract" />
    <xsl:apply-templates mode="titlepage.mode" select="info/abstract" />
  </xsl:template>

  <xsl:template name="bibliography.titlepage">
    <div xsl:use-attribute-sets="bibliography.titlepage.recto.style">
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::bibliography[1]" />
      </xsl:call-template>
    </div>
    <xsl:choose>
      <xsl:when test="bibliographyinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="bibliographyinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="glossary.titlepage">
    <div xsl:use-attribute-sets="glossary.titlepage.recto.style">
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::glossary[1]" />
      </xsl:call-template>
    </div>
    <xsl:choose>
      <xsl:when test="glossaryinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="glossaryinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="index.titlepage">
    <div xsl:use-attribute-sets="index.titlepage.recto.style">
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::index[1]" />
      </xsl:call-template>
    </div>
    <xsl:choose>
      <xsl:when test="indexinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="indexinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="setindex.titlepage">
    <div>
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::setindex[1]" />
      </xsl:call-template>
    </div>
    <xsl:choose>
      <xsl:when test="setindexinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="setindexinfo/subtitle" />
      </xsl:when>
      <xsl:when test="docinfo/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="docinfo/subtitle" />
      </xsl:when>
      <xsl:when test="info/subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="info/subtitle" />
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates mode="titlepage.mode" select="subtitle" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
