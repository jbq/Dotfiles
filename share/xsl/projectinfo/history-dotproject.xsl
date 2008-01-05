<?xml version='1.0'?>

<!--+
    | Author:         Jean-Baptiste Quenot <jbq@anyware-tech.com>
    | Purpose:        Stylesheet to view project history
    | Date Created:   2004-08-23 09:43:35
    | Revision:       $Id: xmlstyle 447 2004-01-30 13:13:52Z jbq $
    |
    | TODO: param uid can have multiple values!
    +-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
  <xsl:include href='common.xsl'/>
  <!--+
      | Create an index of session items with their respective date of execution
      | and todo title
      +-->
  <xsl:key name='sessionsParDate' match='//session'
    use="concat(daytimestamp | from/daytimestamp, '-', @uid)"/>

  <!-- Provide history for each session? -->
  <xsl:param name='details' select='0'/>
  <xsl:param name='sortOrder' select="'ascending'"/>
  <xsl:param name='uid'/>
  <xsl:param name="dpid"/>
  <xsl:param name="itemTitle"/>

  <xsl:output method='xml' indent="yes"/>

  <xsl:template match='/'>
    <task_logs>
      <xsl:call-template name="projectinfo"/>
      <xsl:apply-templates select="error"/>
    </task_logs>
  </xsl:template>

  <xsl:template name='projectinfo'>
    <!-- Pour chaque date trouvée dans la première sessions du groupe -->
    <xsl:for-each select='//session [generate-id() =
      generate-id(key("sessionsParDate", concat(daytimestamp | from/daytimestamp, "-", @uid))
      [1])]'>
      <xsl:sort select='daytimestamp | from/daytimestamp' order='{$sortOrder}'/>

      <!--+
          | For each session at this date matching parameter uid (no
          | parameter uid, or session matches uid, or session does not have
          | uid and todo has and matches requested uid)
          |
          | Having attributes "uid" and "dpid"
          +-->
      <xsl:variable name="sessions" select='key("sessionsParDate", concat(daytimestamp | from/daytimestamp, "-", @uid))'/>
      <xsl:for-each select='$sessions
        [ancestor-or-self::node()/@uid and not($uid) or (ancestor-or-self::node()/@uid = $uid)]
        [not(ancestor-or-self::node()/@dpid)]'>
        <error>-- No dpid for <xsl:value-of select="@uid"/> on <xsl:value-of select="ndate | from/ndate"/> in task <xsl:value-of select="../../@id"/></error>
      </xsl:for-each>
      <xsl:for-each select='$sessions
        [ancestor-or-self::node()/@uid]
        [ancestor-or-self::node()/@dpid and (not($dpid) or $dpid = ancestor-or-self::node()[@dpid][1]/@dpid)]
        [not($uid) or (ancestor-or-self::node()/@uid = $uid)]'>
        <xsl:sort select='from/timestamp' order='{$sortOrder}'/>
        <task_log>
          <xsl:comment>
            <xsl:value-of select="translate(item, '-', '')"/>
          </xsl:comment>
          <task_log_task>
            <xsl:value-of select='ancestor-or-self::node()[@dpid][1]/@dpid'/>
          </task_log_task>
          <task_log_name type="string">
            <xsl:choose>
              <xsl:when test="$itemTitle">
                <xsl:value-of select="item"/>
              </xsl:when>
              <xsl:when test="@dpTitle">
                <xsl:value-of select="@dpTitle"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select='../../title'/>
              </xsl:otherwise>
            </xsl:choose>
          </task_log_name>

          <task_log_creator>
            <!-- @uid from session or todo -->
            <xsl:value-of select="ancestor-or-self::node()/@dpUserID"/>
          </task_log_creator>

          <task_log_hours>
            <xsl:choose>
              <xsl:when test='timespent/seconds != 28800'>
                <xsl:value-of select='timespent/seconds div 3600'/>
              </xsl:when>
              <!--+
                  | This session is not an interval, so we have to substract
                  | from full day (8 hours) the sum of all intervals in other
                  | sessions
                  +-->
              <xsl:when test="$sessions/timespent">
                <xsl:value-of select="(8 - (sum($sessions/timespent/seconds) div 3600)) div count($sessions[not(ancestor-or-self::node()/@hidden) and not(timespent)])"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="8 div last()"/>
              </xsl:otherwise>
            </xsl:choose>
          </task_log_hours>

          <task_log_date type="string">
            <xsl:value-of select='datetime | from/datetime'/>
          </task_log_date>

        </task_log>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match='error'>
    <p style='color: red'><xsl:value-of select='message'/></p>
    <xsl:comment><xsl:value-of select='traceback'/></xsl:comment>
  </xsl:template>

  <xsl:template match='session/from | session/to | session/timespent'/>
</xsl:stylesheet>
