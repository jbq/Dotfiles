<?xml version="1.0" encoding="iso-8859-1"?>

<!--
FILE : dtd_to_latex.xsl

CREATED : 6 August 2001

LAST MODIFIED : 7 August 2001

AUTHOR : Warren Hedley (w.hedley@auckland.ac.nz)
         Department of Engineering Science
         The University of Auckland

TERMS OF USE / COPYRIGHT : See the "Terms of Use" page on the Tools section
  of the physiome.org.nz website, at http://www.physiome.org.nz/

DESCRIPTION : This stylesheet can be used to generate standalone LaTeX files
  containing a formatted representation of a (pre-processed) DTD file.

CHANGES :
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

<xsl:import href="fragments/dtd_to_latex_frag.xsl" />

<xsl:output method="text" />

<xsl:param name="MACROS_FILE"        select="'pml_macros.tex'" />

<!--
  The main template. Builds a basic html Skeleton and calls the
  "embedded_xml" template in "fragments/xml_to_html_frag.xsl".
  -->
<xsl:template match="/">
<xsl:text>
% This file was generated automatically using the DTD Pretty Printer XSLT
% stylesheet dtd_to_latex.xsl. DO NOT EDIT!!
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

<xsl:for-each select="*">
  <xsl:call-template name="embedded_dtd" />
</xsl:for-each>

<xsl:text>
\end{document}
</xsl:text>

</xsl:template>

</xsl:stylesheet>
