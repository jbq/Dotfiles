<?xml version='1.0'?>

<!--
  File:           html.xsl
  Author:         Jean-Baptiste Quenot
  Purpose:        Customize the default Docbook HTML stylesheet
  Date Created:   2003-07-23 18:56:15
  CVS Id:         $Id: html.xsl 738 2004-05-19 17:22:30Z jbq $
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="docbook/html/docbook.xsl"/>
  <xsl:import href="common.xsl"/>

  <!-- Import titlepage customization -->
  <xsl:include href='html-titlepage.xsl' />

  <xsl:output indent='yes' encoding="UTF-8"/>

  <xsl:variable name='info' select='/article/articleinfo|/book/bookinfo'/>
  <xsl:param name="HOME_HREF" select="''"/>
  <xsl:param name="toc.section.depth">3</xsl:param>
  <xsl:param name="css.directory" select="'/css'"/>
  <xsl:param name="HOME_TITLE" select="'Back to Home Page'"/>
  <xsl:param name="PDF_HREF" select="''"/>
  <xsl:param name="PDF_TITLE" select="'PDF Version'"/>
  <xsl:param name="SRC_HREF" select="''"/>
  <xsl:param name="SRC_TITLE" select="'Source code for this page'"/>
  <xsl:param name='SITE_TITLE' value="''"/>
  <xsl:param name="CSS" select="'/docbook.css'"/>
  <xsl:param name='generate.document.info' select='0'/>
  <xsl:param name="html.stylesheet" select="concat($css.directory, $CSS)" />

  <xsl:template name="user.footer.content">
    <hr/>

    <xsl:if test='$info/revhistory'>
      <xsl:apply-templates select='$info/revhistory'/>
      <hr/>
    </xsl:if>

    <xsl:if test='$generate.document.info'>
      <xsl:call-template name='document.info'/>
    </xsl:if>

    <xsl:apply-templates select="$info/copyright"
      mode='titlepage.mode'/>

    <xsl:if test='$HOME_HREF or $PDF_HREF or $SRC_HREF'>
      <hr/>
      <xsl:call-template name='user.common.content.data' />
    </xsl:if>

  </xsl:template>

  <xsl:template name="user.header.content">
    <xsl:if test='$HOME_HREF or $PDF_HREF or $SRC_HREF'>
      <xsl:call-template name='user.common.content.data' />

      <hr />
    </xsl:if>
  </xsl:template>

  <xsl:template name="user.common.content.data">
    <p>
      <xsl:if test='$HOME_HREF'>
        [<a href='{$HOME_HREF}'>
          <xsl:value-of select='$HOME_TITLE' />
        </a>]
      </xsl:if>

      <xsl:if test='$PDF_HREF'>
        [<a href='{$PDF_HREF}'>
          <xsl:value-of select='$PDF_TITLE' />
        </a>]
      </xsl:if>

      <xsl:if test='$SRC_HREF'>
        [<a href='{$SRC_HREF}'>
          <xsl:value-of select='$SRC_TITLE' />
        </a>]
      </xsl:if>
    </p>
  </xsl:template>

  <!-- Define some markup to be monospaced -->
  <xsl:template match='database | type | symbol | command'>
    <xsl:call-template name="inline.monoseq"/>
  </xsl:template>

  <!-- Customize abstract layout: remove formal title -->
  <xsl:template match="abstract" mode="titlepage.mode">
    <div class="{name(.)}">
      <xsl:call-template name="anchor"/>
      <xsl:apply-templates mode="titlepage.mode"/>
    </div>
  </xsl:template>

  <!--
    Add a "class" attribute to inline monospaced sequences to handle the
    monoseq type (filename, ...) with CSS
  -->
  <xsl:template name="inline.monoseq">
    <xsl:param name="content">
      <xsl:if test="@id">
        <a name="{@id}"/>
      </xsl:if>

      <xsl:apply-templates/>
    </xsl:param>

    <tt>
      <xsl:attribute name='class'>
        <xsl:value-of select='local-name(.)'/>
      </xsl:attribute>

      <xsl:copy-of select="$content"/>
    </tt>
  </xsl:template>

  <!-- Customize admonition title layout -->
  <!--xsl:template name="nongraphical.admonition">
    <div class="{name(.)}">
      <xsl:if test="$admon.style">
        <xsl:attribute name="style">
          <xsl:value-of select="$admon.style"/>
        </xsl:attribute>
      </xsl:if>

      <h3 class="title">
        <xsl:call-template name="anchor"/>
        <xsl:apply-templates select="." mode="object.title.markup"/>
        <xsl:text>. </xsl:text>
      </h3>

      <xsl:apply-templates/>
    </div>
  </xsl:template-->

  <!-- man pages to be linked to freebsd.org -->
  <xsl:param name="citerefentry.link" select="'1'"/>
  <xsl:template name="generate.citerefentry.link">
    <xsl:text>http://www.FreeBSD.org/cgi/man.cgi?query=</xsl:text>
    <xsl:value-of select="refentrytitle"/>
    <xsl:text>&amp;sektion=</xsl:text>
    <xsl:value-of select="manvolnum"/>
  </xsl:template>

  <!-- copy role attribute in <phrase role='style'/> for applying custom CSS in
  a HTML <span/> element -->
  <xsl:template match="phrase">
    <span>
      <xsl:attribute name='class'>
        <xsl:apply-templates select='@role'/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- define which tocs are generated -->
  <xsl:param name="generate.toc">
  book      toc,figure,table,example,equation
  </xsl:param>

  <!-- add email address to author markup in title page -->
  <!-- titlepage.xsl match author mode titlepage.mode -->
  <xsl:template match="author" mode="titlepage.mode">
    <div class="{name(.)}">
      <h3 class="{name(.)}">
        <xsl:call-template name="person.name"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select='email'/>
      </h3>
      <xsl:apply-templates mode="titlepage.mode" select="./contrib"/>
      <xsl:apply-templates mode="titlepage.mode" select="./affiliation"/>
    </div>
  </xsl:template>

  <!-- add email address to copyright -->
  <!-- html/titlepage.xsl match copyright mode titlepage.mode -->
  <xsl:template match="copyright" mode="titlepage.mode">
    <p class="{name(.)}">
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
    </p>
  </xsl:template>

  <!--
  <xsl:template match="articleinfo/title" mode="title.markup">
    <xsl:choose>
      <xsl:when test='$SITE_TITLE'>
        <xsl:value-of select='$SITE_TITLE'/>
        <xsl:text> - </xsl:text>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  -->

  <xsl:template match="revision/revremark">
    <div class='revremark'><xsl:apply-templates/></div>
  </xsl:template>

  <xsl:template match="sgmltag">
    <tt class='sgmltag'>&lt;<xsl:apply-templates/>&gt;</tt>
  </xsl:template>

  <xsl:template match='othercredit'>
    <div class="{name(.)}">
      <xsl:call-template name="person.name.and.email"/><br/>
      <xsl:apply-templates select="affiliation"/>
    </div>
  </xsl:template>

  <xsl:template match='affiliation'>
    <xsl:apply-templates select='orgname'/>,
      <xsl:apply-templates select='jobtitle'/><br/>
    <xsl:apply-templates select='address/phone'/><br/>
  </xsl:template>

  <xsl:template match="formalpara[@role]">
    <div class="formalpara {@role}">
      <xsl:call-template name="anchor"/>
      <xsl:apply-templates/>
    </div>
</xsl:template>
  <xsl:template match="articleinfo/author/address">
    <div class="address">
      <xsl:value-of select="street"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="postcode"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="city"/>
      <xsl:if test="country">
        <xsl:text> </xsl:text>
        <xsl:value-of select="country"/>
      </xsl:if>
    </div>

    <div class="phone">
      <xsl:for-each select="phone">
        <xsl:value-of select="."/>
        <xsl:if test="following-sibling::phone">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </div>
  </xsl:template>
</xsl:stylesheet>
