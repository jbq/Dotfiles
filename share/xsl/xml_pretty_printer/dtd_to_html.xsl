<?xml version="1.0" encoding="iso-8859-1"?>

<!--
FILE : dtd_to_html.xsl

CREATED : 6 August 2001

LAST MODIFIED : 6 August 2001

AUTHOR : Warren Hedley (w.hedley@auckland.ac.nz)
         Department of Engineering Science
         The University of Auckland

TERMS OF USE / COPYRIGHT : See the "Terms of Use" page on the Tools section
  of the physiome.org.nz website, at http://www.physiome.org.nz/

DESCRIPTION : This stylesheet can be used to generate standalone HTML files
  containing a formatted representation of a (pre-processed) DTD file.

CHANGES :
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

<xsl:import href="fragments/dtd_to_html_frag.xsl" />

<xsl:output method="html" indent="no" 
            doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN"
            doctype-system="/www/DTDs/html40/loose.dtd"
            encoding="iso-8859-1" />

<xsl:param name="CSS_DIRECTORY" select="'.'" />
<xsl:param name="PAGE_TITLE"    select="'Beautifully Formatted DTD!'" />

<!-- templates that other stylesheets might want to override -->
<xsl:template name="dtd_to_html_generate_stylesheet_link">
  <link type="text/css" rel="stylesheet"
      href="{$CSS_DIRECTORY}/embedded_dtd.css" />
</xsl:template>


<!--
  The main template. Builds a basic html skeleton and calls the
  "embedded_dtd" template in "fragments/dtd_to_html_frag.xsl".
  -->
<xsl:template match="/">
  <xsl:comment>
  This file was generated automatically using the DTD Pretty Printer XSLT
  stylesheet dtd_to_html.xsl.

  For more information about how this file was generated, check out the Tools
  section of the http://www.physiome.org.nz/ website.
  </xsl:comment>
  <html>
    <head>
      <title><xsl:value-of select="$PAGE_TITLE" /></title>
      <xsl:call-template name="dtd_to_html_generate_stylesheet_link" />
    </head>
    <body bgcolor="white">
      <xsl:for-each select="*">
        <xsl:call-template name="embedded_dtd" />
      </xsl:for-each>
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>


