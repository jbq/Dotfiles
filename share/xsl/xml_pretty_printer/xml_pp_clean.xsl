<?xml version="1.0" encoding="iso-8859-1"?>

<!--
FILE : xml_pp_clean.xsl

CREATED : 24 December 2000

LAST MODIFIED : 6 August 2001

AUTHOR : Warren Hedley (w.hedley@auckland.ac.nz)
         Department of Engineering Science
         The University of Auckland

TERMS OF USE / COPYRIGHT : See the "Terms of Use" page on the Tools section
  of the physiome.org.nz website, at http://www.physiome.org.nz/

DESCRIPTION : This stylesheet can be used to remove all attributes in the
  XML pretty printing namespace from an XML document to produce a new XML
  document with indentation as determined by the pretty printing attributes.

CHANGES :
  02/05/2001 - WJH - moved fragments directory.
  15/06/2001 - WJH - added support for <xpp:doctype> (note that <xpp:encoding>
                     cannot be supported because the XSLT processor handles
                     the output encoding).
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xpp="http://www.physiome.org.nz/xml_pretty_printer"
    exclude-result-prefixes="xpp"
    version="1.0">


<xsl:import href="fragments/xml_pp_clean_frag.xsl" />


<xsl:output method="xml" indent="no" encoding="iso-8859-1" />


<xsl:template match="/">
  <xsl:text>&#xA;&#xA;</xsl:text>
  <xsl:if test="//xpp:doctype">
    <xsl:for-each select="(//xpp:doctype)[1]">
      <xsl:value-of select="." disable-output-escaping="yes" />
    </xsl:for-each>
    <xsl:text>&#xA;</xsl:text>
  </xsl:if>
  <xsl:call-template name="embedded_xml" />
</xsl:template>


</xsl:stylesheet>
