<?xml version='1.0'?>

<!--+
    | Author:         Jean-Baptiste Quenot <jb.quenot@caraldi.com>
    | Purpose:        Common templates for project info stylesheets
    | Date Created:   2004-08-23 09:44:47
    | Revision:       $Id: xmlstyle 447 2004-01-30 13:13:52Z jbq $
    +-->

<xsl:stylesheet xmlns:exsl="http://exslt.org/common" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="exsl" version='1.0'>
  <!-- Create an index of session items with their respective date of execution
  and todo title -->
  <xsl:key name='sessionsByDateAndUser' match='//session'
    use="concat(daytimestamp | from/daytimestamp, '-', @uid)"/>

  <xsl:template match='ulink'>
    <a href='{@url}'>
      <xsl:value-of select='.'/>
    </a>
  </xsl:template>

  <xsl:template match='a|tt|b'>
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match='literallayout'>
    <pre class='literallayout'>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>

  <xsl:template name="history.link">
    <xsl:param name="doc" select="$doc"/>

    <xsl:param name="details" select="$details"/>
    <xsl:param name="sortOrder" select="$sortOrder"/>
    <xsl:param name="view" select="$view"/>

    <xsl:param name="uid" select="$uid"/>

    <xsl:param name="text"/>

    <a>
      <xsl:attribute name="href">
        <xsl:text>?</xsl:text>
        <xsl:text>doc=</xsl:text>
        <xsl:value-of select="$doc"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>details=</xsl:text>
        <xsl:value-of select="$details"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>sortOrder=</xsl:text>
        <xsl:value-of select="$sortOrder"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>view=</xsl:text>
        <xsl:value-of select="$view"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>uid=</xsl:text>
        <xsl:value-of select="$uid"/>
      </xsl:attribute>

      <xsl:value-of select="$text"/>
    </a>
  </xsl:template>

  <xsl:template name="todolist.link">
    <xsl:param name="doc" select="$doc"/>

    <xsl:param name='datecreated' select='$datecreated'/>
    <!-- If priority.only is set, show only todo with high priority -->
    <xsl:param name='priority.only' select='$priority.only'/>

    <xsl:param name="uid" select="$uid"/>

    <xsl:param name="text"/>

    <a>
      <xsl:attribute name="href">
        <xsl:text>?</xsl:text>
        <xsl:text>doc=</xsl:text>
        <xsl:value-of select="$doc"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>datecreated=</xsl:text>
        <xsl:value-of select="$datecreated"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>priority.only=</xsl:text>
        <xsl:value-of select="$priority.only"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>uid=</xsl:text>
        <xsl:value-of select="$uid"/>
      </xsl:attribute>

      <xsl:value-of select="$text"/>
    </a>
  </xsl:template>

  <xsl:template match="body">
    <xsl:apply-templates mode="html"/>
  </xsl:template>

  <xsl:template match='@*|node()' mode="html">
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' mode="html"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="compute-timespent">
    <xsl:param name="node"/>

    <xsl:for-each select='$node'>
      <xsl:variable name="sessions" select='key("sessionsByDateAndUser", concat(daytimestamp | from/daytimestamp, "-", @uid))'/>
      <subtotal>
        <xsl:choose>
          <xsl:when test="timespent/seconds">
            <xsl:value-of select="timespent/seconds"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select='(3600 * 8 - sum($sessions/timespent/seconds)) div count($sessions[not(ancestor-or-self::node()/@hidden) and not(timespent)])'/>
          </xsl:otherwise>
        </xsl:choose>
      </subtotal>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="timespent">
    <xsl:param name="node"/>

    <xsl:variable name="total">
      <total>
        <xsl:call-template name='compute-timespent'>
          <xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
      </total>
    </xsl:variable>

    <xsl:value-of select="round(sum(exsl:node-set($total)/total/subtotal) div 3600 div 8 * 100) div 100"/>&#160;j
  </xsl:template>

  <xsl:template match='error'>
    <p style='color: red'><xsl:value-of select='message'/></p>
    <xsl:comment><xsl:value-of select='traceback'/></xsl:comment>
  </xsl:template>
</xsl:stylesheet>
