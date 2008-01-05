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
  <!-- Create an index of session items with their respective date of execution
  and todo title -->
  <xsl:key name='sessionsByDateAndUser' match='//session'
    use="concat(daytimestamp | from/daytimestamp, '-', @uid)"/>

  <xsl:key name='sessionsByUid' match='//session' use="@uid"/>

  <xsl:key name='sessionsByDateUserTask' match='//session'
    use="concat(daytimestamp | from/daytimestamp, '-', @uid, '-', ../../@id)"/>

  <xsl:key name='sessionsByDateTask' match='//session'
    use="concat(daytimestamp | from/daytimestamp, '-', ../../@id)"/>

  <!-- Provide history for each session? -->
  <xsl:param name='details' select='0'/>
  <xsl:param name='sortOrder' select="'ascending'"/>
  <xsl:param name="dpid"/>
  <xsl:param name="hidden" select="1"/>
  <xsl:param name="show.columns" select="'title timespent sessions'"/>
  <xsl:param name="show.session.uid" select="0"/>

  <xsl:output method='html' indent='yes'/>

  <xsl:template match='/'>
    <html>
      <head>
        <title>Project History</title>
        <style type="text/css">
          <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="../../css/tabledata.css" parse="text"/>
        </style>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO8859-15"/>
      </head>

      <body>
        <xsl:apply-templates select='todolist'/>
        <xsl:apply-templates select='error'/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match='todolist'>
    <table class="history">
      <thead>
        <tr>
          <td>Title</td>
          <xsl:if test="contains($show.columns, 'uid')">
            <td>User Id</td>
          </xsl:if>
          <xsl:if test="contains($show.columns, 'status')">
            <td>Status</td>
          </xsl:if>
          <td>Time Spent

            <xsl:call-template name="timespent">
              <xsl:with-param name="node" select="descendant::sessions/session[not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]"/>
            </xsl:call-template>
          </td>
          <td>Sessions</td>
        </tr>
      </thead>

      <tbody>
        <xsl:variable name="todo" select="projectinfo/todo[sessions/session][not($hidden) or not(@hidden)][not($dpid) or $dpid = descendant-or-self::node()[not($hidden) or not(@hidden)]/@dpid]"/>
        <!-- cannot use apply-templates because the nodes won't return their
          sorted position() -->
        <!--+
            | $dpid = descendant-or-self::node()/@dpid will return true if one
            | of the nodes has the right dpid.
            |
            | If one object to be compared is a node-set and the other is a
            | string, then the comparison will be true if and only if there is
            | a node in the node-set such that the result of performing the
            | comparison on the string-value of the node and the other string is
            | true.
            |
            | See http://www.w3.org/TR/xpath#predicates
            +-->
        <xsl:for-each select='$todo'>
          <!--xsl:sort select='sessions/timespent/seconds' data-type='number' order='descending'/-->
          <xsl:sort select='title'/>
          <tr class="color{position() mod 2}">
            <xsl:call-template name='todo-content'>
              <xsl:with-param name="todocount" select="count($todo)"/>
            </xsl:call-template>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match='itemizedlist'>
    <ul>
      <xsl:apply-templates select='listitem'/>
    </ul>
  </xsl:template>

  <xsl:template name='todo-content'>
    <xsl:param name="todocount"/>
    <td class='title'>
      <a name='{@id}'/>
      <xsl:value-of select='title'/>
      <!--<xsl:value-of select='generate-id(.)'/>-->
    </td>

    <xsl:if test="contains($show.columns, 'uid')">
      <td class='uid'>
        <a name='{@uid}'/>
        <b><xsl:value-of select='@uid'/></b>
      </td>
    </xsl:if>

    <xsl:if test="contains($show.columns, 'status')">
      <td class='status'>
        <xsl:choose>
          <xsl:when test='@status'>
            <xsl:value-of select='@status'/>
          </xsl:when>

          <xsl:otherwise>
            open
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </xsl:if>

    <td class='timespent'>
      <p>
        <xsl:variable name="total">
          <total>
            <xsl:call-template name='compute-timespent'>
              <xsl:with-param name="node" select="sessions/session
                [not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]"/>
            </xsl:call-template>
          </total>

          <xsl:if test="$hidden">
            <bonus>
              <xsl:call-template name='compute-timespent'>
                <xsl:with-param name="node" select="//todo/sessions/session
                  [ancestor-or-self::node()/@hidden]
                  [not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]"/>
              </xsl:call-template>
            </bonus>
          </xsl:if>
        </xsl:variable>

        <xsl:value-of select="round((sum(exsl:node-set($total)/total/subtotal) + sum(exsl:node-set($total)/bonus/subtotal) div $todocount) div 3600 div 8 * 100) div 100"/>&#160;j
      </p>
      <!--<p>From <xsl:value-of select='sessions/session[1]/from/ndate'/>
      to <xsl:value-of select='sessions/session[last()]/from/ndate'/></p>-->
    </td>
    <td class='sessions'><xsl:apply-templates select='sessions'/></td>
  </xsl:template>

  <xsl:template match='error'>
    <p style='color: red'><xsl:value-of select='message'/></p>
    <xsl:comment><xsl:value-of select='traceback'/></xsl:comment>
  </xsl:template>

  <xsl:template match='today'>
    <span class='today'>
      <xsl:text>Aujourd'hui</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match='tomorrow'>
    <span class='tomorrow'>
      <xsl:text>Demain</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match='sessions'>
    <xsl:choose>
      <xsl:when test='$details'>
        <xsl:variable name='sessionsWithDistinctDateForCurrentTask' select="session[not($hidden) or not(@hidden)] [ generate-id () =
          generate-id (key ('sessionsByDateTask',
          concat (daytimestamp | from/daytimestamp, '-', ../../@id)) [1])]"/>
        <xsl:variable name="result">
        <xsl:for-each select='$sessionsWithDistinctDateForCurrentTask'>
          <xsl:sort select='daytimestamp | from/daytimestamp' order='{$sortOrder}'/>
          <xsl:variable name="sessionsWithCurrentDateForCurrentTask" select="key ('sessionsByDateTask',
            concat (daytimestamp | from/daytimestamp, '-', ../../@id))
            [not($hidden) or not(@hidden)][not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]"/>
          <xsl:if test="$sessionsWithCurrentDateForCurrentTask/item | $sessionsWithCurrentDateForCurrentTask/body">
            <div>
              <xsl:call-template name='sessionItems'/>
            </div>
          </xsl:if>
        </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="exsl:node-set($result)/node()">
          <xsl:if test="not(position() = 1)">
            <hr/>
          </xsl:if>
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>From </xsl:text>
        <xsl:value-of select='minFrom/ndate'/>
        <xsl:text> to </xsl:text>
        <xsl:value-of select='maxTo/ndate'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name='sessionItems'>
    <span class="date"><xsl:value-of select='ndate|from/ndate'/></span>
      <xsl:variable name="currentSession" select="."/>
      <xsl:variable name="sessionsWithCurrentDateTask" select="key ('sessionsByDateTask',
        concat (daytimestamp | from/daytimestamp, '-', ../../@id))
        [not($hidden) or not(@hidden)][not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]"/>
      <xsl:for-each select="$sessionsWithCurrentDateTask[position() = last() or not(following-sibling::*/@uid=@uid)]">
        <xsl:sort select="@uid"/>
        <xsl:variable name="sessions" select='key("sessionsByDateUserTask",
          concat($currentSession/daytimestamp | $currentSession/from/daytimestamp, "-", @uid, "-", $currentSession/../../@id))
          [not($hidden) or not(@hidden)][not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]'/>
        <div class="session">
        <xsl:choose>
          <xsl:when test="$sessions/item">
              <xsl:if test='@uid and $show.session.uid'>
                <span class="uid"><xsl:value-of select='@uid'/></span>:
              </xsl:if>

              <xsl:if test="@role">
                <b>
                  <i>
                    <xsl:value-of select="@role"/>
                    <xsl:text>: </xsl:text>
                  </i>
                </b>
              </xsl:if>
              <ul>
                <xsl:apply-templates select="$sessions/item"/>
              </ul>
          </xsl:when>

          <xsl:otherwise>
            <xsl:apply-templates select="$sessions/body"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      </xsl:for-each>
  </xsl:template>

    <xsl:template match="item">
      <li>
        <xsl:apply-templates/>
      </li>
    </xsl:template>

  <xsl:template match="body">
    <xsl:if test='../@uid and $show.session.uid'>
      <span class="uid">
        <xsl:value-of select='../@uid'/>:
      </span>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="html"/>
  </xsl:template>
</xsl:stylesheet>
