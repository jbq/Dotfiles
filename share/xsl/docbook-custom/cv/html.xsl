<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
                <xsl:import href='../html.xsl'/>
  <xsl:import href='common.xsl'/>

  <!-- Import titlepage customization -->
  <xsl:include href='html-titlepage.xsl' />

  <!--+
      | Remove email, add address
      +-->
  <xsl:template match="author" mode="titlepage.mode">
    <xsl:if test="affiliation/orgname">
      <div style="padding-bottom: 5mm">
        <xsl:apply-templates select="affiliation/orgname" mode="titlepage.mode"/>
      </div>
    </xsl:if>

    <div>
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="person.name"/>

      <div style="font-size: .8em">
        <xsl:apply-templates select="address"/>

        <div>
          <xsl:value-of select="email"/>
        </div>
      </div>
    </div>
  </xsl:template>
  <!--+
      | Remove bold on title
      +-->
<xsl:template match="formalpara/title">
  <xsl:variable name="titleStr">
      <xsl:apply-templates/>
  </xsl:variable>
  <xsl:variable name="lastChar">
    <xsl:if test="$titleStr != ''">
      <xsl:value-of select="substring($titleStr,string-length($titleStr),1)"/>
    </xsl:if>
  </xsl:variable>

    <xsl:copy-of select="$titleStr"/>
    <xsl:if test="$lastChar != ''
                  and not(contains($runinhead.title.end.punct, $lastChar))">
      <xsl:value-of select="$runinhead.default.title.end.punct"/>
    </xsl:if>
    <xsl:text>&#160;</xsl:text>
</xsl:template>

  <xsl:template match="orgname">
    <i>
      <xsl:apply-templates/>
    </i>
  </xsl:template>
</xsl:stylesheet>
