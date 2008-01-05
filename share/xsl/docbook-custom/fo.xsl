<?xml version='1.0'?>

<!--
  File:           fo.xsl
  Author:         Jean-Baptiste Quenot
  Purpose:        Customize the default Docbook FO stylesheet
  Date Created:   2003-07-23 18:55:47
  CVS Id:         $Id: fo.xsl 1010 2004-10-18 16:29:37Z jbq $
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
  <xsl:import href="docbook/fo/docbook.xsl"/>
  <xsl:import href="fo-titlepage.xsl"/>
  <xsl:include href='fo-common.xsl'/>
  <xsl:output indent='yes'/>

  <xsl:param name="resources.dir"/>
  <xsl:param name="shade.verbatim" select="1"/>
  <xsl:param name="admon.graphics.path" select="concat($resources.dir, '/admonition/')"/>
<xsl:param name="page.margin.inner">
  <xsl:choose>
    <xsl:when test="$double.sided != 0">1.25in</xsl:when>
    <xsl:otherwise>1cm</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="page.margin.outer">
  <xsl:choose>
    <xsl:when test="$double.sided != 0">0.75in</xsl:when>
    <xsl:otherwise>1cm</xsl:otherwise>
  </xsl:choose>
</xsl:param>
  <xsl:param name='append.copyright'>yes</xsl:param>
  <xsl:param name="toc.section.depth">3</xsl:param>
  <xsl:param name="paper.type">A4</xsl:param>
  <!-- don't justify -->
  <xsl:param name='alignment'>left</xsl:param>
  <!-- FOP has broken french hyphenation -->
  <xsl:param name='hyphenate'>false</xsl:param>
<xsl:param name="generate.toc">
/appendix toc,title
article/appendix  nop
/article  nop
book      toc,title,figure,table,example,equation
/chapter  toc,title
part      toc,title
/preface  toc,title
qandadiv  toc
qandaset  toc
reference toc,title
/sect1    toc
/sect2    toc
/sect3    toc
/sect4    toc
/sect5    toc
/section  nop
set       toc,title
</xsl:param>

  <xsl:attribute-set name="admonition.properties">
    <xsl:attribute name='border-left'>solid</xsl:attribute>
    <xsl:attribute name='padding-left'>1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="abstract.properties">
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="start-indent">inherit</xsl:attribute>
    <xsl:attribute name="end-indent">inherit</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="/article/*[position() = last()]">
    <xsl:apply-imports/>

    <xsl:if test='//copyright and $append.copyright = "yes"'>
      <fo:block start-indent="0pt" keep-together="always">
        <fo:leader color="black" leader-pattern="rule" leader-length='100%'/>

        <fo:block>
          <xsl:apply-templates select="//copyright[1]" mode="titlepage.mode"/>
        </fo:block>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:param name="draft.mode" select="'no'"/>

  <xsl:template match='othercredit'>
    <xsl:call-template name="person.name.and.email"/>
    <xsl:apply-templates select="affiliation"/>
  </xsl:template>

  <xsl:template match='affiliation'>
    <fo:block><xsl:apply-templates select='orgname'/>,
      <xsl:apply-templates select='jobtitle'/></fo:block>
    <fo:block><xsl:apply-templates select='address/phone'/></fo:block>
  </xsl:template>

  <xsl:template match='jobtitle'>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match='orgname'>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="revhistory" mode="titlepage.mode"/>

  <xsl:template match='phrase[@role="highlight"]'>
    <fo:inline font-weight='bold'>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- Display <entry role='total'/> with bold text -->
  <xsl:template match="entry|entrytbl" name="entry">
    <xsl:param name="col" select="1"/>
    <xsl:param name="spans"/>

    <xsl:variable name="row" select="parent::row"/>
    <xsl:variable name="group" select="$row/parent::*[1]"/>
    <xsl:variable name="frame" select="ancestor::tgroup/parent::*/@frame"/>

    <xsl:variable name="empty.cell" select="count(node()) = 0"/>

    <xsl:variable name="named.colnum">
      <xsl:call-template name="entry.colnum"/>
    </xsl:variable>

    <xsl:variable name="entry.colnum">
      <xsl:choose>
        <xsl:when test="$named.colnum &gt; 0">
          <xsl:value-of select="$named.colnum"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$col"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="entry.colspan">
      <xsl:choose>
        <xsl:when test="@spanname or @namest">
          <xsl:call-template name="calculate.colspan"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="following.spans">
      <xsl:call-template name="calculate.following.spans">
        <xsl:with-param name="colspan" select="$entry.colspan"/>
        <xsl:with-param name="spans" select="$spans"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="rowsep">
      <xsl:choose>
        <!-- If this is the last row, rowsep never applies. -->
        <xsl:when test="not(ancestor-or-self::row[1]/following-sibling::row
                            or ancestor-or-self::thead/following-sibling::tbody
                            or ancestor-or-self::tbody/preceding-sibling::tfoot)">
          <xsl:value-of select="0"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="inherited.table.attribute">
            <xsl:with-param name="entry" select="."/>
            <xsl:with-param name="colnum" select="$entry.colnum"/>
            <xsl:with-param name="attribute" select="'rowsep'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

  <!--
    <xsl:message><xsl:value-of select="."/>: <xsl:value-of select="$rowsep"/></xsl:message>
  -->

    <xsl:variable name="colsep">
      <xsl:choose>
        <!-- If this is the last column, colsep never applies. -->
        <xsl:when test="$following.spans = ''">0</xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="inherited.table.attribute">
            <xsl:with-param name="entry" select="."/>
            <xsl:with-param name="colnum" select="$entry.colnum"/>
            <xsl:with-param name="attribute" select="'colsep'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="valign">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'valign'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="align">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'align'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="char">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'char'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="charoff">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'charoff'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$spans != '' and not(starts-with($spans,'0:'))">
        <xsl:call-template name="entry">
          <xsl:with-param name="col" select="$col+1"/>
          <xsl:with-param name="spans" select="substring-after($spans,':')"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$entry.colnum &gt; $col">
        <xsl:call-template name="empty.table.cell">
          <xsl:with-param name="colnum" select="$col"/>
        </xsl:call-template>
        <xsl:call-template name="entry">
          <xsl:with-param name="col" select="$col+1"/>
          <xsl:with-param name="spans" select="substring-after($spans,':')"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="cell.content">
          <fo:block>
            <!-- highlight this entry? -->
            <xsl:if test="ancestor::thead or contains(@role, 'total')">
              <xsl:attribute name="font-weight">bold</xsl:attribute>
            </xsl:if>

            <xsl:if test="contains(@role, 'option')">
              <xsl:attribute name="font-style">italic</xsl:attribute>
            </xsl:if>

            <xsl:if test="contains(@role, 'offre')">
              <xsl:attribute name="color">red</xsl:attribute>
            </xsl:if>

            <!-- are we missing any indexterms? -->
            <xsl:if test="not(preceding-sibling::entry)
                          and not(parent::row/preceding-sibling::row)">
              <!-- this is the first entry of the first row -->
              <xsl:if test="ancestor::thead or
                            (ancestor::tbody
                             and not(ancestor::tbody/preceding-sibling::thead
                                     or ancestor::tbody/preceding-sibling::tbody))">
                <!-- of the thead or the first tbody -->
                <xsl:apply-templates select="ancestor::tgroup/preceding-sibling::indexterm"/>
              </xsl:if>
            </xsl:if>

            <!--
            <xsl:text>(</xsl:text>
            <xsl:value-of select="$rowsep"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$colsep"/>
            <xsl:text>)</xsl:text>
            -->
            <xsl:choose>
              <xsl:when test="$empty.cell">
                <xsl:text>&#160;</xsl:text>
              </xsl:when>
              <xsl:when test="self::entrytbl">
                <xsl:variable name="prop-columns"
                              select=".//colspec[contains(@colwidth, '*')]"/>
                <fo:table border-collapse="collapse">
                  <xsl:if test="count($prop-columns) != 0">
                    <xsl:attribute name="table-layout">fixed</xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="tgroup"/>
                </fo:table>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
        </xsl:variable>

        <xsl:variable name="cell-orientation">
          <xsl:call-template name="dbfo-attribute">
            <xsl:with-param name="pis"
                            select="ancestor-or-self::entry/processing-instruction('dbfo')"/>
            <xsl:with-param name="attribute" select="'orientation'"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="row-orientation">
          <xsl:call-template name="dbfo-attribute">
            <xsl:with-param name="pis"
                            select="ancestor-or-self::row/processing-instruction('dbfo')"/>
            <xsl:with-param name="attribute" select="'orientation'"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="cell-width">
          <xsl:call-template name="dbfo-attribute">
            <xsl:with-param name="pis"
                            select="ancestor-or-self::entry/processing-instruction('dbfo')"/>
            <xsl:with-param name="attribute" select="'rotated-width'"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="row-width">
          <xsl:call-template name="dbfo-attribute">
            <xsl:with-param name="pis"
                            select="ancestor-or-self::row/processing-instruction('dbfo')"/>
            <xsl:with-param name="attribute" select="'rotated-width'"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="orientation">
          <xsl:choose>
            <xsl:when test="$cell-orientation != ''">
              <xsl:value-of select="$cell-orientation"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$row-orientation"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="rotated-width">
          <xsl:choose>
            <xsl:when test="$cell-width != ''">
              <xsl:value-of select="$cell-width"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$row-width"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="bgcolor">
          <xsl:call-template name="dbfo-attribute">
            <xsl:with-param name="pis"
                            select="ancestor-or-self::entry/processing-instruction('dbfo')"/>
            <xsl:with-param name="attribute" select="'bgcolor'"/>
          </xsl:call-template>
        </xsl:variable>

        <fo:table-cell xsl:use-attribute-sets="table.cell.padding">
          <xsl:if test="$xep.extensions != 0">
            <!-- Suggested by RenderX to workaround a bug in their implementation -->
            <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
          </xsl:if>

          <xsl:if test="$bgcolor != ''">
            <xsl:attribute name="background-color">
              <xsl:value-of select="$bgcolor"/>
            </xsl:attribute>
          </xsl:if>

          <xsl:call-template name="anchor"/>

          <xsl:if test="$rowsep &gt; 0">
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'bottom'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$colsep &gt; 0 and $col &lt; ancestor::tgroup/@cols">
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'right'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="@morerows">
            <xsl:attribute name="number-rows-spanned">
              <xsl:value-of select="@morerows+1"/>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$entry.colspan &gt; 1">
            <xsl:attribute name="number-columns-spanned">
              <xsl:value-of select="$entry.colspan"/>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$valign != ''">
            <xsl:attribute name="display-align">
              <xsl:choose>
                <xsl:when test="$valign='top'">before</xsl:when>
                <xsl:when test="$valign='middle'">center</xsl:when>
                <xsl:when test="$valign='bottom'">after</xsl:when>
                <xsl:otherwise>
                  <xsl:message>
                    <xsl:text>Unexpected valign value: </xsl:text>
                    <xsl:value-of select="$valign"/>
                    <xsl:text>, center used.</xsl:text>
                  </xsl:message>
                  <xsl:text>center</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$align != ''">
            <xsl:attribute name="text-align">
              <xsl:value-of select="$align"/>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$char != ''">
            <xsl:attribute name="text-align">
              <xsl:value-of select="$char"/>
            </xsl:attribute>
          </xsl:if>

  <!--
          <xsl:if test="@charoff">
            <xsl:attribute name="charoff">
              <xsl:value-of select="@charoff"/>
            </xsl:attribute>
          </xsl:if>
  -->

          <xsl:choose>
            <xsl:when test="$xep.extensions != 0 and $orientation != ''">
              <fo:block-container reference-orientation="{$orientation}">
                <xsl:if test="$rotated-width != ''">
                  <xsl:attribute name="width">
                    <xsl:value-of select="$rotated-width"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:copy-of select="$cell.content"/>
              </fo:block-container>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$cell.content"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:table-cell>

        <xsl:choose>
          <xsl:when test="following-sibling::entry|following-sibling::entrytbl">
            <xsl:apply-templates select="(following-sibling::entry
                                         |following-sibling::entrytbl)[1]">
              <xsl:with-param name="col" select="$col+$entry.colspan"/>
              <xsl:with-param name="spans" select="$following.spans"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="finaltd">
              <xsl:with-param name="spans" select="$following.spans"/>
              <xsl:with-param name="col" select="$col+$entry.colspan"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='note[@role="offre"]' mode="object.title.markup">
    <fo:inline color='red'>Offre exceptionnelle</fo:inline>
  </xsl:template>

<xsl:template match="releaseinfo" mode="article.titlepage.recto.auto.mode">
<fo:block xmlns:fo="http://www.w3.org/1999/XSL/Format" xsl:use-attribute-sets="article.titlepage.recto.style" space-before="0.5em">
  Revision
  <xsl:value-of select="substring(., 7, string-length(.) - 7)" mode="article.titlepage.recto.mode"/>
  edited on
  <xsl:value-of select="substring(../date, 35, string-length(../date) - 37)" mode="article.titlepage.recto.mode"/>
</fo:block>
</xsl:template>

<xsl:template match="date" mode="article.titlepage.recto.auto.mode">
</xsl:template>

  <xsl:template match="formalpara[@role='important']">
  <fo:block keep-together="always" xsl:use-attribute-sets="normal.para.spacing" border="1px solid black" padding=".5em">
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!--+
    | Add 4pc to start-indent of toc entries
    +-->
<xsl:template match="section" mode="toc">
  <xsl:param name="toc-context" select="."/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="cid">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$toc-context"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="depth" select="count(ancestor::section) + 1"/>
  <xsl:variable name="reldepth"
                select="count(ancestor::*)-count($toc-context/ancestor::*)"/>

  <xsl:if test="$toc.section.depth &gt;= $depth">
    <xsl:call-template name="toc.line"/>

    <xsl:if test="$toc.section.depth &gt; $depth and section">
      <fo:block id="toc.{$cid}.{$id}"
                start-indent="{$reldepth*$toc.indent.width}pt + 4pc">
        <xsl:apply-templates select="section" mode="toc">
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:apply-templates>
      </fo:block>
    </xsl:if>
  </xsl:if>
</xsl:template>
<xsl:template match="guibutton">
  <xsl:call-template name="inline.boldseq"/>
</xsl:template>
  <xsl:attribute-set name="section.title.level1.properties"
    use-attribute-sets='section.title.properties'>
    <xsl:attribute name='font-size'>
      <xsl:text>1.1em</xsl:text>
    </xsl:attribute>
  </xsl:attribute-set>
</xsl:stylesheet>
