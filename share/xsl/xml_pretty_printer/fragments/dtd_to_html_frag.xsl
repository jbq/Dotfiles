<?xml version="1.0" encoding="iso-8859-1"?>

<!--
FILE : dtd_to_html_frag.xsl

CREATED : 27 March 2000

LAST MODIFIED : 7 August 2001

AUTHOR : Warren Hedley (w.hedley@auckland.ac.nz)
         Department of Engineering Science
         The University of Auckland

TERMS OF USE / COPYRIGHT : See the "Terms of Use" page on the Tools section
  of the physiome.org.nz website, at http://www.physiome.org.nz/

DESCRIPTION : This stylesheet fragment is used by other stylesheets to format
  any DTD document into an HTML representation. The containing HTML document
  must reference the "embedded_dtd.css" CSS stylesheet which contains the
  corresponding formatting instructions for the browser.

    Stylesheets that use this fragment should call the "embedded_dtd" template
  with a context node whose children will be rendered. This might be a document
  root node or an <embedded_dtd> element. The stylesheet makes use of templates
  declared with a mode of "embedded_dtd".

CHANGES :
  26/09/2000 - WJH - had to change $new_line to $embedded_dtd_new_line to avoid name
                     clash with xml_to_html.
  29/09/2000 - WJH - Fixed infinite loop problem where it was possible to look
                     for keywords with a number greater than the number of
                     keywords defined in this file if we find the last keyword.
  01/11/2000 - WJH - Made sure the dtd_to_html namespace was an extension.
  28/12/2000 - WJH - updated URL of dtd_to_html namespace to physiome.org.nz .
  15/05/2001 - WJH - added support for conditional sections.
  15/06/2001 - WJH - added $create_dtd_environment parameter to embedded_dtd
                     template so that it can be used to add DTD sections to
                     XML files created with xml_to_html.xsl. Split embedded_dtd
                     template into two.
  07/08/2001 - WJH - renamed top-level parameters and variables.
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtd_pretty_printer="http://www.physiome.org.nz/dtd_pretty_printer"
    exclude-result-prefixes="dtd_pretty_printer"
    version="1.0">

<!-- possible debugging options
                xmlns:saxon="http://icl.com/saxon"
                saxon:trace="yes">
-->


<xsl:param name="EMBEDDED_DTD_REPLACE_TABS_WITH" select="'&#160;&#160;'" />


<xsl:variable name="embedded_dtd_big_number" select="'1000000000'" />
<xsl:variable name="embedded_dtd_new_line" select="'&#xA;'" />
<xsl:variable name="embedded_dtd_keywords"
    select="document('')/xsl:stylesheet/dtd_pretty_printer:keywords/keyword" />
<xsl:variable name="num_embedded_dtd_keywords" 
    select="count($embedded_dtd_keywords)" />


<dtd_pretty_printer:keywords>
  <keyword>#IMPLIED</keyword>
  <keyword>#REQUIRED</keyword>
  <keyword>#FIXED</keyword>
  <keyword>#PCDATA</keyword>
  <keyword>CDATA</keyword>
  <keyword>SYSTEM</keyword>
  <keyword>PUBLIC</keyword>
  <keyword>NOTATION</keyword>
  <keyword>IDREFS</keyword>
  <keyword>ID</keyword>
  <keyword>ENTITY</keyword>
  <keyword>ENTITIES</keyword>
  <keyword>NMTOKENS</keyword>
  <keyword>NMTOKEN</keyword>
  <keyword>EMPTY</keyword>
  <keyword>ANY</keyword>
</dtd_pretty_printer:keywords>


<!--
  Entire DTD goes in <code class="dtd">, apart from
  anything between quotes (<code class="dtd-quoted">),
  and keywords (<code class="dtd-keyword">).
-->

<xsl:template name="embedded_dtd">
  <xsl:param name="drop_first_and_last_text_nodes_if_whitespace"
      select="'no'" />
  <xsl:param name="create_dtd_environment" select="'yes'" />

  <!--
    We put lots of carriage returns in the output - it makes using `View Source'
     in the browser on the resulting document that much nicer.
  -->
  <xsl:choose>
    <xsl:when test="$create_dtd_environment = 'yes'">
      <xsl:value-of select="$embedded_dtd_new_line" />
      <p class="embedded-dtd">
        <xsl:value-of select="$embedded_dtd_new_line" />
        <xsl:call-template name="embedded_dtd_process_embedded_dtd">
          <xsl:with-param
              name="drop_first_and_last_text_nodes_if_whitespace"
              select="$drop_first_and_last_text_nodes_if_whitespace" />
        </xsl:call-template>
        <xsl:value-of select="$embedded_dtd_new_line" />
      </p>
      <xsl:value-of select="$embedded_dtd_new_line" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="embedded_dtd_process_embedded_dtd">
        <xsl:with-param
            name="drop_first_and_last_text_nodes_if_whitespace"
            select="$drop_first_and_last_text_nodes_if_whitespace" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="embedded_dtd_process_embedded_dtd">
  <xsl:param name="drop_first_and_last_text_nodes_if_whitespace"
      select="'no'" />

  <xsl:for-each select="child::node()">
    <xsl:choose>
      <xsl:when test="self::comment()">
        <xsl:call-template name="embedded_dtd_process_comment" />
      </xsl:when>
      <xsl:when test="self::text()">
        <xsl:if
            test="$drop_first_and_last_text_nodes_if_whitespace != 'yes'
            or not(position() = 1 and normalize-space() = '') or
            not(position() = last() and normalize-space() = '')">
          <xsl:call-template name="embedded_dtd_process_top_level_text" />
        </xsl:if>
      </xsl:when>
      <xsl:when test="self::processing-instruction()">
        <xsl:call-template name="embedded_dtd_process_pi">
          <xsl:with-param name="pi_node">
            <xsl:value-of select="name()" />
            <xsl:text> </xsl:text>
            <xsl:value-of select="." />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>FATAL ERROR : unexpected </xsl:text>
          <xsl:text>content in embedded dtd - </xsl:text>
          <xsl:copy-of select="." />
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_comment

DESCRIPTION : 
=============================================================================-->
<xsl:template name="embedded_dtd_process_comment">
  <xsl:param name="comment_node" select="." />
  <code class="dtd-comment">
    <xsl:text>&lt;!--</xsl:text>
      <xsl:call-template name="embedded_dtd_process_text">
        <xsl:with-param name="input_text" select="$comment_node" />
      </xsl:call-template>
    <xsl:text>--&gt;</xsl:text>
  </code>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_pi

DESCRIPTION :

TODO : process pseudo attributes
=============================================================================-->
<xsl:template name="embedded_dtd_process_pi">
  <xsl:param name="pi_node" />

  <code class="dtd-pi">
    <xsl:text>&lt;?</xsl:text>
      <xsl:call-template name="embedded_dtd_process_pi_contents">
        <xsl:with-param name="input_text" select="$pi_node" />
      </xsl:call-template>
    <xsl:text>?&gt;</xsl:text>
  </code>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_pi_contents

DESCRIPTION :

TODO : process pseudo attributes
=============================================================================-->
<xsl:template name="embedded_dtd_process_pi_contents">
  <xsl:param name="input_text" />

  <xsl:choose>
    <xsl:when test="contains($input_text, '&quot;')">
      <xsl:variable name="the_rest"
          select="substring-after($input_text, '&quot;')" />
      <xsl:choose>
        <xsl:when test="contains($the_rest, '&quot;')">
          <xsl:value-of select="substring-before($input_text, '&quot;')" />
          <xsl:text disable-output-escaping="yes"
              >&lt;/code&gt;&lt;code class="dtd-pi-quoted"&gt;"</xsl:text>
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text"
                select="substring-before($the_rest, '&quot;')" />
            <xsl:with-param name="exit_class"
                select="'dtd-pi-quoted'" />
          </xsl:call-template>
          <xsl:text disable-output-escaping="yes"
              >"&lt;/code&gt;&lt;code class="dtd-pi"&gt;</xsl:text>
          <xsl:call-template name="embedded_dtd_process_pi_contents">
            <xsl:with-param name="input_text"
                select="substring-after($the_rest, '&quot;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated quoted </xsl:text>
            <xsl:text>section in pi.</xsl:text>
          </xsl:message>
          <xsl:call-template name="embedded_dtd_process_text">
            <xsl:with-param name="input_text" select="$input_text" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="embedded_dtd_process_text">
        <xsl:with-param name="input_text" select="$input_text" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_entity_decl_contents

DESCRIPTION :

TODO : process pseudo attributes
=============================================================================-->
<xsl:template name="embedded_dtd_process_entity_decl_contents">
  <xsl:param name="input_text" />

  <xsl:choose>
    <xsl:when test="contains($input_text, '&quot;')">
      <xsl:variable name="the_rest"
          select="substring-after($input_text, '&quot;')" />
      <xsl:choose>
        <xsl:when test="contains($the_rest, '&quot;')">
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text"
                select="substring-before($input_text, '&quot;')" />
            <xsl:with-param name="exit_class" select="'dtd'" />
          </xsl:call-template>
          <xsl:text disable-output-escaping="yes"
              >&lt;/code&gt;&lt;code class="dtd-quoted"&gt;"</xsl:text>
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text"
                select="substring-before($the_rest, '&quot;')" />
            <xsl:with-param name="exit_class"
                select="'dtd-quoted'" />
          </xsl:call-template>
          <xsl:text disable-output-escaping="yes"
              >"&lt;/code&gt;&lt;code class="dtd"&gt;</xsl:text>
          <xsl:call-template name="embedded_dtd_process_entity_decl_contents">
            <xsl:with-param name="input_text"
                select="substring-after($the_rest, '&quot;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated quoted </xsl:text>
            <xsl:text>section in pi.</xsl:text>
          </xsl:message>
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text" select="$input_text" />
            <xsl:with-param name="exit_class" select="'dtd'" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
        <xsl:with-param name="input_text" select="$input_text" />
        <xsl:with-param name="exit_class" select="'dtd'" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_top_level_text

DESCRIPTION : 
=============================================================================-->
<xsl:template name="embedded_dtd_process_top_level_text">
  <xsl:param name="input_text" select="." />
<!--
<xsl:message>
  <xsl:text>Top level text block </xsl:text>
  <xsl:value-of select="position()" />
  <xsl:text> = `</xsl:text>
  <xsl:value-of select="$input_text" />
  <xsl:text>'</xsl:text>
</xsl:message>
-->
  <xsl:call-template name="embedded_dtd_output_leading_whitespace">
    <xsl:with-param name="input_text" select="$input_text" />
  </xsl:call-template>

  <xsl:variable name="input_text_without_leading_whitespace">
    <xsl:call-template name="embedded_dtd_strip_leading_whitespace">
      <xsl:with-param name="input_text" select="$input_text" />
    </xsl:call-template>
  </xsl:variable>
<!--
<xsl:message>
  <xsl:text>Top level text block </xsl:text>
  <xsl:value-of select="position()" />
  <xsl:text> without whitespace = `</xsl:text>
  <xsl:value-of select="$input_text_without_leading_whitespace" />
  <xsl:text>'</xsl:text>
</xsl:message>
-->
  <xsl:choose>
    <!--
      Detect comments in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;!--')">
      <xsl:variable name="the_rest" select="substring(
          $input_text_without_leading_whitespace, 5)" />
      <xsl:choose>
        <xsl:when test="contains($the_rest, '--&gt;')">
          <xsl:call-template name="embedded_dtd_process_comment">
            <xsl:with-param name="comment_node"
                select="substring-before($the_rest, '--&gt;')" />
          </xsl:call-template>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text"
                select="substring-after($the_rest, '--&gt;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated comment.</xsl:text>
          </xsl:message>
          <xsl:call-template name="embedded_dtd_process_comment">
            <xsl:with-param name="comment_node"
                select="$input_text_without_leading_whitespace" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect processing instructions in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;?')">
      <xsl:variable name="the_rest" select="substring(
          $input_text_without_leading_whitespace, 3)" />
      <xsl:choose>
        <xsl:when test="contains($the_rest, '?&gt;')">
          <xsl:call-template name="embedded_dtd_process_pi">
            <xsl:with-param name="pi_node"
                select="substring-before($the_rest, '?&gt;')" />
          </xsl:call-template>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text"
                select="substring-after($the_rest, '?&gt;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated pi.</xsl:text>
          </xsl:message>
          <xsl:call-template name="embedded_dtd_process_pi">
            <xsl:with-param name="pi_node"
              select="$input_text_without_leading_whitespace" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect entity references in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace, '%')">
      <xsl:choose>
        <xsl:when test="contains($input_text_without_leading_whitespace, ';')">
          <code class="dtd-entityref">
            <xsl:value-of select="substring-before(
                $input_text_without_leading_whitespace, ';')" />
            <xsl:value-of select="';'" />
          </code>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text" select="substring-after(
                $input_text_without_leading_whitespace, ';')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated entity-reference.</xsl:text>
          </xsl:message>
          <code class="dtd-entityref">
            <xsl:value-of select="$input_text_without_leading_whitespace" />
          </code>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect element declarations in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;!ELEMENT')">
      <code class="dtd">
        <xsl:text>&lt;</xsl:text>
      </code>
      <code class="dtd-typedef">
        <xsl:text>!ELEMENT</xsl:text>
      </code>
      <xsl:choose>
        <xsl:when test="contains($input_text_without_leading_whitespace,
            '&gt;')">
          <code class="dtd">
            <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
              <xsl:with-param name="input_text"
                  select="substring-before(substring-after(
                  $input_text_without_leading_whitespace, '&lt;!ELEMENT'),
                  '&gt;')" />
              <xsl:with-param name="exit_class" select="'dtd'" />
            </xsl:call-template>
            <xsl:text>&gt;</xsl:text>
          </code>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text" select="substring-after(
                $input_text_without_leading_whitespace, '&gt;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated </xsl:text>
            <xsl:text>element declaration.</xsl:text>
          </xsl:message>
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text"
                select="$input_text_without_leading_whitespace" />
            <xsl:with-param name="exit_class" select="'dtd'" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect attribute list declarations in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;!ATTLIST')">
      <code class="dtd">
        <xsl:text>&lt;</xsl:text>
      </code>
      <code class="dtd-typedef">
        <xsl:text>!ATTLIST</xsl:text>
      </code>
      <xsl:choose>
        <xsl:when test="contains($input_text_without_leading_whitespace,
            '&gt;')">
          <code class="dtd">
            <xsl:call-template name="embedded_dtd_process_entity_decl_contents">
              <xsl:with-param name="input_text"
                  select="substring-before(substring-after(
                  $input_text_without_leading_whitespace, '&lt;!ATTLIST'),
                  '&gt;')" />
              <xsl:with-param name="exit_class" select="'dtd'" />
            </xsl:call-template>
            <xsl:text>&gt;</xsl:text>
          </code>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text" select="substring-after(
                $input_text_without_leading_whitespace, '&gt;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated </xsl:text>
            <xsl:text>element declaration.</xsl:text>
          </xsl:message>
          <xsl:call-template name="embedded_dtd_process_entity_decl_contents">
            <xsl:with-param name="input_text"
                select="$input_text_without_leading_whitespace" />
            <xsl:with-param name="exit_class" select="'dtd'" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect entity declarations in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;!ENTITY')">
      <code class="dtd">
        <xsl:text>&lt;</xsl:text>
      </code>
      <code class="dtd-typedef">
        <xsl:text>!ENTITY</xsl:text>
      </code>
      <xsl:choose>
        <xsl:when test="contains($input_text_without_leading_whitespace,
            '&gt;')">
          <code class="dtd">
            <xsl:call-template name="embedded_dtd_process_entity_decl_contents">
              <xsl:with-param name="input_text"
                  select="substring-before(substring-after(
                  $input_text_without_leading_whitespace, '&lt;!ENTITY'),
                  '&gt;')" />
            </xsl:call-template>
            <xsl:text>&gt;</xsl:text>
          </code>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text" select="substring-after(
                $input_text_without_leading_whitespace, '&gt;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated </xsl:text>
            <xsl:text>element declaration.</xsl:text>
          </xsl:message>
          <xsl:call-template name="embedded_dtd_process_entity_decl_contents">
            <xsl:with-param name="input_text"
                select="$input_text_without_leading_whitespace" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect doctype declarations in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;!DOCTYPE')">
      <code class="dtd">
        <xsl:text>&lt;</xsl:text>
      </code>
      <code class="dtd-typedef">
        <xsl:text>!DOCTYPE</xsl:text>
      </code>
      <xsl:variable name="the_rest" select="substring-after(
          $input_text_without_leading_whitespace, '&lt;!DOCTYPE')" />
      <xsl:variable name="next_closing_pointy_bracket">
        <xsl:choose>
          <xsl:when test="contains($the_rest, '&gt;')">
            <xsl:value-of select="string-length(
              substring-before($the_rest, '&gt;'))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$embedded_dtd_big_number" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="next_opening_square_bracket">
        <xsl:choose>
          <xsl:when test="contains($the_rest, '[')">
            <xsl:value-of select="string-length(
                substring-before($the_rest, '['))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$embedded_dtd_big_number" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$next_closing_pointy_bracket !=
            $embedded_dtd_big_number and
            $next_closing_pointy_bracket &lt; $next_opening_square_bracket">
          <code class="dtd">
            <xsl:call-template
                name="embedded_dtd_process_entity_decl_contents">
              <xsl:with-param name="input_text"
                  select="substring-before($the_rest, '&gt;')" />
            </xsl:call-template>
            <xsl:text>&gt;</xsl:text>
          </code>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text"
                select="substring-after($the_rest, '&gt;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$next_opening_square_bracket !=
            $embedded_dtd_big_number and
            $next_opening_square_bracket &lt; $next_closing_pointy_bracket">
          <code class="dtd">
            <xsl:call-template
                name="embedded_dtd_process_entity_decl_contents">
              <xsl:with-param name="input_text" select="substring(
                   $the_rest, 1, $next_opening_square_bracket - 1)" />
            </xsl:call-template>
          </code>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text" select="substring(
                 $the_rest, $next_opening_square_bracket)" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found doctype declaration without </xsl:text>
            <xsl:text>subsequent '&gt;' or '['.</xsl:text>
          </xsl:message>
          <xsl:call-template name="embedded_dtd_process_entity_decl_contents">
            <xsl:with-param name="input_text" select="$the_rest" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect the start of a conditional section ('<![')
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;![')">
      <code class="dtd">
        <xsl:text>&lt;</xsl:text>
      </code>
      <code class="dtd-typedef">
        <xsl:text>!</xsl:text>
      </code>
      <code class="dtd-square-brackets">
        <xsl:text>[</xsl:text>
      </code>
      <xsl:call-template name="embedded_dtd_process_top_level_text">
        <xsl:with-param name="input_text" select="substring(
            $input_text_without_leading_whitespace, 4)" />
      </xsl:call-template>
    </xsl:when>
    <!--
      Detect the end of a conditional section (']]>')
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        ']]>')">
      <code class="dtd-square-brackets">
        <xsl:text>]]</xsl:text>
      </code>
      <code class="dtd">
        <xsl:text>&gt;</xsl:text>
      </code>
      <xsl:call-template name="embedded_dtd_process_top_level_text">
        <xsl:with-param name="input_text" select="substring(
            $input_text_without_leading_whitespace, 4)" />
      </xsl:call-template>
    </xsl:when>
    <!--
      Detect the start of an internal DTD subset ('[')
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '[')">
      <code class="dtd-square-brackets">
        <xsl:text>[</xsl:text>
      </code>
      <xsl:call-template name="embedded_dtd_process_top_level_text">
        <xsl:with-param name="input_text" select="substring(
            $input_text_without_leading_whitespace, 2)" />
      </xsl:call-template>
    </xsl:when>
    <!--
      Detect the inner end of the internal DTD subset (']')
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        ']')">
      <code class="dtd-square-brackets">
        <xsl:text>]</xsl:text>
      </code>
      <xsl:call-template name="embedded_dtd_process_top_level_text">
        <xsl:with-param name="input_text" select="substring(
            $input_text_without_leading_whitespace, 2)" />
      </xsl:call-template>
    </xsl:when>
    <!--
      Detect the outer end of the internal DTD subset ('>')
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&gt;')">
      <code class="dtd">
        <xsl:text>&gt;</xsl:text>
      </code>
      <xsl:call-template name="embedded_dtd_process_top_level_text">
        <xsl:with-param name="input_text" select="substring(
            $input_text_without_leading_whitespace, 2)" />
      </xsl:call-template>
    </xsl:when>
    <!--
      Found a currently unrecognised piece of top level text - output a
      warning, and skip ahead through to the next piece of whitespace
    -->
    <xsl:otherwise>
      <xsl:call-template name="embedded_dtd_process_text">
        <xsl:with-param name="input_text"
            select="$input_text_without_leading_whitespace" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_output_leading_whitespace

DESCRIPTION : 
=============================================================================-->
<xsl:template name="embedded_dtd_output_leading_whitespace">
  <xsl:param name="input_text" />
  <xsl:param name="collected_whitespace" select="''" />

  <xsl:choose>
    <xsl:when test="$input_text != ''">
      <xsl:variable name="first_char" select="substring($input_text, 1, 1)" />
      <xsl:choose>
        <xsl:when test="$first_char = '&#x20;' or $first_char = '&#x09;' or
            $first_char = '&#x0D;' or $first_char = '&#x0A;'">
          <xsl:call-template name="embedded_dtd_output_leading_whitespace">
            <xsl:with-param name="input_text"
                select="substring($input_text, 2)" />
            <xsl:with-param name="collected_whitespace"
                select="concat($collected_whitespace, $first_char)" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="embedded_dtd_process_text">
            <xsl:with-param name="input_text" select="$collected_whitespace" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="embedded_dtd_process_text">
        <xsl:with-param name="input_text" select="$collected_whitespace" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_strip_leading_whitespace

DESCRIPTION : 
=============================================================================-->
<xsl:template name="embedded_dtd_strip_leading_whitespace">
  <xsl:param name="input_text" />

  <xsl:if test="$input_text != ''">
    <xsl:variable name="first_char" select="substring($input_text, 1, 1)" />
    <xsl:choose>
      <xsl:when test="$first_char = '&#x20;' or $first_char = '&#x09;' or
          $first_char = '&#x0D;' or $first_char = '&#x0A;'">
        <xsl:call-template name="embedded_dtd_strip_leading_whitespace">
          <xsl:with-param name="input_text"
              select="substring($input_text, 2)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$input_text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_text

DESCRIPTION : 
=============================================================================-->
<xsl:template name="embedded_dtd_process_text">
  <xsl:param name="input_text" />
  <xsl:call-template name="embedded_dtd_process_carriage_returns">
    <xsl:with-param name="input_text">
      <xsl:call-template name="embedded_dtd_generic_text_replacement">
        <xsl:with-param name="input_text"
            select="translate($input_text, ' ', '&#160;')" />
        <xsl:with-param name="find_this"    select="'&#x9;'" />
        <xsl:with-param name="replace_with"
            select="$EMBEDDED_DTD_REPLACE_TABS_WITH" />
      </xsl:call-template>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_carriage_returns

DESCRIPTION : This template is called when processing processing-instruction,
  text and comment nodes, and it replaces carriage returns with <br> elements.
  Note that a real carriage return is also inserted to make the HTML output
  that much more pleasant to view. This template is adapted from a template
  submitted to the XSL-List by Steve Muench of Oracle.
=============================================================================-->
<xsl:template name="embedded_dtd_process_carriage_returns">
  <xsl:param name="input_text" />
  <xsl:choose>
    <xsl:when test="contains($input_text, $embedded_dtd_new_line)">
      <xsl:value-of select="substring-before(
          $input_text, $embedded_dtd_new_line)" />
      <br />
      <xsl:value-of select="$embedded_dtd_new_line" />
      <xsl:call-template name="embedded_dtd_process_carriage_returns">
        <xsl:with-param name="input_text"
            select="substring-after($input_text, $embedded_dtd_new_line)" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$input_text" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_generic_text_replacement

DESCRIPTION : This template is called when 
=============================================================================-->
<xsl:template name="embedded_dtd_generic_text_replacement">
  <xsl:param name="input_text" />
  <xsl:param name="find_this" />
  <xsl:param name="replace_with" />

  <xsl:choose>
    <xsl:when test="contains($input_text, $find_this)">
      <xsl:value-of select="substring-before($input_text, $find_this)" />
      <xsl:value-of select="$replace_with" />
      <xsl:call-template name="embedded_dtd_generic_text_replacement">
        <xsl:with-param name="input_text"
            select="substring-after($input_text, $find_this)" />
        <xsl:with-param name="find_this"    select="$find_this" />
        <xsl:with-param name="replace_with" select="$replace_with" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$input_text" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_less_thans

DESCRIPTION : 
=============================================================================-->
<!--
<xsl:template name="embedded_dtd_process_less_thans">
  <xsl:param name="input_text" />
  <xsl:choose>
    <xsl:when test="contains($input_text, '&lt;')">
      <xsl:value-of select="substring-before($input_text, '&lt;')" />
      <xsl:text>&amp;lt;</xsl:text>
      <xsl:call-template name="embedded_dtd_process_less_thans">
        <xsl:with-param name="input_text"
          select="substring-after($input_text, '&lt;')" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$input_text" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_keywords_and_pes

DESCRIPTION : 
=============================================================================-->
<xsl:template name="embedded_dtd_process_keywords_and_pes">
  <xsl:param name="input_text" />
  <xsl:param name="exit_class" />

  <xsl:choose>
    <xsl:when test="contains($input_text, '%')">
      <xsl:call-template name="embedded_dtd_highlight_keywords">
        <xsl:with-param name="input_text"
            select="substring-before($input_text, '%')" />
        <xsl:with-param name="exit_class" select="$exit_class" />
      </xsl:call-template>
      <xsl:variable name="the_rest"
          select="substring-after($input_text, '%')" />
      <xsl:variable name="next_char" select="substring($the_rest, 1, 1)" />
      <xsl:choose>
        <xsl:when test="$next_char = '&#x20;' or $next_char = '&#x09;' or
            $next_char = '&#x0D;' or $next_char = '&#x0A;'">
          <xsl:text>%</xsl:text>
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text" select="$the_rest" />
            <xsl:with-param name="exit_class" select="$exit_class" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="contains($the_rest, ';')">
          <xsl:text disable-output-escaping="yes"
              >&lt;/code&gt;&lt;code class="dtd-entityref"&gt;%</xsl:text>
          <xsl:value-of select="substring-before($the_rest, ';')" />
          <xsl:text disable-output-escaping="yes"
              >;&lt;/code&gt;&lt;code class="</xsl:text>
          <xsl:value-of select="$exit_class" />
          <xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text" select="substring-after(
                $the_rest, ';')" />
            <xsl:with-param name="exit_class" select="$exit_class" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated entity-reference.</xsl:text>
          </xsl:message>
          <xsl:text disable-output-escaping="yes"
              >&lt;/code&gt;&lt;code class="dtd-entityref"&gt;%</xsl:text>
          <xsl:value-of select="$the_rest" />
          <xsl:text disable-output-escaping="yes"
              >&lt;/code&gt;&lt;code class="</xsl:text>
          <xsl:value-of select="$exit_class" />
          <xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="embedded_dtd_highlight_keywords">
        <xsl:with-param name="input_text" select="$input_text" />
        <xsl:with-param name="exit_class" select="$exit_class" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_highlight_keywords

DESCRIPTION : 
=============================================================================-->
<xsl:template name="embedded_dtd_highlight_keywords">
  <xsl:param name="input_text" />
  <xsl:param name="exit_class" />
  <xsl:param name="number" select="'1'" />

  <xsl:variable name="keyword"
      select="$embedded_dtd_keywords[$number]/text()" />
<!--
<xsl:message>
  <xsl:text>Looking for keyword `</xsl:text>
  <xsl:value-of select="$keyword" />
  <xsl:text>' (</xsl:text>
  <xsl:value-of select="$number" />
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$num_embedded_dtd_keywords" />
  <xsl:text>) in `</xsl:text>
  <xsl:value-of select="$input_text" />
  <xsl:text>'</xsl:text>
</xsl:message>
-->
  <xsl:choose>
    <xsl:when test="contains($input_text, $keyword)">
      <xsl:choose>
        <xsl:when test="$number &lt; $num_embedded_dtd_keywords">
          <!--
            Look through the text before the keyword we found for
            keywords that we haven't looked for yet!
          -->
          <xsl:call-template name="embedded_dtd_highlight_keywords">
            <xsl:with-param name="input_text"
                select="substring-before($input_text, $keyword)" />
            <xsl:with-param name="exit_class" select="$exit_class" />
            <xsl:with-param name="number"     select="$number + 1" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="embedded_dtd_process_text">
            <xsl:with-param name="input_text"
                select="substring-before($input_text, $keyword)" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text disable-output-escaping="yes"
          >&lt;/code&gt;&lt;code class="dtd-keyword"&gt;</xsl:text>
      <xsl:value-of select="$keyword" />
      <xsl:text disable-output-escaping="yes"
          >&lt;/code&gt;&lt;code class="</xsl:text>
      <xsl:value-of select="$exit_class" />
      <xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
      <xsl:call-template name="embedded_dtd_highlight_keywords">
        <xsl:with-param name="input_text"
            select="substring-after($input_text, $keyword)" />
        <xsl:with-param name="exit_class" select="$exit_class" />
        <xsl:with-param name="number"     select="$number" />
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$number &lt; $num_embedded_dtd_keywords">
      <xsl:call-template name="embedded_dtd_highlight_keywords">
        <xsl:with-param name="input_text" select="$input_text" />
        <xsl:with-param name="exit_class" select="$exit_class" />
        <xsl:with-param name="number"     select="$number + 1" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="embedded_dtd_process_text">
        <xsl:with-param name="input_text" select="$input_text" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
<xsl:template match="old_text" mode="embedded_dtd">
  <xsl:param name="first_node" />

  <xsl:variable name="step_1">
    <xsl:choose>
      <xsl:when test="$first_node = 'true' and starts-with(., '&#xA;')">
        <xsl:call-template name="escape_less_thans">
          <xsl:with-param name="string"
            select="translate(substring(., 2), ' ', '&#160;')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="escape_less_thans">
          <xsl:with-param name="string"
            select="translate(., ' ', '&#160;')" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

<xsl:message>
  <xsl:text>After less than escaping:</xsl:text>
  <xsl:value-of select="$step_1" />
</xsl:message>

  <xsl:variable name="step_2">
    <xsl:call-template name="search_for_entity_declarations">
      <xsl:with-param name="string" select="$step_1" />
    </xsl:call-template>
  </xsl:variable>
-->
<!--
  <xsl:variable name="step_2">
    <xsl:call-template name="process_quotes">
      <xsl:with-param name="string" select="$step_1" />
    </xsl:call-template>
  </xsl:variable>
-->
  <!-- highlight typedef keywords -->
<!--
  <xsl:variable name="step_20">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_2" />
      <xsl:with-param name="keyword" select="'!DOCTYPE'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_21">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_20" />
      <xsl:with-param name="keyword" select="'!ENTITY'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_22">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_21" />
      <xsl:with-param name="keyword" select="'!ELEMENT'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_23">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_22" />
      <xsl:with-param name="keyword" select="'!ATTLIST'" />
    </xsl:call-template>
  </xsl:variable>
-->

  <!-- highlight mid-stream keywords -->
<!--
  <xsl:variable name="step_30">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_23" />
      <xsl:with-param name="keyword" select="'SYSTEM'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_31">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_30" />
      <xsl:with-param name="keyword" select="'PUBLIC'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_32">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_31" />
      <xsl:with-param name="keyword" select="'#PCDATA'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_33">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_32" />
      <xsl:with-param name="keyword" select="'CDATA'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_34">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_33" />
      <xsl:with-param name="keyword" select="'#IMPLIED'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_35">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_34" />
      <xsl:with-param name="keyword" select="'#REQUIRED'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_36">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_35" />
      <xsl:with-param name="keyword" select="'EMPTY'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_37">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_36" />
      <xsl:with-param name="keyword" select="'ANY'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_38">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_37" />
      <xsl:with-param name="keyword" select="'ID'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_39">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_38" />
      <xsl:with-param name="keyword" select="'IDREF'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_40">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_39" />
      <xsl:with-param name="keyword" select="'NMTOKEN'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_41">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_40" />
      <xsl:with-param name="keyword" select="'NMTOKENS'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_42">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_41" />
      <xsl:with-param name="keyword" select="'ENTITIES'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="step_43">
    <xsl:call-template name="highlight_keywords">
      <xsl:with-param name="string"  select="$step_42" />
      <xsl:with-param name="keyword" select="'NOTATION'" />
      <xsl:with-param name="class"   select="'dtd-keyword'" />
    </xsl:call-template>
  </xsl:variable>
-->
<!--
  <xsl:variable name="step_100">
    <xsl:call-template name="process_dtd_carriage_returns">
      <xsl:with-param name="string" select="$step_2" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:value-of select="$step_100" disable-output-escaping="yes" />

</xsl:template>
-->

<!--
<xsl:template name="search_for_entity_declarations">
  <xsl:param name="string" />
  <xsl:choose>
    <xsl:when test="contains($string, '&lt;!')">
      <xsl:value-of select="$string" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->
<!--
<xsl:template name="process_quotes">
  <xsl:param name="string" select="." />
  <xsl:choose>
    <xsl:when test="contains($string, '&quot;')">
      <xsl:call-template name="process_entity_references">
        <xsl:with-param name="string"
            select="substring-before($string, '&quot;')" />
      </xsl:call-template>
      <xsl:text disable-output-escaping="yes">&lt;/code&gt;</xsl:text>
      <xsl:text disable-output-escaping="yes"
          >&lt;code class="dtd-quoted"&gt;"</xsl:text>
      <xsl:variable name="after_string"
          select="substring-after($string, '&quot;')" />
      <xsl:call-template name="process_entity_references">
        <xsl:with-param name="string"
            select="substring-before($after_string, '&quot;')" />
        <xsl:with-param name="in_quotes" select="true()" />
      </xsl:call-template>
      <xsl:text disable-output-escaping="yes">"&lt;/code&gt;</xsl:text>
      <xsl:text disable-output-escaping="yes"
          >&lt;code class="dtd"&gt;</xsl:text>
      <xsl:call-template name="process_quotes">
        <xsl:with-param name="string"
            select="substring-after($after_string, '&quot;')" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->
<!--
<xsl:template name="step_until_semicolon">
  <xsl:param name="string" select="." />
  <xsl:param name="in_quotes" select="false()" />
  <!- get the first character ->
  <xsl:variable name="first_character" select="substring($string, 1, 1)" />
  <xsl:choose>
    <xsl:when test="$first_character = ';'">
      <xsl:text disable-output-escaping="yes">;&lt;/code&gt;</xsl:text>
      <xsl:choose>
        <xsl:when test="$in_quotes">
          <xsl:text disable-output-escaping="yes"
              >&lt;code class="dtd-quoted"&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text disable-output-escaping="yes"
              >&lt;code class="dtd"&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="process_entity_references">
        <xsl:with-param name="string" select="substring($string, 2)" />
        <xsl:with-param name="in_quotes" select="$in_quotes" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$first_character" />
      <xsl:call-template name="step_until_semicolon">
        <xsl:with-param name="string" select="substring($string, 2)" />
        <xsl:with-param name="in_quotes" select="$in_quotes" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->
<!--
<xsl:template name="process_entity_references">
  <xsl:param name="string" select="." />
  <xsl:param name="in_quotes" select="false()" />
  <xsl:choose>
    <xsl:when test="contains($string, '%')">
      <xsl:value-of select="substring-before($string, '%')" />
      <xsl:text disable-output-escaping="yes">&lt;/code&gt;</xsl:text>
      <xsl:text disable-output-escaping="yes"
          >&lt;code class="dtd-entityref"&gt;%</xsl:text>
      <xsl:variable name="next_character"
        select="substring(substring-after($string, '%'), 1, 1)" />
      <xsl:choose>
        <!-
          If the character after the '%' is whitespace, we turn the
          highlighting off and continue processing the original string.
        ->
        <xsl:when test="$next_character = '&#x20;' or
            $next_character = '&#x9;' or $next_character = '&#xD;' or
            $next_character = '&#xA;' or $next_character = '&#160;'">
          <xsl:text disable-output-escaping="yes">&lt;/code&gt;</xsl:text>
          <xsl:choose>
            <xsl:when test="$in_quotes">
              <xsl:text disable-output-escaping="yes"
                  >&lt;code class="dtd-quoted"&gt;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text disable-output-escaping="yes"
                  >&lt;code class="dtd"&gt;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:call-template name="process_entity_references">
            <xsl:with-param name="string"
                select="substring-after($string, '%')" />
          </xsl:call-template>
        </xsl:when>
        <!-
          Otherwise, we have to check each character to see if
          it's a semi-colon.
        ->
        <xsl:otherwise>
          <xsl:call-template name="step_until_semicolon">
            <xsl:with-param name="string"
                select="substring-after($string, '%')" />
            <xsl:with-param name="in_quotes" select="$in_quotes" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->
<!--
<xsl:template name="highlight_keywords">
  <xsl:param name="string" select="." />
  <xsl:param name="keyword" select="'==='" />
  <xsl:param name="class"   select="'dtd-typedef'" />
  <xsl:choose>
    <xsl:when test="contains($string, $keyword)">
      <xsl:value-of select="substring-before($string, $keyword)" />
      <xsl:text disable-output-escaping="yes">&lt;/code&gt;</xsl:text>
      <xsl:text disable-output-escaping="yes">&lt;code class="</xsl:text>
      <xsl:value-of select="$class" />
      <xsl:text disable-output-escaping="yes">"&gt;</xsl:text>
      <xsl:value-of select="$keyword" />
      <xsl:text disable-output-escaping="yes">&lt;/code&gt;</xsl:text>
      <xsl:text disable-output-escaping="yes"
          >&lt;code class="dtd"&gt;</xsl:text>
      <xsl:call-template name="highlight_keywords">
        <xsl:with-param name="string"
            select="substring-after($string, $keyword)" />
        <xsl:with-param name="keyword" select="$keyword" />
        <xsl:with-param name="class"   select="$class" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->

</xsl:stylesheet>
