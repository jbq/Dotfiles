<?xml version="1.0" encoding="ISO8859-15"?>

<!--+
    |
    | Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
    | Purpose:       Generate XSL Formatting Objects from Docbook Slides
    | Date Created:  2004-06-18 22:53:44
    | Revision:      $Id: slides.xsl 717 2004-05-04 15:13:09Z jbq $
    |
    | Copyright (c) 2004, Jean-Baptiste Quenot <jb.quenot@caraldi.com>
    | All rights reserved.
    |
    | Redistribution and use in source and binary forms, with or without
    | modification, are permitted provided that the following conditions are
    | met:
    |
    | * Redistributions of source code must retain the above copyright notice,
    |   this list of conditions and the following disclaimer.
    | * Redistributions in binary form must reproduce the above copyright
    |   notice, this list of conditions and the following disclaimer in the
    |   documentation and/or other materials provided with the distribution.
    | * The name of the contributors may not be used to endorse or promote
    |   products derived from this software without specific prior written
    |   permission.
    |
    | THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    | "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    | LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    | A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    | OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    | SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
    | TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    | PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    | LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    | NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    | SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    |
    +-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
  <xsl:import href='slides/xsl/fo/plain.xsl'/>
  <xsl:include href='slides-titlepage-fo.xsl'/>
  <xsl:include href='fo-common.xsl'/>
  <xsl:param name="paper.type">A4</xsl:param>
  <xsl:param name="hyphenate">false</xsl:param>
  <xsl:attribute-set name="admonition.properties">
    <xsl:attribute name='margin-left'>2in</xsl:attribute>
    <xsl:attribute name='margin-right'>2in</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="admonition.title.properties"
    xsl:use-attribute-sets="admonition.properties"/>

  <xsl:template name="slides.titlepage.verso">
    <fo:block background-color="white"
              color="black"
              font-size="{$foil.title.size}"
              font-weight="bold"
              text-align="center"
              font-family="{$slide.title.font.family}"
              break-before='page'>
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">TableofContents</xsl:with-param>
      </xsl:call-template>
    </fo:block>
    <fo:block>
      <fo:leader color="black" leader-pattern="rule" leader-length='100%'/>
    </fo:block>

    <fo:block text-align='center'>
      <fo:external-graphic src='url(daemon-gray.png)' width="auto" height="auto"
        content-width="auto" content-height="auto"/>
    </fo:block>

    <fo:block font-weight="normal" color="gray" font-family="Helvetica"
      margin-left="1in" margin-right="1in" font-size="24pt">
      <fo:list-block space-before.optimum="12pt"
        space-before.minimum="8pt" space-before.maximum="14pt"
        space-after.optimum="0pt" space-after.minimum="0pt"
        space-after.maximum="0pt" provisional-label-separation="0.2em"
        provisional-distance-between-starts="1.5em">

        <xsl:for-each select='foilgroup/title'>
          <fo:list-item space-before.optimum="6pt" space-before.minimum="4pt"
            space-before.maximum="8pt">
            <fo:list-item-label end-indent="label-end()">
              <fo:block>&#x2022;</fo:block>
            </fo:list-item-label>

            <fo:list-item-body start-indent="body-start()">
              <fo:block>
                <fo:block><xsl:apply-templates/></fo:block>
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </xsl:for-each>
      </fo:list-block>
    </fo:block>
  </xsl:template>

  <xsl:template name="foilgroup.titlepage">
    <fo:block text-align='center'>
      <fo:external-graphic src='url(daemon-gray.png)' width="auto" height="auto"
        content-width="auto" content-height="auto"/>
    </fo:block>
    <fo:block font-weight="normal" color="gray" font-family="Helvetica"
      margin-left="1in" margin-right="1in" font-size="24pt">
      <fo:list-block space-before.optimum="12pt"
        space-before.minimum="8pt" space-before.maximum="14pt"
        space-after.optimum="0pt" space-after.minimum="0pt"
        space-after.maximum="0pt" provisional-label-separation="0.2em"
        provisional-distance-between-starts="1.5em">

        <xsl:for-each select='foil/title'>
          <fo:list-item space-before.optimum="6pt" space-before.minimum="4pt"
            space-before.maximum="8pt">
            <fo:list-item-label end-indent="label-end()">
              <fo:block>&#x2022;</fo:block>
            </fo:list-item-label>

            <fo:list-item-body start-indent="body-start()">
              <fo:block>
                <fo:block><xsl:apply-templates/></fo:block>
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </xsl:for-each>
      </fo:list-block>
    </fo:block>
  </xsl:template>

  <xsl:template match="slidesinfo/copyright" mode="titlepage.mode">
    <fo:block>
      <xsl:apply-imports/>
    </fo:block>
  </xsl:template>
  <!--xsl:param name="body.margin.top" select="'1in'"/>
  <xsl:param name="body.margin.bottom" select="'1in'"/-->
  
  <xsl:param name="region.before.extent" select="'3cm'"/>
  <!--xsl:param name="region.after.extent" select="'0.5in'"/-->

  <xsl:param name="page.margin.top" select="'1cm'"/>
  <xsl:param name="page.margin.bottom" select="'1cm'"/>

  <!--xsl:param name="page.margin.inner" select="'0.25in'"/>
  <xsl:param name="page.margin.outer" select="'0.25in'"/-->

  <xsl:param name="draft.mode" select="'no'"/>

  <xsl:param name="local.l10n.xml" select="document('')"/>
  <i18n xmlns="http://docbook.sourceforge.net/xmlns/l10n/1.0">
    <l:l10n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0" language="fr">
      <l:gentext key="Continued" text="(suite)"/>
      <l:context name="title">
        <l:template name="slides" text="%t"/>
        <l:template name="foilgroup" text="%t"/>
        <l:template name="foil" text="%t"/>
      </l:context>
    </l:l10n>
  </i18n>

  <xsl:attribute-set name="foil.properties">
    <xsl:attribute name="font-weight">normal</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="normal.para.spacing">
    <xsl:attribute name="padding-top">.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match='command'>
    <fo:inline font-weight='bold'>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match='screen | programlisting'>
    <fo:block wrap-option='no-wrap' white-space-collapse='false'
      linefeed-treatment="preserve">

  <xsl:if test='@role="compact"'>
    <xsl:attribute name="font-size">14pt</xsl:attribute>
  </xsl:if>
  <xsl:if test="not(ancestor::informaltable or ancestor::table)">
      <xsl:attribute name='background-color'>#F0F0F0</xsl:attribute>
  </xsl:if>
      <xsl:attribute name='padding'>.25em</xsl:attribute>
      <xsl:attribute name='font-family'>monospace</xsl:attribute>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="*[@role='dialog']">
    <fo:block margin="15%" padding="1em" border="1px solid black" text-align="center">
      <xsl:apply-templates select="node()"/>
    </fo:block>
  </xsl:template>

<xsl:template match="ulink[@role='bibliography']" name="ulink">
  <fo:basic-link xsl:use-attribute-sets="xref.properties">
    <xsl:attribute name="external-destination">
      <xsl:call-template name="fo-external-image">
        <xsl:with-param name="filename" select="@url"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:choose>
      <xsl:when test="count(child::node())=0">
        <xsl:call-template name="hyphenate-url">
          <xsl:with-param name="url" select="@url"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <fo:inline font-weight='bold'>
          <xsl:apply-templates/>
        </fo:inline>
      </xsl:otherwise>
    </xsl:choose>
  </fo:basic-link>

  <xsl:if test="count(child::node()) != 0
                and string(.) != @url
                and $ulink.show != 0">
    <!-- yes, show the URI -->
    <xsl:choose>
      <xsl:when test="$ulink.footnotes != 0 and not(ancestor::footnote)">
        <fo:footnote>
          <xsl:call-template name="ulink.footnote.number"/>
          <fo:footnote-body font-family="{$body.fontset}"
                            font-size="{$footnote.font.size}"
                            font-weight="normal"
                            font-style="normal">
            <fo:block>
              <xsl:call-template name="ulink.footnote.number"/>
              <xsl:text> </xsl:text>
              <fo:inline>
                <xsl:value-of select="@url"/>
              </fo:inline>
            </fo:block>
          </fo:footnote-body>
        </fo:footnote>
      </xsl:when>
      <xsl:otherwise>
        <fo:block hyphenate="false" font-size='14pt'>
          <xsl:call-template name="hyphenate-url">
            <xsl:with-param name="url" select="@url"/>
          </xsl:call-template>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="running.head.mode">
  <xsl:param name="master-reference" select="'unknown'"/>
  <!-- use the foilgroup title if there is one -->
  <fo:static-content flow-name="xsl-region-before-foil">
    <fo:block background-color="white"
              color="black"
              font-size="{$foil.title.size}"
              font-weight="bold"
              text-align="center"
              font-family="{$slide.title.font.family}">
      <xsl:apply-templates select="title" mode="titlepage.mode"/>
    </fo:block>
    <fo:block>
      <fo:leader color="black" leader-pattern="rule" leader-length='100%'/>
    </fo:block>
  </fo:static-content>

  <fo:static-content flow-name="xsl-region-before-foil-continued">
    <fo:block background-color="white"
              color="black"
              font-size="{$foil.title.size}"
              font-weight="bold"
              text-align="center"
              font-family="{$slide.title.font.family}">
      <xsl:apply-templates select="title" mode="titlepage.mode"/>
      <xsl:text> </xsl:text>
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'Continued'"/>
      </xsl:call-template>
    </fo:block>
    <fo:block>
      <fo:leader color="black" leader-pattern="rule" leader-length='100%'/>
    </fo:block>
  </fo:static-content>
</xsl:template>

<xsl:template match="*" mode="running.foot.mode">
  <xsl:param name="master-reference" select="'unknown'"/>

  <xsl:variable name="last-slide"
                select="(//foil|//foilgroup)[last()]"/>

  <xsl:variable name="last-id">
    <xsl:choose>
      <xsl:when test="$last-slide/@id">
        <xsl:value-of select="$last-slide/@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="generate-id($last-slide)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="content">
    <fo:table table-layout="fixed" width="100%"
              font-family="{$slide.font.family}"
              font-size="14pt"
              color="#9F9F9F">
      <fo:table-column column-number="1" column-width="6cm"/>
      <fo:table-column column-number="2" column-width="16cm"/>
      <fo:table-column column-number="3" column-width="6cm"/>
      <fo:table-body>
        <fo:table-row height="14pt">
          <fo:table-cell text-align="left">
            <fo:block>
              <xsl:if test="self::foil">
                <xsl:choose>
                  <xsl:when test="ancestor::foilgroup[1]/titleabbrev">
                    <xsl:apply-templates select="ancestor::foilgroup[1]/titleabbrev"
                                         mode="titlepage.mode"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="ancestor::foilgroup[1]/title"
                                         mode="titlepage.mode"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell text-align="center">
            <fo:block>
              <xsl:if test="/slides/slidesinfo/releaseinfo[@role='copyright']">
                <xsl:apply-templates select="/slides/slidesinfo/releaseinfo[@role='copyright']"
                                     mode="value"/>
                <xsl:text>&#160;&#160;&#160;</xsl:text>
              </xsl:if>
              <xsl:apply-templates select="/slides/slidesinfo/copyright"
                                   mode="titlepage.mode"/>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell text-align="right">
            <fo:block>
              <fo:page-number/>
              <xsl:text>&#160;/&#160;</xsl:text>
              <fo:page-number-citation ref-id="{$last-id}"/>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
  </xsl:variable>

  <fo:static-content flow-name="xsl-region-after-foil">
    <fo:block>
      <xsl:copy-of select="$content"/>
    </fo:block>
  </fo:static-content>

  <fo:static-content flow-name="xsl-region-after-foil-continued">
    <fo:block>
      <xsl:copy-of select="$content"/>
    </fo:block>
  </fo:static-content>
</xsl:template>

  <xsl:template match='informaltable[@role="data"]'>
    <fo:block font-size="14pt">
      <xsl:apply-imports/>
    </fo:block>
  </xsl:template>

  <!--+
      | Add support for role="fitpagewidth"
      +-->
  <xsl:template name="calsTable">

  <xsl:variable name="keep.together">
    <xsl:call-template name="dbfo-attribute">
      <xsl:with-param name="pis"
                      select="processing-instruction('dbfo')"/>
      <xsl:with-param name="attribute" select="'keep-together'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:for-each select="tgroup">

    <xsl:variable name="prop-columns"
                  select=".//colspec[contains(@colwidth, '*')]"/>

    <fo:table xsl:use-attribute-sets="table.table.properties">
      <xsl:if test="ancestor-or-self::node()/@role='fitpagewidth'">
        <xsl:attribute name="margin-left">0</xsl:attribute>
        <xsl:attribute name="margin-right">0</xsl:attribute>
      </xsl:if>
      <xsl:if test="$keep.together != ''">
        <xsl:attribute name="keep-together.within-column">
          <xsl:value-of select="$keep.together"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="table.frame"/>
      <xsl:if test="following-sibling::tgroup">
        <xsl:attribute name="border-bottom-width">0pt</xsl:attribute>
        <xsl:attribute name="border-bottom-style">none</xsl:attribute>
        <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
        <xsl:attribute name="space-after.minimum">0pt</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
        <xsl:attribute name="space-after.maximum">0pt</xsl:attribute>
      </xsl:if>
      <xsl:if test="preceding-sibling::tgroup">
        <xsl:attribute name="border-top-width">0pt</xsl:attribute>
        <xsl:attribute name="border-top-style">none</xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="margin-top">0pt</xsl:attribute>
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-before.minimum">0pt</xsl:attribute>
        <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
        <xsl:attribute name="space-before.maximum">0pt</xsl:attribute>
      </xsl:if>
      <xsl:if test="count($prop-columns) != 0 or
                    $fop.extensions != 0 or
                    $fop1.extensions != 0 or
                    $passivetex.extensions != 0">
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="."/>
    </fo:table>
  </xsl:for-each>
</xsl:template>

  <xsl:template match='phrase[@role="highlight"]'>
    <fo:inline xsl:use-attribute-sets='highlight'>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:attribute-set name="highlight">
    <xsl:attribute name='color'>red</xsl:attribute>
  </xsl:attribute-set>
</xsl:stylesheet>
