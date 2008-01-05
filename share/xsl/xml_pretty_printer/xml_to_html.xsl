<?xml version="1.0" encoding="iso-8859-1"?>

<!--
FILE : xml_to_html.xsl

CREATED : 27 March 2000

LAST MODIFIED : 15 June 2001

AUTHOR : Warren Hedley (w.hedley@auckland.ac.nz)
         Department of Engineering Science
         The University of Auckland

TERMS OF USE / COPYRIGHT : See the "Terms of Use" page on the Tools section
  of the physiome.org.nz website, at http://www.physiome.org.nz/

DESCRIPTION : This stylesheet can be used to generate standalone HTML files
  containing a formatted representation of the input XML file. It uses the
  "xml_to_html_frag.xsl" stylesheet fragment to do the formatting and the
  output HTML requires the "embedded_xml.css" CSS stylesheet to be placed
  into the same directory. A "CSS_DIRECTORY" parameter may be used to
  specify an alternative directory for this stylesheet.

CHANGES :
  02/05/2001 - WJH - moved fragments directory.
  19/05/2001 - WJH - added PAGE_TITLE parameter.
  15/06/2001 - WJH - added xpp namespace declaration. Add link to embedded
                     DTD stylesheet if the input document contains a
                     <xpp:doctype> element.
  15/06/2001 - WJH - added xml_to_html_generate_stylesheet_links template to
                     reduce the maintenance problems with other copies of this
                     stylesheet.
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xpp="http://www.physiome.org.nz/xml_pretty_printer"
    exclude-result-prefixes="xpp"
    version="1.0">

<!-- possible debugging options
                xmlns:saxon="http://icl.com/saxon"
                saxon:trace="yes">
-->

<xsl:import href="fragments/xml_to_html_frag.xsl" />
<xsl:import href="fragments/dtd_to_html_frag.xsl" />

<xsl:output method="html" indent="no" 
            doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN"
            doctype-system="/www/DTDs/html40/loose.dtd"
            encoding="iso-8859-1" />

<xsl:param name="CSS_DIRECTORY" select="'.'" />
<xsl:param name="PAGE_TITLE"    select="'Beautifully Formatted XML!'" />

<!-- templates that other stylesheets might want to override -->
<xsl:template name="xml_to_html_generate_stylesheet_links">
  <link type="text/css" rel="stylesheet"
      href="{$CSS_DIRECTORY}/embedded_xml.css" />
  <link type="text/css" rel="stylesheet"
      href="{$CSS_DIRECTORY}/embedded_dtd.css" />
</xsl:template>


<!--
  The main template. Builds a basic html Skeleton and calls the
  "embedded_xml" template in "fragments/xml_to_html_frag.xsl".
  -->
<xsl:template match="/">
  <xsl:comment>
  This file was generated automatically using the XML Pretty Printer XSLT
  stylesheet xml_to_html.xsl.

  For more information about how this file was generated, check out the Tools
  section of the http://www.physiome.org.nz/ website.
  </xsl:comment>
  <html>
    <head>
      <title><xsl:value-of select="$PAGE_TITLE" /></title>
      <xsl:call-template name="xml_to_html_generate_stylesheet_links" />
    </head>
    <body bgcolor="white">
      <xsl:text>&#xA;</xsl:text>
      <p class="embedded-dtd">
        <xsl:text>&#xA;</xsl:text>
        <code class="dtd-pi">&lt;?xml version=</code>
        <code class="dtd-pi-quoted">"1.0"</code>
        <xsl:variable name="encoding" select="//xpp:encoding" />
        <xsl:if test="$encoding">
          <code class="dtd-pi"> encoding=</code>
          <code class="dtd-pi-quoted">
            <xsl:value-of select="concat('&quot;', $encoding, '&quot;')" />
          </code>
        </xsl:if>
        <code class="dtd-pi">?&gt;</code>
        <br /><xsl:text>&#xA;</xsl:text>
        <br /><xsl:text>&#xA;</xsl:text>
        <xsl:for-each select="(//xpp:doctype)[1]">
          <xsl:call-template name="embedded_dtd">
            <xsl:with-param
                name="drop_first_and_last_text_nodes_if_whitespace"
                select="'yes'" />
            <xsl:with-param name="create_dtd_environment" select="'no'" />
          </xsl:call-template>
        </xsl:for-each>
        <xsl:text>&#xA;</xsl:text>
      </p>
      <xsl:text>&#xA;</xsl:text>
      <xsl:call-template name="embedded_xml" />
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>
