<?xml version='1.0'?>

<!--+
    | Author:         Jean-Baptiste Quenot
    | Purpose:        Convert XML to SQL
    | Date Created:   2005-02-09 15:13:36
    | Revision:       $Id: xmlstyle 447 2004-01-30 13:13:52Z jbq $
    |
    | TODO: Escape apostrophes
    | TODO: remove indentation
    +-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
  <xsl:output method="text"/>

  <xsl:template match="task_log">
    <xsl:text>INSERT INTO task_log (</xsl:text>
    <xsl:for-each select="*">
      <xsl:value-of select="local-name(.)"/>

      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>

    <xsl:text>) VALUES (</xsl:text>
    <xsl:for-each select="*">
      <xsl:if test="@type = 'string'">
        <xsl:text>'</xsl:text>
      </xsl:if>
      <xsl:value-of select="."/>
      <xsl:if test="@type = 'string'">
        <xsl:text>'</xsl:text>
      </xsl:if>

      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>

    <xsl:text>);</xsl:text>
  </xsl:template>
</xsl:stylesheet>
