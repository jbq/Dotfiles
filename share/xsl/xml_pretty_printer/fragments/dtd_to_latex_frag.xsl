<?xml version="1.0" encoding="iso-8859-1"?>

<!--
FILE : dtd_to_latex_frag.xsl

CREATED : 27 March 2000

LAST MODIFIED : 7 August 2001

AUTHOR : Warren Hedley (w.hedley@auckland.ac.nz)
         Department of Engineering Science
         The University of Auckland

TERMS OF USE / COPYRIGHT : See the "Terms of Use" page on the Tools section
  of the physiome.org.nz website, at http://www.physiome.org.nz/

DESCRIPTION : This stylesheet fragment is used by other stylesheets to format
  any DTD document into an LATEX representation.

    Stylesheets that use this fragment should call the "embedded_dtd" template
  with a context node whose children will be rendered. This might be a document
  root node or an <embedded_dtd> element. The stylesheet makes use of templates
  declared with a mode of "embedded_dtd".

CHANGES :
  28/12/2000 - WJH - massive re-write to bring this inline with the HTML
                     pretty-printing, to generate good colour PDFs.
  15/05/2001 - WJH - added support for conditional sections.
  15/06/2001 - WJH - added $create_dtd_environment parameter to embedded_dtd
                     template so that it can be used to add DTD sections to
                     XML files created with xml_to_latex.xsl.
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


<xsl:param name="EMBEDDED_DTD_REPLACE_TABS_WITH" select="'  '" />


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

  <xsl:if test="$create_dtd_environment = 'yes'">
    <xsl:text>\begin{code}&#xA;</xsl:text>
  </xsl:if>
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
  <xsl:if test="$create_dtd_environment = 'yes'">
    <xsl:text>\end{code}&#xA;</xsl:text>
  </xsl:if>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_comment

DESCRIPTION : 
=============================================================================-->
<xsl:template name="embedded_dtd_process_comment">
  <xsl:param name="comment_node" select="." />

  <xsl:text>\codedc{&lt;!--</xsl:text>
  <xsl:call-template name="embedded_dtd_process_text">
    <xsl:with-param name="input_text" select="$comment_node" />
  </xsl:call-template>
  <xsl:text>--&gt;}</xsl:text>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_dtd_process_pi

DESCRIPTION :

TODO : process pseudo attributes
=============================================================================-->
<xsl:template name="embedded_dtd_process_pi">
  <xsl:param name="pi_node" />

  <xsl:text>\codedpi{&lt;?</xsl:text>
  <xsl:call-template name="embedded_dtd_process_pi_contents">
    <xsl:with-param name="input_text" select="$pi_node" />
  </xsl:call-template>
  <xsl:text>?&gt;}</xsl:text>
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
          <xsl:text>}\codedpiq{"</xsl:text>
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text"
                select="substring-before($the_rest, '&quot;')" />
            <xsl:with-param name="exit_class"
                select="'\codedpiq{'" />
          </xsl:call-template>
          <xsl:text>"}\codedpi{</xsl:text>
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
            <xsl:with-param name="exit_class" select="'\codedtd{'" />
          </xsl:call-template>
          <xsl:text>}\codedq{"</xsl:text>
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text"
                select="substring-before($the_rest, '&quot;')" />
            <xsl:with-param name="exit_class"
                select="'\codedq{'" />
          </xsl:call-template>
          <xsl:text>"}\codedtd{</xsl:text>
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
            <xsl:with-param name="exit_class" select="'\codedtd{'" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
        <xsl:with-param name="input_text" select="$input_text" />
        <xsl:with-param name="exit_class" select="'\codedtd{'" />
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
          <xsl:text>\codeder{</xsl:text>
            <xsl:value-of select="substring-before(
                $input_text_without_leading_whitespace, ';')" />
            <xsl:value-of select="';'" />
          <xsl:text>}</xsl:text>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text" select="substring-after(
                $input_text_without_leading_whitespace, ';')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>WARNING : found unterminated entity-reference.</xsl:text>
          </xsl:message>
          <xsl:text>\codeder{</xsl:text>
            <xsl:value-of select="$input_text_without_leading_whitespace" />
          <xsl:text>}</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect element declarations in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;!ELEMENT')">
      <xsl:text>\codedtd{&lt;}\codedtyped{!ELEMENT}</xsl:text>
      <xsl:choose>
        <xsl:when test="contains($input_text_without_leading_whitespace,
            '&gt;')">
          <xsl:text>\codedtd{</xsl:text>
          <xsl:call-template name="embedded_dtd_process_keywords_and_pes">
            <xsl:with-param name="input_text"
                select="substring-before(substring-after(
                $input_text_without_leading_whitespace, '&lt;!ELEMENT'),
                '&gt;')" />
            <xsl:with-param name="exit_class" select="'\codedtd{'" />
          </xsl:call-template>
          <xsl:text>&gt;}</xsl:text>
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
            <xsl:with-param name="exit_class" select="'\codedtd{'" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect attribute list declarations in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;!ATTLIST')">
      <xsl:text>\codedtd{&lt;}\codedtyped{!ATTLIST}</xsl:text>
      <xsl:choose>
        <xsl:when test="contains($input_text_without_leading_whitespace,
            '&gt;')">
          <xsl:text>\codedtd{</xsl:text>
          <xsl:call-template name="embedded_dtd_process_entity_decl_contents">
            <xsl:with-param name="input_text"
                select="substring-before(substring-after(
                $input_text_without_leading_whitespace, '&lt;!ATTLIST'),
                '&gt;')" />
            <xsl:with-param name="exit_class" select="'\codedtd{'" />
          </xsl:call-template>
          <xsl:text>&gt;}</xsl:text>
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
            <xsl:with-param name="exit_class" select="'\codedtd{'" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!--
      Detect entity declarations in the middle of text nodes.
    -->
    <xsl:when test="starts-with($input_text_without_leading_whitespace,
        '&lt;!ENTITY')">
      <xsl:text>\codedtd{&lt;}\codedtyped{!ENTITY}</xsl:text>
      <xsl:choose>
        <xsl:when test="contains($input_text_without_leading_whitespace,
            '&gt;')">
          <xsl:text>\codedtd{</xsl:text>
          <xsl:call-template name="embedded_dtd_process_entity_decl_contents">
            <xsl:with-param name="input_text"
                select="substring-before(substring-after(
                $input_text_without_leading_whitespace, '&lt;!ENTITY'),
                '&gt;')" />
          </xsl:call-template>
          <xsl:text>&gt;}</xsl:text>
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
      <xsl:text>\codedtd{&lt;}\codedtyped{!DOCTYPE}</xsl:text>
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
          <xsl:text>\codedtd{</xsl:text>
          <xsl:call-template
              name="embedded_dtd_process_entity_decl_contents">
            <xsl:with-param name="input_text"
                select="substring-before($the_rest, '&gt;')" />
          </xsl:call-template>
          <xsl:text>&gt;}</xsl:text>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text"
                select="substring-after($the_rest, '&gt;')" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$next_opening_square_bracket !=
            $embedded_dtd_big_number and
            $next_opening_square_bracket &lt; $next_closing_pointy_bracket">
          <xsl:text>\codedtd{</xsl:text>
          <xsl:call-template
              name="embedded_dtd_process_entity_decl_contents">
              <xsl:with-param name="input_text" select="substring(
                   $the_rest, 1, $next_opening_square_bracket)" />
          </xsl:call-template>
          <xsl:text>}</xsl:text>
          <xsl:call-template name="embedded_dtd_process_top_level_text">
            <xsl:with-param name="input_text" select="substring(
                 $the_rest, $next_opening_square_bracket + 1)" />
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
      <xsl:text>\codedtd{&lt;}\codedtyped{!}\codedsqbr{[}</xsl:text>
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
      <xsl:text>\codedsqbr{]]}\codedtd{&gt;}</xsl:text>
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
      <xsl:text>\codedsqbr{[}</xsl:text>
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
      <xsl:text>\codedsqbr{]}</xsl:text>
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
      <xsl:text>\codedtd{&gt;}</xsl:text>
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
        <xsl:with-param name="input_text"   select="$input_text" />
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
      <xsl:text>&#xA;</xsl:text>
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
          <xsl:text>}\codeder{%</xsl:text>
          <xsl:value-of select="substring-before($the_rest, ';')" />
          <xsl:text>;}</xsl:text>
          <xsl:value-of select="$exit_class" />
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
          <xsl:text>}\codeder{%</xsl:text>
          <xsl:value-of select="$the_rest" />
          <xsl:text>;}</xsl:text>
          <xsl:value-of select="$exit_class" />
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
      <xsl:text>}\codedk{</xsl:text>
      <xsl:value-of select="$keyword" />
      <xsl:text>}</xsl:text>
      <xsl:value-of select="$exit_class" />
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

<!-- commented out 28/12/2000
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">


<xsl:template name="embedded_dtd">
  <xsl:text>\begin{code}
</xsl:text>
  <xsl:apply-templates mode="embedded_dtd" />
  <xsl:text>\end{code}
</xsl:text>
</xsl:template>


<xsl:template match="*" mode="embedded_dtd">
  <xsl:text>\bftext{WARNING : UNEXPECTED ELEMENT IN EMBEDDED DTD OF TYPE </xsl:text>
  <xsl:value-of select="name()" />
  <xsl:text>}</xsl:text>
</xsl:template>

-->
<!-- we don't escape underscores in embedded dtd sections -->
<!--
<xsl:template match="text()" mode="embedded_dtd">
  <xsl:value-of select="." />
</xsl:template>


-->
</xsl:stylesheet>
