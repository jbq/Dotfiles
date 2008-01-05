<?xml version='1.0'?>

<!--+
    | Author:         Jean-Baptiste Quenot <jbq@anyware-tech.com>
    | Purpose:        Stylesheet to view project history
    | Date Created:   2004-08-23 09:43:35
    | Revision:       $Id: xmlstyle 447 2004-01-30 13:13:52Z jbq $
    +-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
  <xsl:include href='common.xsl'/>
  <!--+
      | Create an index of session items with their respective date of execution
      | and todo title
      +-->
  <xsl:key name='sessionsParDate' match='//session' use="daytimestamp | from/daytimestamp"/>

  <xsl:param name='doc'/>
  <!-- Provide history for each session? -->
  <xsl:param name='details' select='0'/>
  <xsl:param name='sortOrder' select="'ascending'"/>
  <xsl:param name='uid'/>
  <xsl:param name="dpid"/>
  <xsl:param name='exact.role'/>
  <xsl:param name='role'/>
  <xsl:param name='timespent' select="0"/>

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
        <xsl:call-template name="projectinfo"/>
        <xsl:apply-templates select="error"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template name='projectinfo'>
    <table cellspacing='0' cellpadding='0' border='0'>
      <thead>
        <tr>
          <td>Date</td>
          <td>Title</td>
          <td>User Id</td>
          <xsl:if test="$timespent">
            <td>Time Spent</td>
          </xsl:if>
          <td>Sessions</td>
        </tr>
      </thead>

      <tbody>
        <!-- For each date -->
        <xsl:for-each select='//session [generate-id() =
          generate-id(key("sessionsParDate", daytimestamp | from/daytimestamp) [1])]'>
          <xsl:sort select='daytimestamp | from/daytimestamp' order='{$sortOrder}'/>
          <xsl:variable name='datePosition'>
            <xsl:value-of select='position()'/>
          </xsl:variable>
          <!--+
              | For each session at this date matching parameter uid (no
              | parameter uid, or session matches uid, or session does not have
              | uid and todo has and matches requested uid)
              +-->
        <xsl:variable name="allSessionsForCurrentDate" select='key("sessionsParDate", daytimestamp | from/daytimestamp)'/>
        <xsl:variable name="visibleSessions" select='$allSessionsForCurrentDate
          [not($exact.role) or item/@role = $exact.role]
          [not($role) or contains(item/@role, $role)]
          [not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid]
          [not($uid) or @uid = $uid or (not(@uid) and ../../@uid = $uid)]'/>
        <xsl:for-each select='$visibleSessions'>
            <xsl:sort select='from/timestamp' order='{$sortOrder}'/>
            <tr class="color{$datePosition mod 2}">
              <xsl:if test='position() = 1'>
                <td rowspan='{last()}'>
                  <xsl:value-of select='ndate | from/ndate'/>
                </td>
              </xsl:if>

              <td>
                <b>
                  <xsl:if test="ancestor-or-self::node()/@hidden">
                    <xsl:attribute name="class">hidden</xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select='../../title'/>
                  (<xsl:choose>
                    <xsl:when test="ancestor-or-self::node()[@dpid][1]/@dpid">
                      <a class="dpid">
                        <xsl:attribute name="href">
                          <xsl:text>http://neo/dotproject/index.php?m=tasks&amp;a=view&amp;task_id=</xsl:text>
                          <xsl:value-of select="ancestor-or-self::node()[@dpid][1]/@dpid"/>
                        </xsl:attribute>
                        <xsl:choose>
                          <xsl:when test="@dpTask">
                            <xsl:value-of select="@dpTask"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="ancestor-or-self::node()[@dpid][1]/@dpid"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </a>
                    </xsl:when>

                    <xsl:otherwise>
                      <xsl:text>n/a</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>)
                </b>
              </td>

              <td>
                <!-- @uid from session or todo -->
                <xsl:choose>
                  <xsl:when test='@uid'>
                    <b>
                      <xsl:call-template name="history.link">
                        <xsl:with-param name="uid" select="@uid"/>
                        <xsl:with-param name="text" select="@uid"/>
                      </xsl:call-template>
                    </b>
                  </xsl:when>

                  <xsl:when test='../../@uid'>
                    <b>
                      <xsl:call-template name="history.link">
                        <xsl:with-param name="uid" select="../../@uid"/>
                        <xsl:with-param name="text" select="../../@uid"/>
                      </xsl:call-template>
                    </b>
                  </xsl:when>

                  <xsl:otherwise>
                    &#160;
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <xsl:variable name="current.uid" select="@uid"/>
              <xsl:if test="$timespent">
              <td>
                <xsl:choose>
                  <xsl:when test='timespent/seconds != 28800'>
                    <xsl:value-of select='timespent/representation'/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="ancestor-or-self::node()/@hidden">
                        n/a
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="round((8 - (sum($allSessionsForCurrentDate[@uid = $current.uid]/timespent/seconds) div 3600))
                          div count($allSessionsForCurrentDate[@uid = $current.uid][not(ancestor-or-self::node()/@hidden) and not(timespent)]) * 100) div 100"/>&#160;h
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              </xsl:if>

              <td>
                <xsl:if test='$details'>
                  <xsl:choose>
                    <xsl:when test="item">
                      <ul class="items">
                        <xsl:apply-templates select="item"/>
                      </ul>
                    </xsl:when>

                    <xsl:otherwise>
                      <xsl:apply-templates select="body"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:if>
              </td>
            </tr>
          </xsl:for-each>
        </xsl:for-each>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match='itemizedlist'>
    <ul>
      <xsl:apply-templates select='listitem'/>
    </ul>
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

  <xsl:template match='item'>
    <xsl:if test="not($role or $exact.role) or $role and contains(@role, $role) or $exact.role and @role = $exact.role">
    <li>
      <xsl:if test="@role">
        <b>
          <xsl:value-of select="@role"/>
          <xsl:text>: </xsl:text>
        </b>
      </xsl:if>
      <xsl:apply-templates/>
    </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="body/ul[not(normalize-space(preceding-sibling::text()) or preceding-sibling::*)]" mode="html">
    <ul class="items">
      <xsl:apply-templates mode="html"/>
    </ul>
  </xsl:template>

  <xsl:template match='session/from | session/to | session/timespent'/>
</xsl:stylesheet>
