<?xml version='1.0'?>

<!--+
    | Author:         Jean-Baptiste Quenot <jb.quenot@caraldi.com>
    | Purpose:        Stylesheet for converting fax XML to XSL formatting objects
    | Date Created:   2004-02-08 21:15:52
    | Revision:       $Id: fax.xsl 941 2004-10-01 11:47:29Z jbq $
    +-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" version='1.0'>
  <xsl:include href='common.xsl'/>

  <xsl:output indent='yes'/>

  <xsl:param name='big' select='0'/>

  <xsl:template match='/'>
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
      <fo:layout-master-set>
        <fo:simple-page-master margin-right="3cm" margin-left="3cm"
          margin-bottom="2cm" margin-top="2cm" page-width="21cm"
          page-height="29.7cm" master-name="normal">
          <fo:region-body margin-top='0cm' margin-bottom='0cm'/>
        </fo:simple-page-master>
      </fo:layout-master-set>

      <fo:page-sequence master-reference="normal">
        <fo:flow flow-name="xsl-region-body" font-size="10pt">
          <xsl:apply-templates/>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>

  <xsl:template match='info'>
    <fo:block font-size='24pt' padding-bottom='5mm' text-align='center' font-weight='bold'>FAX</fo:block>

    <fo:block><fo:leader rule-style='solid' leader-pattern='rule' leader-length='100%'/></fo:block>

    <fo:table table-layout='fixed'>
      <fo:table-column column-width='3cm'/>
      <fo:table-column column-width='12cm'/>
      <fo:table-body>
          <xsl:apply-templates select='from'/>
          <xsl:apply-templates select='to'/>
          <xsl:apply-templates select='subject'/>
          <xsl:apply-templates select='pubdate'/>
          <xsl:call-template name='pages'/>
      </fo:table-body>
    </fo:table>

    <fo:block padding-top='5mm' padding-bottom='5mm'><fo:leader rule-style='solid' leader-pattern='rule' leader-length='100%'/></fo:block>
  </xsl:template>

  <xsl:template name='pages'>
    <fo:table-row>
      <fo:table-cell padding-top='4mm'>
        <fo:block>Pages:</fo:block>
      </fo:table-cell>

      <fo:table-cell padding-top='4mm'>
        <xsl:if test='pages'>
          <fo:block><xsl:apply-templates select='pages'/></fo:block>
        </xsl:if>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template match='info/pubdate'>
    <fo:table-row>
      <fo:table-cell padding-top='4mm'>
        <fo:block>Date:</fo:block>
      </fo:table-cell>

      <fo:table-cell padding-top='4mm'>
        <fo:block>
          <xsl:apply-templates/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template match='info/from'>
    <fo:table-row>
      <fo:table-cell padding-top='4mm'>
        <fo:block>De:</fo:block>
      </fo:table-cell>

      <fo:table-cell padding-top='4mm'>
        <xsl:apply-templates select='.' mode='general'/>
        <xsl:apply-templates select='.' mode='details'/>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template match='info/to'>
    <fo:table-row>
      <fo:table-cell padding-top='4mm'>
        <fo:block>A:</fo:block>
      </fo:table-cell>

      <fo:table-cell padding-top='4mm'>
        <xsl:apply-templates select='.' mode='general'/>
        <xsl:apply-templates select='.' mode='details'/>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template match='info/subject'>
    <fo:table-row>
      <fo:table-cell padding-top='4mm'>
        <fo:block>Objet:</fo:block>
      </fo:table-cell>

      <fo:table-cell padding-top='4mm'>
        <fo:block font-weight='bold'>
          <xsl:apply-templates/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
</xsl:stylesheet>
