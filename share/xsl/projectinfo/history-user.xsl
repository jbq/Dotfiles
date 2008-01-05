<?xml version='1.0'?>

<!--+
    | Author:         Jean-Baptiste Quenot <jb.quenot@caraldi.com>
    | Purpose:        Stylesheet to view project history
    | Date Created:   2004-08-23 09:43:06
    | Revision:       $Id: project-history.xsl 870 2004-08-27 09:29:50Z jbq $
    |
    | TODO group todo with same id
    +-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl" version='1.0'>
  <xsl:include href='common.xsl'/>

  <!-- Provide history for each session? -->
  <xsl:param name='details' select='0'/>
  <xsl:param name='sortOrder' select="'ascending'"/>
  <xsl:param name="dpid"/>
  <xsl:param name="show.columns" select="'title timespent sessions'"/>

  <xsl:output method='html' indent='yes'/>

  <xsl:template match='/'>
    <html>
      <head>
        <title>Project History</title>
        <link rel='stylesheet' href='/css/tabledata.css'/>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO8859-15"/>
      </head>

      <body>
        <xsl:apply-templates select='todolist'/>
        <xsl:apply-templates select='error'/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match='todolist'>
    <table>
      <thead>
        <tr>
          <td>User Id</td>
          <td>Total Time Spent
            <xsl:call-template name="timespent">
              <xsl:with-param name="node" select="//todo/sessions/session[not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]"/>
            </xsl:call-template>
          </td>
        </tr>
      </thead>

      <tbody>
        <xsl:variable name="sessionsSortedByUser">
          <xsl:for-each select="//todo/sessions/session[@uid][not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]">
            <xsl:sort select='@uid'/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="distinctUsers" select="exsl:node-set($sessionsSortedByUser)/node()[position() = last() or not(following-sibling::*/@uid=@uid)]"/>
        <xsl:variable name="rootNode" select="/"/>

        <xsl:for-each select="$distinctUsers">
          <tr class="color{position() mod 2}">
            <xsl:call-template name='todo-content'>
              <xsl:with-param name="todocount" select="count(exsl:node-set($distinctUsers))"/>
              <xsl:with-param name="rootNode" select="$rootNode"/>
            </xsl:call-template>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name='todo-content'>
    <xsl:param name="todocount"/>
    <xsl:param name="rootNode"/>

    <xsl:variable name="currentUid" select="@uid"/>

    <td class='uid'>
      <a name='{@uid}'/>
      <b><xsl:value-of select='@uid'/></b>
    </td>

    <td>
      <xsl:call-template name="timespent">
        <xsl:with-param name="node" select="$rootNode//todo/sessions/session[@uid][@uid=$currentUid]
          [not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]"/>
      </xsl:call-template>
    </td>
  </xsl:template>
</xsl:stylesheet>
