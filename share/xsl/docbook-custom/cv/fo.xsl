<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
                <xsl:import href='../fo.xsl'/>
  <xsl:import href='common.xsl'/>
  <xsl:import href="fo-titlepage.xsl"/>

  <xsl:param name='append.copyright'>no</xsl:param>
  <xsl:param name="body.font.family" select="'sans-serif'"/>
  <xsl:param name="title.font.family" select="'sans-serif'"/>
  <!--xsl:param name="body.font.family" select="'Trebuchet'"/>
  <xsl:param name="title.font.family" select="'Trebuchet'"/-->
  <!--xsl:param name="body.font.family" select="'Tahoma'"/>
  <xsl:param name="title.font.family" select="'Tahoma'"/-->

<xsl:param name="body.margin.bottom" select="'2em'"/>
<xsl:param name="body.margin.top" select="'2em'"/>
<xsl:param name="page.margin.bottom" select="'2em'"/>
<xsl:param name="page.margin.top" select="'1em'"/>

  <xsl:attribute-set name="admonition.properties">
    <xsl:attribute name='border-left'>none</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="list.block.spacing">
    <xsl:attribute name="margin-left">1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="section.title.level1.properties"
    use-attribute-sets='section.title.properties'>
    <xsl:attribute name="font-size">1.1em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">1em</xsl:attribute>
    <xsl:attribute name="space-before.optimum">1em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="section.title.level2.properties"
    use-attribute-sets='section.title.properties'>
    <xsl:attribute name="font-size">1em</xsl:attribute>
    <xsl:attribute name="start-indent">2pc</xsl:attribute>
    <xsl:attribute name="space-before.minimum">.8em</xsl:attribute>
    <xsl:attribute name="space-before.optimum">.8em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">.8em</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
  </xsl:attribute-set>

  <!--+
      | Float
      |
      | TODO: use t:named-template in titlepage.xml
      +-->
  <xsl:template match="mediaobject" mode="article.titlepage.recto.auto.mode">
    <fo:float float="start">
      <xsl:apply-imports/>
    </fo:float>
  </xsl:template>

  <xsl:template name="header.content"/>
  <xsl:template name="footer.content"/>
  <xsl:template name="head.sep.rule"/>
  <xsl:template name="foot.sep.rule"/>
<xsl:attribute-set name="list.block.spacing">
  <xsl:attribute name="space-before.minimum">.4em</xsl:attribute>
  <xsl:attribute name="space-before.optimum">.4em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">.4em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">0</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0</xsl:attribute>
  <xsl:attribute name="space-after.maximum">0</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="list.item.spacing">
  <xsl:attribute name="space-before.minimum">.2em</xsl:attribute>
  <xsl:attribute name="space-before.optimum">.2em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">.2em</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="normal.para.spacing">
  <xsl:attribute name="space-before.minimum">.4em</xsl:attribute>
  <xsl:attribute name="space-before.optimum">.4em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">.4em</xsl:attribute>
</xsl:attribute-set>

  <!--+
      | Remove email, add address
      +-->
  <xsl:template match="author" mode="titlepage.mode">
    <xsl:if test="affiliation/orgname">
      <fo:block padding-bottom='5mm'>
        <xsl:apply-templates select="affiliation/orgname" mode="titlepage.mode"/>
      </fo:block>
    </xsl:if>

    <fo:block>
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="person.name"/>

      <fo:block font-size=".8em">
        <xsl:apply-templates select="address"/>

        <fo:block>
          <xsl:value-of select="email"/>
        </fo:block>
      </fo:block>
    </fo:block>
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

    <fo:inline
               keep-with-next.within-line="always"
               padding-end="1em">
      <xsl:copy-of select="$titleStr"/>
      <xsl:if test="$lastChar != ''
                    and not(contains($runinhead.title.end.punct, $lastChar))">
        <xsl:value-of select="$runinhead.default.title.end.punct"/>
      </xsl:if>
      <xsl:text>&#160;</xsl:text>
    </fo:inline>
  </xsl:template>
  <xsl:template match="orgname">
    <fo:inline font-style="italic">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>
</xsl:stylesheet>
