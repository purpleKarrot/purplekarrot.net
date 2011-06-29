<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="templates/unmatched.xsl" />
  <xsl:import href="templates/admonition.xsl" />
  <xsl:import href="templates/text_level.xsl" />
  <xsl:import href="templates/footnote.xsl" />
  <xsl:import href="templates/refentry.xsl" />
  <xsl:import href="templates/lists.xsl" />

  <xsl:output method="xml" encoding="UTF-8" indent="yes"
    omit-xml-declaration="yes" />

  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;&#10;</xsl:text>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <!-- <xsl:call-template name="head.content" /> -->
      </head>
      <body>
        <xsl:apply-templates />
      </body>
    </html>
  </xsl:template>

  <xsl:template match="chapter">
    <article>
      <xsl:apply-templates />
    </article>
  </xsl:template>

  <xsl:template match="section">
    <section>
      <xsl:apply-templates />
    </section>
  </xsl:template>

  <xsl:template match="para|simpara">
    <p>
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="phrase">
    <span>
      <xsl:attribute name="class"><xsl:value-of select="@role" /></xsl:attribute>
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="programlisting|synopsis">
    <pre>
      <xsl:apply-templates />
    </pre>
  </xsl:template>

  <xsl:template match="title">
    <h2>
      <xsl:apply-templates />
    </h2>
  </xsl:template>

  <xsl:template match="link|anchor">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="informalfigure">
    <figure>
      <xsl:apply-templates />
    </figure>
  </xsl:template>

  <xsl:template match="mediaobject">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="caption">
    <figcaption>
      <xsl:apply-templates />
    </figcaption>
  </xsl:template>

  <xsl:template match="imageobject">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="imagedata">
    <img>
      <xsl:attribute name="src">
        <xsl:text>s_</xsl:text>
        <xsl:value-of select="@fileref" />
      </xsl:attribute>
    </img>
  </xsl:template>

  <xsl:template match="table|informaltable">
    <table>
      <xsl:apply-templates />
    </table>
  </xsl:template>

  <xsl:template match="tgroup">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="thead">
    <thead>
      <xsl:apply-templates />
    </thead>
  </xsl:template>

  <xsl:template match="tbody">
    <tbody>
      <xsl:apply-templates />
    </tbody>
  </xsl:template>

  <xsl:template match="row">
    <tr>
      <xsl:apply-templates />
    </tr>
  </xsl:template>

  <xsl:template match="entry">
    <td>
      <xsl:apply-templates />
    </td>
  </xsl:template>

</xsl:stylesheet>
