<?xml version="1.0" encoding="iso-8859-1"?>

<!--
FILE : text_utils_frag.xsl

CREATED : 22 March 2001

LAST MODIFIED : 24 April 2001

AUTHOR : Warren Hedley (w.hedley@auckland.ac.nz)
         Department of Engineering Science
         The University of Auckland

TERMS OF USE / COPYRIGHT : See the "Terms of Use" page on the Tools section
  of the physiome.org.nz website, at http://www.physiome.org.nz/

DESCRIPTION : This stylesheet contains some basic text processing methods
  written using pure XSLT.

CHANGES :
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<!--============================================================================
NAMED TEMPLATE : text_utils_strip_leading_whitespace

DESCRIPTION : 
=============================================================================-->
<xsl:template name="text_utils_strip_leading_whitespace">
  <xsl:param name="text" />

  <xsl:if test="$text != ''">
    <xsl:variable name="first_char" select="substring($text, 1, 1)" />
    <xsl:choose>
      <xsl:when test="$first_char = '&#x20;' or $first_char = '&#x09;' or
          $first_char = '&#x0D;' or $first_char = '&#x0A;'">
        <xsl:call-template name="text_utils_strip_leading_whitespace">
          <xsl:with-param name="text" select="substring($text, 2)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : text_utils_strip_trailing_whitespace

DESCRIPTION : NOT FINISHED YET
=============================================================================-->
<xsl:template name="text_utils_strip_trailing_whitespace">
  <xsl:param name="text" />

  <xsl:if test="$text != ''">
    <xsl:variable name="first_char" select="substring($text, 1, 1)" />
    <xsl:choose>
      <xsl:when test="$first_char = '&#x20;' or $first_char = '&#x09;' or
          $first_char = '&#x0D;' or $first_char = '&#x0A;'">
        <xsl:call-template name="text_utils_strip_trailing_whitespace">
          <xsl:with-param name="text" select="substring($text, 2)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>


<xsl:template name="text_utils_count_character_x_in_string">
  <xsl:param name="text" />
  <xsl:param name="character" />
  <xsl:param name="num_instances" select="0" />

  <xsl:choose>
    <xsl:when test="string($text) and contains($text, $character)">
      <xsl:call-template name="text_utils_count_character_x_in_string">
        <xsl:with-param name="text"
            select="substring-after($text, $character)" />
        <xsl:with-param name="character" select="$character" />
        <xsl:with-param name="num_instances" select="$num_instances + 1" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$num_instances" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
