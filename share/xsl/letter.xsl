<?xml version='1.0'?>

<!--+
    | Author:         Jean-Baptiste Quenot <jb.quenot@caraldi.com>
    | Purpose:        Stylesheet for converting letter XML to XSL-FO
    | Date Created:   2004-02-18 13:16:14
    | Revision:       $Id: letter.xsl 941 2004-10-01 11:47:29Z jbq $
    +-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" version='1.0'>
  <xsl:import href='docbook-custom/fo.xsl'/>
  <xsl:import href='common.xsl'/>

  <xsl:output indent='yes'/>

  <!-- TODO make another stylesheet for big -->
  <xsl:param name='big' select='0'/>

  <xsl:template match='/'>
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
      <fo:layout-master-set>
        <fo:simple-page-master margin-right="3cm" margin-left="3cm"
          margin-bottom="2cm" margin-top="1cm" page-width="21cm"
          page-height="29.7cm" master-name="normal">
          <fo:region-body margin-top='1cm' margin-bottom='1cm'/>
          <fo:region-before region-name='xsl-region-before' display-align='before'
            extent='1cm'/>
          <fo:region-after region-name='xsl-region-after' display-align='after'
            extent='1cm'/>
        </fo:simple-page-master>

        <fo:page-sequence-master master-name="psm">
          <fo:repeatable-page-master-reference master-reference="normal"/>
        </fo:page-sequence-master>
      </fo:layout-master-set>

      <xsl:variable name='font.size'>
        <xsl:choose>
          <xsl:when test='$big'>
            <xsl:text>18pt</xsl:text>
          </xsl:when>

          <xsl:otherwise>
            <xsl:text>12pt</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <fo:page-sequence master-reference="psm">
        <fo:flow flow-name="xsl-region-body" font-size='{$font.size}'>
          <xsl:apply-templates/>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>

  <xsl:template match='letter'>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match='info'>
    <xsl:apply-templates select='from' mode='general'/>
    <xsl:apply-templates select='to'/>
    <xsl:apply-templates select='subject'/>

    <fo:block><fo:leader rule-style='solid' leader-pattern='rule' leader-length='100%'/></fo:block>

    <xsl:apply-templates select='pubdate'/>

    <fo:block padding-bottom='14mm'>
      <fo:leader leader-pattern='space'/>
    </fo:block>
  </xsl:template>

  <xsl:template match='info/pubdate'>
    <fo:block font-weight='bold' padding-top='1cm'>
      <xsl:choose>
        <xsl:when test='//@lang = "en"'>
          <xsl:apply-templates/>
        </xsl:when>

        <xsl:when test='//@lang = "fr"'>
          <xsl:value-of select='../from/location/city'/>, le <xsl:apply-templates/>
        </xsl:when>
      </xsl:choose>
    </fo:block>
  </xsl:template>

  <!-- TODO faire un template générique pour info/from et info/to -->
  <xsl:template match='info/to'>
    <!--<fo:block-container  top='0cm' left='7.5cm' right='21cm' bottom='15cm'
      position='absolute'>-->
      <!--<fo:block text-align='right'>-->
        <fo:block margin-left='7.5cm' padding-top='1cm' padding-bottom='1cm'>
    <fo:block font-weight='bold' padding-top='4mm'>
      <xsl:if test='honorific'>
        <xsl:apply-templates select='honorific'/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select='firstname'/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select='surname'/>
    </fo:block>

    <xsl:if test='orgname'>
      <xsl:apply-templates select='orgname'/>
    </xsl:if>

    <xsl:if test='location'>
      <xsl:apply-templates select='location'/>
    </xsl:if>

    <xsl:if test='phone|email'>
      <fo:table padding-top='4mm' table-layout='fixed'>
        <xsl:choose>
          <xsl:when test='$big'>
            <fo:table-column column-width='6cm'/>
          </xsl:when>

          <xsl:otherwise>
            <fo:table-column column-width='4cm'/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test='$big'>
            <fo:table-column column-width='8cm'/>
          </xsl:when>

          <xsl:otherwise>
            <fo:table-column column-width='10cm'/>
          </xsl:otherwise>
        </xsl:choose>

        <fo:table-body>
          <xsl:if test='phone'>
            <fo:table-row>
              <fo:table-cell>
                <fo:block>
                  <xsl:choose>
                    <xsl:when test='//@lang = "fr"'>
                      <xsl:text>Téléphone domicile</xsl:text>
                    </xsl:when>

                    <xsl:when test='//@lang = "en"'>
                      <xsl:text>Home Phone</xsl:text>
                    </xsl:when>
                  </xsl:choose>
                </fo:block>
              </fo:table-cell>

              <fo:table-cell>
                <fo:block font-family='monospace'><xsl:apply-templates select='phone'/></fo:block>
              </fo:table-cell>
            </fo:table-row>
          </xsl:if>

          <xsl:if test='email'>
            <fo:table-row>
              <fo:table-cell>
                <fo:block>
                  <xsl:choose>
                    <xsl:when test='//@lang = "fr"'>
                      <xsl:text>Adresse email</xsl:text>
                    </xsl:when>

                    <xsl:when test='//@lang = "en"'>
                      <xsl:text>Email address</xsl:text>
                    </xsl:when>
                  </xsl:choose>
                </fo:block>
              </fo:table-cell>

              <fo:table-cell>
                <fo:block font-family='monospace'><xsl:apply-templates select='email'/></fo:block>
              </fo:table-cell>
            </fo:table-row>
          </xsl:if>
        </fo:table-body>
      </fo:table>
    </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match='companyCode'>
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match='info/subject'>
    <fo:block font-weight='bold' padding-top='4mm'>
      <xsl:choose>
        <xsl:when test='//@lang = "fr"'>
          <xsl:text>Objet: </xsl:text>
        </xsl:when>

        <xsl:when test='//@lang = "en"'>
          <xsl:text>Subject: </xsl:text>
        </xsl:when>
      </xsl:choose>

      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match='signature'>
    <xsl:apply-imports/>

    <xsl:if test="@image">
      <fo:block keep-with-previous="always">
        <xsl:apply-templates select='../info/from' mode='details'/>
      </fo:block>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
