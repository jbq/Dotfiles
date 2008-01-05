<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
  <xsl:template match="section[@role='job']" mode="object.title.markup">
    <xsl:apply-templates select="sectioninfo/affiliation/jobtitle"/>
    <xsl:text> - </xsl:text>
    <xsl:apply-templates select="sectioninfo/affiliation/orgname"/>
    <xsl:text> (</xsl:text>
    <xsl:apply-templates select="sectioninfo/affiliation/address" mode="job"/>
    <xsl:text>) </xsl:text>
    <xsl:apply-imports/>
  </xsl:template>

  <xsl:template match="address" mode="job">
    <xsl:apply-templates select="city"/>
    <xsl:if test="city and country">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="country"/>
  </xsl:template>
</xsl:stylesheet>
