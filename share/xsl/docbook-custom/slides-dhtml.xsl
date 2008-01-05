<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns="http://www.w3.org/TR/xhtml1/transitional"
  xmlns:jedit="java:code2html.Main" exclude-result-prefixes="jedit #default">
  <!--xsl:import href="docbook/html/docbook.xsl"/-->
  <xsl:import
    href='http://docbook.sourceforge.net/release/xsl/current/html/docbook.xsl'/>
  <xsl:output indent='yes' method='html' encoding="UTF-8"/>
  <xsl:param name="linenumbering.extension" select="0"/>
  <xsl:param name="codehighlighting.extension" select="1"/>
  <xsl:param name="use.extensions" select="1"/>
  <xsl:param name="event" select="''" />
  <xsl:param name='resources' select='"resources"'/>

  <xsl:template match="programlisting/text()">
    <xsl:choose>
      <xsl:when test="function-available('jedit:htmlSyntax') and $codehighlighting.extension = '1' and $use.extensions != '0'">
        <xsl:copy-of select="jedit:htmlSyntax(.)"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select='.'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--xsl:template match="programlisting">
    <pre class="programlisting" onclick="makeScroll(this)">
      <xsl:apply-templates/>
    </pre>
  </xsl:template-->

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name='titlepage'>
    <div class="slidetitle">
      <table class='slidetitle'>
        <tr>
          <td colspan='2'>
            <xsl:call-template name="navigation"/>
            <xsl:apply-templates select="//slidesinfo/pubdate"/>
            <xsl:apply-templates select="//slidesinfo/mediaobject"/>
            <xsl:apply-templates select="//slidesinfo/title"/>
            <xsl:apply-templates select="//slidesinfo/subtitle"/>
            <xsl:apply-templates select="//slidesinfo/authorgroup|//slidesinfo/author"/>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>

  <xsl:template match="slides">
    <html>
      <head>
        <title>
          <xsl:value-of select="./slidesinfo/title"/>
        </title>
        <script type="text/javascript" src="{$resources}/slides.js"></script>
        <link rel="stylesheet" type="text/css" href="{$resources}/slides.css" media="screen" />
        <link rel="stylesheet" type="text/css" href="{$resources}/slides-print.css" media="print" />
      </head>
      <body onload="init()">
        <xsl:call-template name='titlepage'/>

        <xsl:apply-templates select="foil|foilgroup"/>
        <xsl:call-template name="toc"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match='pubdate'>
    <div class='pubdate'>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="slidesinfo/author">
    <div class="{name(.)}">
      <h3 class="{name(.)}">
        <xsl:call-template name="person.name"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select='email'/>
      </h3>

      <xsl:apply-templates select="contrib"/>
      <xsl:apply-templates select="affiliation"/>
    </div>
  </xsl:template>

  <xsl:template match="slidesinfo/author" mode='footer'>
    <span class='person'>
    <xsl:call-template name="person.name"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select='email'/>
    </span>

    <xsl:apply-templates select="affiliation" mode="titlepage.mode"/>
  </xsl:template>

  <xsl:template name="holder">
    <xsl:apply-templates select='//slidesinfo/author' mode='footer'/>
  </xsl:template>

  <xsl:template match="firstname|surname">
    <xsl:apply-templates/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="//slidesinfo/subtitle">
    <h2 class="subtitle">
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="//slidesinfo/title">
    <h1>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <xsl:template match="authorgroup">
    <xsl:for-each select="author">
      <div class="author">
        <xsl:apply-templates/>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="toc">
    <div id="slidetoc">
      <h4 class="toctitle">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">TableofContents</xsl:with-param>
        </xsl:call-template>
      </h4>

      <p class='toc'>
        <a href="#" onclick="jumptoc(0)">
        <xsl:value-of select="//title"/>
        </a>
      </p>

      <xsl:variable name="num">1</xsl:variable>
      <ul class='toc'>
        <xsl:for-each select="foil|foilgroup">
          <li>
            <a href="#">
              <xsl:attribute name="onclick">
                <xsl:text>jumptoc(</xsl:text>
                <xsl:number level="any" count="foil|foilgroup"/>
                <xsl:text>)</xsl:text>
              </xsl:attribute>
              <xsl:value-of select="title"/>
            </a>
            <xsl:if test="name()='foilgroup'">
              <ul class='toc'>
                <xsl:for-each select="foil">
                  <li>
                    <a href="#">
                      <xsl:attribute name="onclick">
                        <xsl:text>jumptoc(</xsl:text>
                        <xsl:number level="any" count="foil|foilgroup"/>
                        <xsl:text>)</xsl:text>
                      </xsl:attribute>
                      <xsl:value-of select="title"/>
                    </a>
                  </li>
                </xsl:for-each>
              </ul>
            </xsl:if>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="foilgroup">
    <xsl:call-template name="anchor">
      <xsl:with-param name="conditional" select="0"/>
    </xsl:call-template>
    <div class="slidegroup">
      <table class="foil" cellspacing="0" cellpadding="0" border="0">
        <tr>
          <th class="foil" colspan="2">
            <xsl:apply-templates select="title" mode="show"/>
          </th>
        </tr>
        <tr>
          <td class="foil" colspan="2">
            <xsl:apply-templates select="*[name()!='foil']"/>
            <ul>
              <xsl:for-each select="preceding-sibling::foilgroup">
                <li class="previous">
                  <xsl:apply-templates select="title" mode="show"/>
                </li>
              </xsl:for-each>
              <li class="current">
                <xsl:apply-templates select="title" mode="show"/>
                <ul>
                  <xsl:for-each select="foil">
                    <li>
                      <xsl:apply-templates select="title" mode="show"/>
                    </li>
                  </xsl:for-each>
                </ul>
              </li>
              <xsl:for-each select="following-sibling::foilgroup">
                <li class="following">
                  <xsl:apply-templates select="title" mode="show"/>
                </li>
              </xsl:for-each>
            </ul>
          </td>
        </tr>

        <xsl:apply-templates select='.' mode='footer'/>
      </table>
    </div>
    <xsl:apply-templates select="foil"/>
  </xsl:template>

  <xsl:template match='foilgroup' mode='footer'>
  </xsl:template>

  <xsl:template match="foil">
    <xsl:call-template name="anchor">
      <xsl:with-param name="conditional" select="0"/>
    </xsl:call-template>
    <div class="slide">
      <table class="foil" cellspacing="0" cellpadding="0" border="0">
        <tr>
          <th class="foil" colspan="2">
            <xsl:apply-templates select="title" mode="show"/>
          </th>
        </tr>
        <tr>
          <td class="foil" colspan="2">
            <xsl:apply-templates/>
          </td>
        </tr>

        <xsl:apply-templates select='.' mode='footer'/>
      </table>
    </div>
  </xsl:template>

  <xsl:template match='*' mode='footer'>
    <tr>
      <td class="footer" colspan='2'>
        <xsl:call-template name="postfooter"/>
      </td>
    </tr>

    <tr>
      <td colspan='2' class='prefooter'>
        <xsl:apply-templates select="//slidesinfo/copyright"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="speakernotes"></xsl:template>

  <xsl:template match="foilinfo"></xsl:template>

  <xsl:template match="foil/title"></xsl:template>

  <xsl:template match="foilgroup/title"></xsl:template>

  <xsl:template match="foilgroup/title" mode="show">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="foil/title" mode="show">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="navigation">
    <div class="navigation">
      <a href="#" onclick="gohome(this)">
        <img src="plain/active/nav-home.png" alt="home" onmouseover="activate(this)" onmouseout="deactivate(this)"/>
      </a>
      <a href="#" onclick="gotoc(this)">
        <img src="plain/active/nav-toc.png" alt="Table of contents" onmouseover="activate(this)" onmouseout="deactivate(this)"/>
      </a>
      <a href="#" onclick="prev(this)">
        <img src="plain/active/nav-prev.png" alt="previous slide" onmouseover="activate(this)" onmouseout="deactivate(this)"/>
      </a>
      <a href="#" onclick="goup(this)">
        <img src="plain/active/nav-up.png" alt="previous slide" onmouseover="activate(this)" onmouseout="deactivate(this)"/>
      </a>
      <a href="#" onclick="next(this)">
        <img src="plain/active/nav-next.png" alt="next slide" onmouseover="activate(this)" onmouseout="deactivate(this)"/>
      </a>
    </div>
  </xsl:template>

  <xsl:template match='subtitle'>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="postfooter">
    <xsl:value-of select="/slides/slidesinfo/title"/>

    <xsl:if test='/slides/slidesinfo/subtitle'>
      <xsl:text> / </xsl:text>
      <xsl:value-of select="/slides/slidesinfo/subtitle"/>
    </xsl:if>

    <xsl:text> / </xsl:text>

    <span class="index">
      <xsl:value-of select="count(preceding::foil)+ count(preceding::foilgroup)+ count(ancestor::foilgroup)+ 1"/>
    </span>
  </xsl:template>

  <xsl:template match="mediaobject[@role]">
    <div class="{@role}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="slidesinfo/author">
    <div class='affiliation'>
      <xsl:apply-templates mode="titlepage.mode" select="./contrib"/>
      <xsl:apply-templates mode="titlepage.mode" select="./affiliation"/>
    </div>

    <div class='person'>
      <xsl:call-template name="person.name"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select='email'/>
    </div>
  </xsl:template>

  <xsl:template match='affiliation' mode='titlepage.mode'>
    <xsl:apply-templates select='orgname'/>
  </xsl:template>

  <xsl:template match="copyright">
    <span class="{name(.)}">
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
      <xsl:call-template name="holder"/>
    </span>
  </xsl:template>

  <xsl:template match='foreignphrase[@role]'>
    <span class='{@role}'>
      <xsl:apply-imports/>
    </span>
  </xsl:template>

  <xsl:template match='phrase[@role]'>
    <xsl:choose>
      <xsl:when test='starts-with(@role, "onclick:")'>
        <span onclick='{substring-after(@role, "onclick:")}(this)'>
          <xsl:apply-imports/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

