<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
  <xsl:template match="/">
    <document>
      <xsl:apply-templates/>
    </document>
  </xsl:template>

  <xsl:template match="table | informaltable [@id][descendant::entry/@role='total']">
    <total id="{@id}.2">
      <entry role="total">
        <xsl:value-of select="sum(tgroup/tbody/row/entry[not(@role='total')][2])"/>
      </entry>
    </total>

    <xsl:if test="tgroup/tbody/row/entry[3]">
      <total id="{@id}.3">
        <entry role="total">
          <xsl:value-of select="sum(tgroup/tbody/row/entry[not(@role='total')][3])"/>
        </entry>
      </total>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text()"/>
</xsl:stylesheet>
