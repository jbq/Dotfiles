<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
  <xsl:template name='person.name.and.email'>
    <xsl:param name='node' select='.'/>

    <xsl:call-template name='person.name'>
      <xsl:with-param name='node' select='$node'/>
    </xsl:call-template>

    <xsl:text> </xsl:text>
    <xsl:apply-templates select="$node/email"/>
  </xsl:template>

  <xsl:template match="function/replaceable" priority="2">
    <xsl:call-template name="inline.italicmonoseq"/>
  </xsl:template>
</xsl:stylesheet>
