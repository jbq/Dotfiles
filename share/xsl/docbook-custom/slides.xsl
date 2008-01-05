<?xml version="1.0" encoding="ISO8859-15"?>

<!--
  File:          slides.xsl
  Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
  Purpose:       Produce slides as HTML
  Date Created:  2002-10-30 14:45:24
  CVS Id:        $Id: slides.xsl 717 2004-05-04 15:13:09Z jbq $
 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href='slides/html/default.xsl'/>
  <!--xsl:param name="output.indent" select="'yes'"/>
  <xsl:param name="toc.width" select="200"/>

  <xsl:param name='graphics.dir' select="'../graphics'"/>
  <xsl:param name="css.stylesheet" select="'../browser/slides-frames.css'"/>
  <xsl:param name='script.dir' select="'../browser'"/-->
  <xsl:param name='base.dir' select="'slides/'"/>

  <!-- does not fully work on mozilla -->
  <!--xsl:param name="active.toc" select="0"/>
  <xsl:param name='keyboard.nav' select='0'/>
  <xsl:param name="dynamic.toc" select="0"/>
  <xsl:param name="toc.hide.show" select="0"/-->

  <!--<xsl:param name="overlay" select="1"/>-->
<!--xsl:param name="multiframe" select="1"/-->
  <!--<xsl:template name="foilgroup-top-nav"/>
  <xsl:template name="foil-top-nav"/>-->

  <xsl:template match="slidesinfo/author" mode='titlepage.mode'>
    <div class="{name(.)}">
      <h3 class="{name(.)}">
        <xsl:call-template name="person.name"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select='email'/>
      </h3>

      <xsl:apply-templates mode="titlepage.mode" select="./contrib"/>
      <xsl:apply-templates mode="titlepage.mode" select="./affiliation"/>
    </div>
  </xsl:template>

  <xsl:template match="holder" mode='titlepage.mode'>
    <xsl:apply-templates/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select='../../author/email'/>
  </xsl:template>

  <xsl:template match="copyright" mode="titlepage.mode"/>
</xsl:stylesheet>
