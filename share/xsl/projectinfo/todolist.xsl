<?xml version='1.0'?>

<!--+
    | Author:         Jean-Baptiste Quenot <jb.quenot@caraldi.com>
    | Purpose:        Stylesheet to view todo list
    | Date Created:   2004-08-23 09:41:54
    | Revision:       $Id: xmlstyle 447 2004-01-30 13:13:52Z jbq $
    +-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl"
  version='1.0'>
  <xsl:include href='common.xsl'/>
  <xsl:output method='html' indent='yes'/>

  <xsl:param name='doc'/>
  <xsl:param name='datecreated' select='0'/>
  <!-- If priority is set, show only todo with given priority -->
  <xsl:param name='priority' select="'high normal low'"/>
  <!-- If uid is set, do not show todo from other users -->
  <xsl:param name='uid'/>

  <xsl:template match='/'>
    <html>
      <head>
        <title>Todo List</title>
        <link rel='stylesheet' href='/css/tabledata.css'/>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO8859-15"/>
      </head>

      <body onload="if (parent.adjustIFrameSize)
                        parent.adjustIFrameSize(window);">
        <xsl:apply-templates select='todolist'/>
        <xsl:apply-templates select='error'/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match='todolist'>
    <table cellspacing='0' cellpadding='0' border='0' class='todolist'>
      <thead>
        <tr>
          <xsl:if test='$datecreated'>
            <th>Date Created</th>
          </xsl:if>
          <th>DateDue</th>
          <th>UserId</th>
          <th>Title</th>
          <th>Description</th>
        </tr>
      </thead>

        <!-- todo with a datedue: do not show closed todo -->
        <!-- cannot use apply-templates because the nodes won't return their
        sorted position() -->
      <xsl:variable name="tbody">
        <tbody>
          <xsl:for-each select='todo
            [not(@status="closed") and (not($uid) or @uid = $uid)]'>
            <xsl:sort select='datedue//timestamp' data-type='number'/>

            <xsl:variable name='styleClass'>
              <xsl:call-template name='styleClass'/>
            </xsl:variable>

            <xsl:variable name='priority.condition'>
              <xsl:call-template name='priority.condition'/>
            </xsl:variable>
            <!--tr>
              <td colspan="4"><xsl:value-of select=".//@priority"/></td>
            </tr-->

            <xsl:if test='$priority.condition = "true"'>
              <tr class="{$styleClass}">
                <xsl:call-template name='todo-content'/>
              </tr>
            </xsl:if>
          </xsl:for-each>
        </tbody>
      </xsl:variable>

      <!--+
          | This « hack » to keep rows in a variable and use exsl:node-set()
          | is apparently needed because position() does not return the
          | position of sorted nodes, but the position of the node in its
          | XML context.  We need the *sorted* position, ie the row index.
          +-->
      <tbody>
        <xsl:for-each select="exsl:node-set($tbody)/node()/tr">
          <tr class="color{position() mod 2} {@class}">
            <xsl:copy-of select="node() | @* [local-name() != 'class']"/>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name='styleClass'>
    <xsl:if test="@priority">
      <xsl:text> </xsl:text>
      <xsl:value-of select='@priority'/>
      <xsl:text>-priority</xsl:text>
    </xsl:if>

    <xsl:if test='datedue/relative'>
      <xsl:for-each select='datedue/relative/*'>
        <xsl:text> </xsl:text>
        <xsl:value-of select='local-name(.)'/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name='priority.condition'>
    <xsl:choose>
      <xsl:when test='(@priority and contains($priority, @priority) or not(@priority) and contains($priority, "normal"))
        and (normalize-space(description/text()) or description/*) or datedue/relative/past or
        datedue/relative/near-future'>
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:when test="not($priority) and
        (normalize-space(description/text()) or description/*)">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='personname'>
    <!--a>
      <xsl:attribute name='href'>
        <xsl:text>http://OpenSourceConsulting.info/address-book/search.do?name=</xsl:text>
        <xsl:apply-templates/>
      </xsl:attribute>

      <xsl:apply-templates/>
    </a-->
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="item">
    <xsl:if test="@uid">
      <b><xsl:value-of select="@uid"/></b>
      <xsl:text>: </xsl:text>
    </xsl:if>

    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match='item'>
    <xsl:variable name="item.priority">
      <xsl:choose>
        <xsl:when test="@priority">
          <xsl:value-of select="@priority"/>
        </xsl:when>

        <xsl:otherwise>
          <xsl:text>normal</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test='contains($priority, $item.priority) or ../../datedue/relative/past or ../../datedue/relative/near-future'>
        <li class='{$item.priority}-priority'>
          <xsl:call-template name='item'/>
        </li>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='itemizedlist'>
    <xsl:apply-templates select='title'/>
    <ul class='itemizedlist'>
      <xsl:apply-templates select='item'/>
    </ul>
  </xsl:template>

  <xsl:template match='itemizedlist/title'>
    <p><b><xsl:apply-templates/></b></p>
  </xsl:template>

  <xsl:template name='todo-content'>
    <xsl:if test='$datecreated'>
      <td class='datecreated'>
        <xsl:value-of select='datecreated/ndate'/>
      </td>
    </xsl:if>
    <xsl:choose>
      <xsl:when test='datedue'>
        <td class='datedue'>
          <xsl:choose>
            <xsl:when test='datedue/relative/today | datedue/relative/tomorrow |
              datedue/relative/yesterday'>
              <xsl:apply-templates select='datedue/relative/today |
                datedue/relative/tomorrow | datedue/relative/yesterday'/>
            </xsl:when>

            <xsl:otherwise>
              <xsl:value-of select='datedue//ndate'/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test='datedue//time'>
            <xsl:text> à </xsl:text><xsl:value-of select='datedue//ntime'/>
          </xsl:if>
        </td>
      </xsl:when>

      <xsl:otherwise>
        <td>&#160;</td>
      </xsl:otherwise>
    </xsl:choose>
    <td class='uid'>
      <xsl:choose>
        <xsl:when test='@uid'>
          <b>
            <xsl:call-template name="todolist.link">
              <xsl:with-param name="uid" select="@uid"/>
              <xsl:with-param name="text" select="@uid"/>
            </xsl:call-template>
          </b>
        </xsl:when>

        <xsl:otherwise>
          &#160;
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td class='title'>
      <a name="{@id}"/>
      <xsl:apply-templates select='title'/>
    </td>
    <td class='description'>
      <xsl:choose>
        <xsl:when test='normalize-space(description/text()) or description/*'>
          <xsl:apply-templates select='description'/>
        </xsl:when>

        <xsl:otherwise>
          <xsl:text>&#160;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </xsl:template>

  <xsl:template match='description'>
    <xsl:apply-templates select="text() | body"/>

    <xsl:if test='item'>
      <ul>
        <xsl:apply-templates select='item'/>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match='error'>
    <p style='color: red'><xsl:value-of select='message'/></p>
    <xsl:comment><xsl:value-of select='traceback'/></xsl:comment>
  </xsl:template>

  <xsl:template match='ulink'>
    <a href='{@url}'>
      <xsl:choose>
        <xsl:when test='text()'>
          <xsl:value-of select='.'/>
        </xsl:when>

        <xsl:otherwise>
          <xsl:value-of select='@url'/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match='today'>
    <span class='today'>
      <xsl:text>Aujourd'hui</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match='yesterday'>
    <span class='yesterday'>
      <xsl:text>Hier</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match='tomorrow'>
    <span class='tomorrow'>
      <xsl:text>Demain</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match='screen'>
    <pre class='screen'>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>

  <xsl:template match='literal'>
    <tt class='literal'>
      <xsl:apply-templates/>
    </tt>
  </xsl:template>

  <xsl:template match="command">
    <tt class='command'>
      <xsl:apply-templates/>
    </tt>
  </xsl:template>
</xsl:stylesheet>
