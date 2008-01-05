<!--+
    | Author:         Jean-Baptiste Quenot <jb.quenot@caraldi.com>
    | Purpose:        Common XSLT templates for fax and letter
    | Date Created:   2004-02-08 21:17:02
    | Revision:       $Id: common.xsl 941 2004-10-01 11:47:29Z jbq $
    +-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" version='1.0'>
  <xsl:template match='signature'>
    <xsl:choose>
      <xsl:when test='@image'>
        <fo:block keep-with-previous="always">
          <fo:external-graphic src='{@image}'
            content-height='2cm' height='2cm'/>
          <fo:block font-weight='bold'><xsl:apply-templates/></fo:block>
        </fo:block>
      </xsl:when>

      <xsl:otherwise>
        <fo:block keep-with-previous="always" font-weight='bold' padding-top='3cm'><xsl:apply-templates/></fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='*' mode='general'>
    <fo:block font-weight='bold'>
      <xsl:if test='honorific'>
        <xsl:apply-templates select='honorific'/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select='firstname'/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select='surname'/>
    </fo:block>

    <xsl:if test='orgname'>
      <xsl:if test='orgdiv'>
        <xsl:apply-templates select='orgdiv'/>
      </xsl:if>
      <xsl:apply-templates select='orgname'/>
    </xsl:if>

    <xsl:if test='location'>
      <xsl:apply-templates select='location'/>
    </xsl:if>
  </xsl:template>

  <xsl:template match='*' mode='details'>
    <xsl:if test='phone|homePhone|email|companyCode|faxNumber'>
      <fo:table padding-top='4mm' table-layout='fixed' font-size='9pt'>
        <xsl:choose>
          <xsl:when test='$big'>
            <fo:table-column column-width='6cm'/>
          </xsl:when>

          <xsl:otherwise>
            <fo:table-column column-width='3cm'/>
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
          <xsl:if test='homePhone'>
            <fo:table-row>
              <fo:table-cell>
                <fo:block>Téléphone domicile</fo:block>
              </fo:table-cell>

              <fo:table-cell>
                <fo:block font-family='monospace'><xsl:apply-templates
                    select='homePhone'/></fo:block>
              </fo:table-cell>
            </fo:table-row>
          </xsl:if>

          <xsl:if test='phone'>
            <fo:table-row>
              <fo:table-cell>
                <fo:block>Téléphone bureau</fo:block>
              </fo:table-cell>

              <fo:table-cell>
                <fo:block font-family='monospace'><xsl:apply-templates select='phone'/></fo:block>
              </fo:table-cell>
            </fo:table-row>
          </xsl:if>

          <xsl:if test='faxNumber'>
            <fo:table-row>
              <fo:table-cell>
                <fo:block>Fax</fo:block>
              </fo:table-cell>

              <fo:table-cell>
                <fo:block font-family='monospace'><xsl:apply-templates
                    select='faxNumber'/></fo:block>
              </fo:table-cell>
            </fo:table-row>
          </xsl:if>

          <xsl:if test='email'>
            <fo:table-row>
              <fo:table-cell>
                <fo:block>Adresse email</fo:block>
              </fo:table-cell>

              <fo:table-cell>
                <fo:block font-family='monospace'><xsl:apply-templates select='email'/></fo:block>
              </fo:table-cell>
            </fo:table-row>
          </xsl:if>

          <xsl:if test='legalinfo'>
            <fo:table-row>
              <fo:table-cell>
                <fo:block>Numéro RCS</fo:block>
              </fo:table-cell>

              <fo:table-cell>
                <fo:block><xsl:apply-templates select='legalinfo'/></fo:block>
              </fo:table-cell>
            </fo:table-row>
          </xsl:if>
        </fo:table-body>
      </fo:table>
    </xsl:if>
  </xsl:template>

  <!--+
      | Override docbook def
      +-->
  <xsl:template match='legalinfo | address'>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match='orgname | orgdiv'>
    <fo:block font-weight='bold'>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match='location'>
    <xsl:for-each select='address'>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </xsl:for-each>

    <fo:block>
      <xsl:apply-templates select='postcode'/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select='city'/>
    </fo:block>

    <xsl:if test='country'>
      <fo:block>
        <xsl:apply-templates select='country'/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template match='literallayout'>
    <fo:block font-family='monospace'
      linefeed-treatment="preserve"
      white-space-collapse='false'
      padding-top='2mm'>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match='orderedlist'>
    <fo:list-block space-before='4mm' margin-left='4mm'>
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

  <xsl:template match='email'>
    <fo:inline font-family='monospace'><xsl:apply-templates/></fo:inline>
  </xsl:template>

  <xsl:template match='para'>
    <!--<fo:block padding-top='4mm' hyphenate='true' language='fr'
      text-align='justify'><xsl:apply-templates/></fo:block>-->
    <fo:block padding-top='4mm' hyphenate='false' language='fr'
      text-align='left'><xsl:apply-templates/></fo:block>
  </xsl:template>

  <xsl:template match='greeting'>
    <fo:block padding-top='8mm' padding-bottom='4mm'><xsl:apply-templates/></fo:block>
  </xsl:template>

  <xsl:template match='para' mode='list-item-body'>
    <fo:block><xsl:apply-templates/></fo:block>
  </xsl:template>

  <xsl:template match='para'>
    <fo:block padding-top='4mm' language='fr'><xsl:apply-templates/></fo:block>
  </xsl:template>

  <xsl:template match='literal'>
    <fo:inline font-family='monospace'>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match='listitem'>
    <fo:list-item space-before='2mm'>
      <fo:list-item-label>
        <fo:block>&#x2022;</fo:block>
      </fo:list-item-label>

      <fo:list-item-body start-indent="8mm">
        <xsl:apply-templates mode='list-item-body'/>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>

  <!--+
      | Prevent Docbook from proceeding to default error template
      +-->
  <xsl:template match="homePhone">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>
