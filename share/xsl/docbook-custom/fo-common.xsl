<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version='1.0'>
  <xsl:include href="common.xsl"/>
  <!-- add email address to copyright -->
  <!-- fo/titlepage.xsl match copyright mode titlepage.mode -->
  <xsl:template match="copyright" mode="titlepage.mode">
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'Copyright'"/>
    </xsl:call-template>
    <xsl:call-template name="gentext.space"/>
    <xsl:call-template name="dingbat">
      <xsl:with-param name="dingbat">copyright</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="gentext.space"/>
    <xsl:call-template name="copyright.years">
      <xsl:with-param name="years" select="year"/>
      <xsl:with-param name="print.ranges" select="$make.year.ranges"/>
      <xsl:with-param name="single.year.ranges"
                      select="$make.single.year.ranges"/>
    </xsl:call-template>
    <xsl:call-template name="gentext.space"/>

    <xsl:choose>
      <xsl:when test='not(holder)'>
        <xsl:choose>
          <xsl:when test='../author/affiliation/orgname'>
            <xsl:apply-templates select='../author/affiliation/orgname' mode='titlepage.mode'/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:call-template name='person.name.and.email'>
              <xsl:with-param name='node' select='../author'/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates select='holder' mode='titlepage.mode'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template match="author" mode="titlepage.mode">
  <xsl:if test="affiliation/orgname">
    <fo:block padding-bottom='5mm'>
      <xsl:apply-templates select="affiliation/orgname" mode="titlepage.mode"/>
    </fo:block>
  </xsl:if>

  <fo:block>
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="person.name.and.email"/>
  </fo:block>
</xsl:template>

  <xsl:template match="articleinfo/author/address">
    <fo:block>
      <xsl:value-of select="street"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="postcode"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="city"/>
      <xsl:if test="country">
        <xsl:text> </xsl:text>
        <xsl:value-of select="country"/>
      </xsl:if>
    </fo:block>

    <fo:block>
      <xsl:for-each select="phone">
        <xsl:value-of select="."/>
        <xsl:if test="following-sibling::phone">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>

  <xsl:template match="phrase[@role='xc']">
    <fo:inline color="#36648b" font-weight="bold">
      <xsl:apply-templates select="node()"/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="phrase[@role='xe']">
    <fo:inline color="#A00000" font-weight="bold">
      <xsl:apply-templates select="node()"/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="phrase[@role='xa' or @role='xns']">
    <fo:inline color="red" font-weight="bold">
      <xsl:apply-templates select="node()"/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="sgmltag[not(@class='attribute')]">
    <fo:inline color="#A00000" font-weight="bold" font-family="monospace">
      &lt;<xsl:apply-templates select="node()"/>&gt;
    </fo:inline>
  </xsl:template>

  <xsl:template match='filename'>
    <fo:inline color='green'>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>
</xsl:stylesheet>
