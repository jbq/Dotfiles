<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
  <xsl:output encoding='UTF-8' method='html'/>
  <xsl:template match='/'>
    <html>
      <head>
        <title>Contact List</title>
        <link rel='stylesheet' href='/css/tabledata.css'/>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO8859-15"/>
      </head>

      <body>
        <table>
          <thead>
            <td>Nom</td>
            <td>Prénom</td>
            <td>Société</td>
            <td>Téléphone</td>
            <td>Adresse</td>
          </thead>

          <tbody>
            <xsl:apply-templates/>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match='contactlist'>
    <xsl:for-each select='contact'>
      <xsl:sort select='concat(surname,orgname)'/>

      <tr class="color{position() mod 2}">
        <xsl:call-template name='contact-content'/>
      </tr>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name='contact-content'>
    <td>
      <b><xsl:value-of select='surname'/></b>
    </td>

    <td>
      <xsl:value-of select='firstname'/>
    </td>

    <td>
      <b><xsl:value-of select='orgname'/></b>
      <xsl:if test='orgdiv'><dt><xsl:value-of select='orgdiv'/></dt></xsl:if>
    </td>

    <td>
      <ul class='phone'>
        <xsl:for-each select='phone|location/phone'>
          <li>
            <xsl:if test='@location'>
              <xsl:value-of select='@location'/>:
            </xsl:if>

            <xsl:apply-templates/>
          </li>
        </xsl:for-each>
      </ul>
    </td>

    <td>
      <xsl:if test='location'>
        <xsl:apply-templates select='location'/>
      </xsl:if>
    </td>
  </xsl:template>

  <xsl:template match='location'>
    <ul class='location'>
      <xsl:for-each select='address'>
        <li><xsl:apply-templates/></li>
      </xsl:for-each>

      <li>
        <xsl:value-of select='postcode'/>
        <xsl:text> </xsl:text>
        <xsl:value-of select='city'/>
      </li>
    </ul>
  </xsl:template>
</xsl:stylesheet>
