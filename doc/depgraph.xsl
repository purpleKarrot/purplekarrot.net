<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dg="http://www.thoughtcrime.us/ns/depgraph/1.0">
  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:variable name="start-uris" as="xs:anyURI+" select="input/uri/text ()" />
    <xsl:variable name="all-uris" as="xs:anyURI+" select="distinct-values (for $uri in $start-uris return dg:uris-from (resolve-uri ($uri), ()))" />
    <xsl:variable name="prefix" as="xs:string" select="dg:common-uri-prefix ($all-uris)" />
    <xsl:text>// URI prefix: </xsl:text>
    <xsl:value-of select="$prefix" />
    <xsl:text>&#10;</xsl:text>
    <xsl:text>digraph {&#10;</xsl:text>
    <xsl:for-each select="$all-uris">
      <xsl:text>&#9;// </xsl:text><xsl:value-of select="."/><xsl:text>&#10;</xsl:text>
      <xsl:value-of select="dg:doc-edges (., $prefix)"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    <xsl:text>}&#10;</xsl:text>
  </xsl:template>

  <xsl:function name="dg:doc-edges" as="xs:string">
    <xsl:param name="doc-uri" as="xs:anyURI" />
    <xsl:param name="prefix" as="xs:string" />
    <xsl:variable name="doc" as="document-node(element(xsl:stylesheet))">
      <xsl:call-template name="canonicalize-stylesheet">
        <xsl:with-param name="doc" select="doc ($doc-uri)" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:sequence select="string-join (('&#9;', dg:encode-string (dg:node-name ($doc-uri, $prefix)), ';&#10;',
                          for $import-uri in dg:document-imports ($doc)
                      return ('&#9;', dg:encode-string (dg:node-name ($doc-uri, $prefix)), '-&gt;',
                        dg:encode-string (dg:node-name ($import-uri, $prefix)),
            '[color=&quot;#000088&quot;];&#10;'),
                for $include-uri in dg:document-includes ($doc)
                return ('&#9;', dg:encode-string (dg:node-name ($doc-uri, $prefix)), '-&gt;',
                        dg:encode-string (dg:node-name ($include-uri, $prefix)),
            '[color=&quot;#aa0000&quot;];&#10;')),
               '')" />
  </xsl:function>

  <xsl:function name="dg:uris-from" as="xs:anyURI*">
    <xsl:param name="doc-uri" as="xs:anyURI" />
    <xsl:param name="parents" as="xs:anyURI*" />
    <xsl:if test="empty (index-of ($parents, $doc-uri))">
      <xsl:variable name="parents" as="xs:anyURI*" select="($doc-uri, $parents)" />
      <xsl:variable name="doc" as="document-node(element(xsl:stylesheet))">
        <xsl:call-template name="canonicalize-stylesheet">
          <xsl:with-param name="doc" select="doc ($doc-uri)" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="referenced-uris" as="xs:anyURI*" select="(dg:document-includes ($doc), dg:document-imports ($doc))" />
      <xsl:sequence select="distinct-values (($doc-uri, for $uri in $referenced-uris return dg:uris-from ($uri, $parents)))" />
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="dg:document-includes" as="xs:anyURI*">
    <xsl:param name="doc" as="document-node(element(xsl:stylesheet))"/>
    <xsl:for-each select="$doc/xsl:stylesheet/xsl:include">
      <xsl:sequence select="resolve-uri (@href, base-uri (.))"/>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="dg:document-imports" as="xs:anyURI*">
    <xsl:param name="doc" as="document-node(element(xsl:stylesheet))"/>
    <xsl:for-each select="$doc/xsl:stylesheet/xsl:import">
      <xsl:sequence select="resolve-uri (@href, base-uri (.))"/>
    </xsl:for-each>
  </xsl:function>
  
  <!-- Encodes $input as a string in the DOT language. -->
  <xsl:function name="dg:encode-string" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:value-of select="concat ('&quot;', replace ($input, '&quot;', '\\&quot;'), '&quot;')"/>
  </xsl:function>
  
  <!-- Given the URI to a document ($doc-uri) and the common $prefix
       of all URIs we're dealing with, returns a good node name for
       the document. -->
  <xsl:function name="dg:node-name" as="xs:string">
    <xsl:param name="doc-uri" as="xs:anyURI"/>
    <xsl:param name="prefix" as="xs:string"/>
    <xsl:value-of select="substring ($doc-uri, string-length ($prefix) + 1)"/>
  </xsl:function>
  
  <!-- Returns the common prefix of $uri, only considering splitting at slashes. -->
  <xsl:function name="dg:common-uri-prefix" as="xs:string">
    <xsl:param name="uris" as="xs:anyURI+"/>
    <xsl:value-of select="replace (dg:common-prefix ($uris), '[^/]+$', '')"/>
  </xsl:function>

  <!-- Returns the common prefix of $strings. -->
  <xsl:function name="dg:common-prefix" as="xs:string">
    <xsl:param name="strings" as="xs:string+"/>
    <xsl:variable name="prefix-length" as="xs:integer" select="dg:common-prefix-length-search ($strings, 0, string-length ($strings[1]))"/>
    <xsl:value-of select="substring ($strings[1], 1, $prefix-length)"/>
  </xsl:function>
  
  <!-- Returns the length of the longest common prefix to $strings whose length is bounded by [$min,$max]. -->
  <xsl:function name="dg:common-prefix-length-search" as="xs:integer">
    <xsl:param name="strings" as="xs:string+"/>
    <xsl:param name="min" as="xs:integer"/>
    <xsl:param name="max" as="xs:integer"/>
    <xsl:variable name="pivot" as="xs:integer" select="xs:integer (avg (($min, $max)))"/>
    <xsl:variable name="correct" as="xs:boolean" select="dg:is-common-prefix-length ($strings, $pivot) and not (dg:is-common-prefix-length ($strings, $pivot + 1))"/>
    <xsl:sequence select="if ($correct) then $pivot
        else if (dg:is-common-prefix-length ($strings, $pivot))
        then dg:common-prefix-length-search ($strings, $pivot, $max) else dg:common-prefix-length-search ($strings, $min, $pivot)"/>
  </xsl:function>

  <!-- Returns whether $length denotes a common prefix among all $strings. -->
  <xsl:function name="dg:is-common-prefix-length" as="xs:boolean">
    <xsl:param name="strings" as="xs:string+" />
    <xsl:param name="length" as="xs:integer" />
    <xsl:variable name="prefix" as="xs:string" select="substring ($strings[1], 1, $length)" />
    <xsl:sequence select="(string-length ($prefix) = $length) and (every $string in $strings satisfies starts-with ($string, $prefix))" />
  </xsl:function>

  <!-- Derived from http://www.w3.org/TR/xslt20/#simplified-stylesheet -->
  <xsl:template name="expand-simplified" as="document-node(element(xsl:stylesheet))">
    <xsl:param name="doc" as="document-node()" required="yes" />
    <xsl:document>
      <xsl:element name="xsl:stylesheet">
        <xsl:attribute name="version" select="$doc/element()/@xsl:version" />
        <xsl:element name="xsl:template">
          <xsl:attribute name="match">/</xsl:attribute>
          <xsl:copy-of select="$doc/." />
        </xsl:element>
      </xsl:element>
    </xsl:document>
  </xsl:template>

  <xsl:template name="canonicalize-stylesheet" as="document-node(element(xsl:stylesheet))">
    <xsl:param name="doc" as="document-node()" required="yes" />
    <xsl:choose>
      <xsl:when test="$doc/xsl:stylesheet">
        <xsl:sequence select="$doc" />
      </xsl:when>
      <xsl:when test="$doc/xsl:transform">
        <xsl:document>
          <xsl:element name="xsl:stylesheet">
            <xsl:copy-of select="$doc/xsl:transform/node ()" />
          </xsl:element>
        </xsl:document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="expand-simplified">
          <xsl:with-param name="doc" select="$doc" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
