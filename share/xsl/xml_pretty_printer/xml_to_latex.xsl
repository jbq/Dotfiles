<?xml version="1.0" encoding="iso-8859-1"?>

<!--
FILE : xml_to_latex.xsl

CREATED : 30 November 2000

LAST MODIFIED : 6 August 2001

AUTHOR : Warren Hedley (w.hedley@auckland.ac.nz)
         Department of Engineering Science
         The University of Auckland

TERMS OF USE / COPYRIGHT : See the "Terms of Use" page on the Tools section
  of the physiome.org.nz website, at http://www.physiome.org.nz/

DESCRIPTION : 

CHANGES :
  02/05/2001 - WJH - moved fragments directory.
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

<xsl:import href="fragments/xml_to_latex_frag.xsl" />
<xsl:import href="fragments/dtd_to_latex_frag.xsl" />

<xsl:output method="text" />

<xsl:param name="MACROS_FILE"        select="'pml_macros.tex'" />

<!--
  The main template. Builds a basic html Skeleton and calls the
  "embedded_xml" template in "fragments/xml_to_html_frag.xsl".
  -->
<xsl:template match="/">
<xsl:text>
% This file was generated automatically using the XML Pretty Printer XSLT
% stylesheet xml_to_latex.xsl. DO NOT EDIT!!
%
% For more information about how this file was generated, check out the Tools
% section of the http://www.physiome.org.nz/ website.
%

\documentclass[12pt,twoside,a4paper]{article}

\usepackage{color}
\usepackage[dvips]{graphics}
\usepackage{alltt}
\usepackage{times}
\usepackage{vmargin}

\pagestyle{empty}

\usepackage[center,sc,small]{caption2}      % Alter caption styles
\setcaptionmargin{0.25in}
\captionstyle{centerlast}

\setpapersize{A4}
\setmargrb{15mm}{5mm}{15mm}{15mm}

\input{</xsl:text><xsl:value-of select="$MACROS_FILE" /><xsl:text>}

\begin{document}
</xsl:text>

<xsl:call-template name="embedded_xml">
  <xsl:with-param name="embedded_dtd_section">
    <xsl:text>\codedpi{&lt;?xml version=}\codedpiq{"1.0"}</xsl:text>
    <xsl:variable name="encoding" select="//xpp:encoding" />
    <xsl:if test="$encoding">
      <xsl:text>\codedpi{ encoding=}\codedpiq{"</xsl:text>
      <xsl:value-of select="$encoding" />
      <xsl:text>"}</xsl:text>
    </xsl:if>
    <xsl:text>\codedpi{?>}&#xA;&#xA;</xsl:text>
    <xsl:if test="//xpp:doctype">
      <xsl:for-each select="(//xpp:doctype)[1]">
        <xsl:call-template name="embedded_dtd">
          <xsl:with-param
              name="drop_first_and_last_text_nodes_if_whitespace"
              select="'yes'" />
          <xsl:with-param name="create_dtd_environment" select="'no'" />
        </xsl:call-template>
      </xsl:for-each>
      <xsl:text>&#xA;</xsl:text>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:with-param>
</xsl:call-template>

<xsl:text>
\end{document}
</xsl:text>

</xsl:template>

</xsl:stylesheet>
