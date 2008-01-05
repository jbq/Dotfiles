<?xml version="1.0" encoding="iso-8859-1"?>

<!--
FILE : xml_to_html_frag.xsl

CREATED : 27 March 2000

LAST MODIFIED : 9 August 2001

AUTHOR : Warren Hedley (w.hedley@auckland.ac.nz)
         Department of Engineering Science
         The University of Auckland

TERMS OF USE / COPYRIGHT : See the "Terms of Use" page on the Tools section
  of the physiome.org.nz website, at http://www.physiome.org.nz/

CONTRIBUTORS : Michael Kay, Oliver Becker, Steve Muench

DESCRIPTION : This stylesheet fragment is used by other stylesheets to format
  any XML document into an HTML representation. The containing HTML document
  must reference the "embedded_xml.css" CSS stylesheet which contains the
  corresponding formatting instructions for the browser.

    Stylesheets that use this fragment should call the "embedded_xml" template
  with a context node whose children will be rendered. This might be a document
  root node or an <embedded_xml> element.

    In this stylesheet, all match templates are declared with a mode of
  "embedded_xml" and the names of all named templates start with "embedded_xml".
  This should hopefully stop the templates in this stylesheet interfering
  with any other included templates.

    Note that this stylesheet only works properly with indent set to "no" on
  the XML output method of the base stylesheet.

    The format for the ATTRIBUTE_SORT_ORDER command line parameter is
  '[element_1][element_2]{att_1,att_2,att_3}'.

CHANGES :
  26/09/2000 - WJH - had to change $xml_new_line to $xml_new_line to avoid name
                     clash with dtd_to_html.
  29/09/2000 - WJH - changed $HIGHLIGHT_NAMESPACE from '' to '?', to prevent
                     problems with default namespaces where name(namespace::*)
                     can return ''.
  02/10/2000 - WJH - added indentation to namespace node output.
  08/10/2000 - WJH - possible improvement on dropping whitespace nodes.
  22/11/2000 - WJH - added comment (above) on ATTRIBUTE_SORT_ORDER param.
  27/11/2000 - WJH - namespace declarations are now output after attributes.
                     Namespaces are ignored when looking for element names in
                     the ATTRIBUTE_SORT_ORDER param.
  24/12/2000 - WJH - changed XTH_NAMESPACE (http://www.whedley.com/xml_to_html)
                     to XPP_NAMESPACE (...physiome.org.nz/xml_pretty_printer).
  24/12/2000 - WJH - for comments and processing instructions that are outside
                     the document element (i.e., their parent is the root
                     element), we append two carriage returns so that subsequent
                     nodes start on a new-line.
  02/05/2001 - WJH - added support for xpp:output_ns attribute, which causes
                     namespace nodes to be output on elements even if they are
                     declared on parent elements.
  16/05/2001 - WJH - had to put whitespace inside start-tags inside <code>
                     elements to guarantee a monospace font.
  15/06/2001 - WJH - added xpp namespace declaration and removed some
                     instances of the XPP_NAMESPACE variable.
  15/06/2001 - WJH - added template to remove elements in the xpp namespace.
  06/07/2001 - WJH - removed support for HIGHLIGHT_NAMESPACE parameter.
  19/07/2001 - WJH - added support for NAMESPACE_SORT_ORDER parameter.
  06/08/2001 - WJH - improved pattern for checking if parent was document root.
  09/08/2001 - WJH - improved Warning message when an element has no attribute
                     or namespace nodes.
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xpp="http://www.physiome.org.nz/xml_pretty_printer"
    exclude-result-prefixes="xpp"
    version="1.0">


<xsl:param name="ATTRIBUTE_SORT_ORDER" select="''" />
<xsl:param name="NAMESPACE_SORT_ORDER" select="''" />

<xsl:variable name="XPP_NAMESPACE"
    select="'http://www.physiome.org.nz/xml_pretty_printer'" />

<xsl:variable name="xml_new_line" select="'&#xA;'" />


<!--============================================================================
NAMED TEMPLATE : embedded_xml

DESCRIPTION : This template is the root element for the XML -> HTML process.
  All of the other templates in this document have a mode="embedded_xml"
  attribute or are called by name. Processing starts with the children of the
  current node, so it can be applied to the root node of a document, or an
  element called <embedded_xml> whose children are to be included in the output
  document. There is a parameter `drop_first_and_last_text_nodes_if_whitespace'.
  If this is set to `yes', then if the first or last child nodes of the current
  element contain only whitespace, they will not be included in the output.
  For instance, in an input document containing the following XML

  <embedded_xml>
  <my_element_1 />
  <my_element_2 />
  </embedded_xml>

  the whitespace nodes between <embedded_xml> and <my_element_1 /> and
  <my_element_2 /> and </embedded_xml> would be removed.
=============================================================================-->
<xsl:template name="embedded_xml">
  <xsl:param name="drop_first_and_last_text_nodes_if_whitespace"
      select="'no'" />

  <!--
    We put lots of carriage returns in the output - it makes using `View Source'
     in the browser on the resulting document that much nicer.
  -->
    <xsl:choose>
      <xsl:when test="$drop_first_and_last_text_nodes_if_whitespace = 'yes'">
        <xsl:apply-templates select="child::node()[
            (not(position() = 1 and self::text() and
            normalize-space() = '')) and (not(position() = last() and
            self::text() and normalize-space() = ''))]" mode="embedded_xml" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="embedded_xml" />
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!--============================================================================
MATCH TEMPLATE : xpp:*  (MODE = embedded_xml)

DESCRIPTION : This template matches any elements in the XML pretty printer
  namespace, preventing them from turning up in the output document.
=============================================================================-->
<xsl:template match="xpp:*" mode="embedded_xml" />


<!--============================================================================
MATCH TEMPLATE : *  (MODE = embedded_xml)

DESCRIPTION : This template is used to process all element nodes. It calls one
  of the two element processing templates depending on the existence of
  child nodes within the current element.
=============================================================================-->
<xsl:template match="*" mode="embedded_xml">
  <xsl:choose>
    <xsl:when test="child::node()">
      <xsl:call-template name="embedded_xml_process_not_empty_element" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="embedded_xml_process_empty_element" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
MATCH TEMPLATE : text()  (MODE = embedded_xml)

DESCRIPTION : Outputs all text nodes without regard to context. To ensure
  consistent display, all spaces are made non-breaking, and <br> elements are
  inserted in place of carriage returns.
=============================================================================-->
<xsl:template match="text()" mode="embedded_xml">
  <phrase role="xec">
    <xsl:call-template name="embedded_xml_process_carriage_returns">
      <xsl:with-param name="input_text"
          select="translate(., ' ', '&#160;')" />
    </xsl:call-template>
  </phrase>
</xsl:template>


<!--============================================================================
MATCH TEMPLATE : comment()  (MODE = embedded_xml)

DESCRIPTION : Outputs all comments without regard to context. Note that comments
  in the XML are NOT comments in the output. To ensure consistent display, all
  spaces are made non-breaking, and <br> elements are inserted in place of
  carriage returns. Note that if this node is outside of the document element,
  then we add two carriage returns to make sure that the document element or
  subsequent nodes start on a newline.
=============================================================================-->
<xsl:template match="comment()" mode="embedded_xml">
  <phrase role="xc">
    <xsl:text>&lt;!--</xsl:text>
      <xsl:call-template name="embedded_xml_process_carriage_returns">
        <xsl:with-param name="input_text"
            select="translate(., ' ', '&#160;')" />
      </xsl:call-template>
    <xsl:text>--&gt;</xsl:text>
  </phrase>
  <xsl:if test="not(ancestor::*)">
    <xsl:value-of select="$xml_new_line" />
    <xsl:value-of select="$xml_new_line" />
  </xsl:if>
</xsl:template>


<!--============================================================================
MATCH TEMPLATE : processing-instruction()  (MODE = embedded_xml)

DESCRIPTION : Outputs all processing instructions without regard to context.
  Note that if this node is outside of the document element, then we add two
  carriage returns to make sure that the document element or subsequent nodes
  start on a newline.
=============================================================================-->
<xsl:template match="processing-instruction()" mode="embedded_xml">
  <phrase role="pi">
    <xsl:text>&lt;?</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:text>&#160;</xsl:text>
    <xsl:call-template name="embedded_xml_process_carriage_returns">
      <xsl:with-param name="input_text"
          select="translate(., ' ', '&#160;')" />
    </xsl:call-template>
    <xsl:text>?&gt;</xsl:text>
  </phrase>
  <xsl:if test="not(ancestor::*)">
    <xsl:value-of select="$xml_new_line" />
    <xsl:value-of select="$xml_new_line" />
  </xsl:if>
</xsl:template>


<!--
<xsl:template name="embedded_xml_calculate_element_class">
  <xsl:variable name="ns_uri" select="namespace-uri(.)" />
  <xsl:variable name="highlight_element">
    <xsl:choose>
      <xsl:when test="$ns_uri = '' and (
          $HIGHLIGHT_NAMESPACE = '-' or
          contains($HIGHLIGHT_NAMESPACE, '[-]'))">
        <xsl:value-of select="'0'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="namespace::*">
          <xsl:if test="namespace-uri(..) = . and (
              name(.) = $HIGHLIGHT_NAMESPACE or
              contains($HIGHLIGHT_NAMESPACE, concat('[', name(.), ']')))">
            <xsl:value-of select="'0'" />
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$highlight_element != ''">
      <xsl:text>xeh</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>xe</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->

<!--============================================================================
NAMED TEMPLATE : embedded_xml_process_not_empty_element

DESCRIPTION : This template is called to process non-empty elements (ie.
  elements with child nodes of some form). A start tag is printed, namespace
  nodes are processed, attribute nodes are processed, child nodes are processed,
  and finally a closing tag is printed. Note that a small optimisation is
  performed by not calling the namespace and attribute processing templates
  unless namespace or attribute nodes exist.
=============================================================================-->
<xsl:template name="embedded_xml_process_not_empty_element">
  <xsl:choose>
    <xsl:when test="@* | namespace::*">
      <phrase role="xe">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name(.)" />
      </phrase>
      <xsl:call-template name="embedded_xml_process_element_attributes" />
      <xsl:call-template name="embedded_xml_process_element_namespaces" />
      <phrase role="xe">
        <xsl:text>&gt;</xsl:text>
      </phrase>
    </xsl:when>
    <xsl:otherwise> <!-- separated for optimisation purposes -->
      <!-- Note that this should never be reached, because all elements
      must have at least one namespace node -->
      <xsl:message>WARNING: Found element with no attributes or namespaces -- this probably reflects an error in your XSLT processor.</xsl:message>
      <phrase role="xe">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name(.)" />
        <xsl:text>&gt;</xsl:text>
      </phrase>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:apply-templates mode="embedded_xml" />

  <phrase role="xe">
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name(.)" />
    <xsl:text>&gt;</xsl:text>
  </phrase>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_process_empty_element

DESCRIPTION : This template is called to process empty elements (ie. elements
  with not child nodes). A start tag is printed, namespace nodes are processed,
  attribute nodes are processed, and the element is closed. Note that a small
  optimisation is performed by not calling the namespace and attribute
  processing templates unless namespace or attribute nodes exist.
=============================================================================-->
<xsl:template name="embedded_xml_process_empty_element">
  <xsl:choose>
    <xsl:when test="@* | namespace::*">
      <phrase role="xe">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name(.)" />
      </phrase>
      <xsl:call-template name="embedded_xml_process_element_attributes" />
      <xsl:call-template name="embedded_xml_process_element_namespaces" />
      <phrase role="xe">
        <xsl:text>&#160;/&gt;</xsl:text>
      </phrase>
    </xsl:when>
    <xsl:otherwise> <!-- separated for optimisation purposes -->
      <phrase role="xe">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name(.)" />
        <xsl:text>&#160;/&gt;</xsl:text>
      </phrase>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_process_element_attributes

DESCRIPTION : This template is called for every element in the input DOM, and
  it processes and outputs the attributes on that element using the named
  template `embedded_xml_process_attribute_set'. Attributes in this stylesheet's
  namespace are not ignored. The attribute formatting attributes are evaluated
  as discussed in the stylesheet documentation and then passed down the
  template tree.
=============================================================================-->
<xsl:template name="embedded_xml_process_element_attributes">
  <xsl:variable name="attribute_set"
      select="attribute::*[namespace-uri() != $XPP_NAMESPACE]" />

  <xsl:if test="$attribute_set">
    <xsl:variable name="indent">
      <xsl:call-template name="embedded_xml_check_xth_parameter">
        <xsl:with-param name="xth_parameter" select="'indent'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ncols">
      <xsl:call-template name="embedded_xml_check_xth_parameter">
        <xsl:with-param name="xth_parameter" select="'ncols'" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="xpp_sort_order" select="(ancestor-or-self::*/
        @xpp:attribute_sort_order)[position()=last()]" />

    <xsl:variable name="aso">
      <xsl:choose>
        <xsl:when test="$xpp_sort_order and $xpp_sort_order != '-'">
          <xsl:value-of select="$xpp_sort_order" />
        </xsl:when>
        <xsl:when test="$ATTRIBUTE_SORT_ORDER">
          <xsl:variable name="element_name_search_pattern"
              select="concat('[', name(), ']')" />
          <xsl:choose>
            <xsl:when test="contains($ATTRIBUTE_SORT_ORDER,
                $element_name_search_pattern)">
              <xsl:value-of select="substring-before(
                  substring-after(substring-after($ATTRIBUTE_SORT_ORDER,
                  $element_name_search_pattern), '{'), '}')" />
            </xsl:when>
            <xsl:when test="contains($ATTRIBUTE_SORT_ORDER, '[*]')">
              <xsl:value-of select="substring-before(
                  substring-after(substring-after(
                  $ATTRIBUTE_SORT_ORDER, '[*]'), '{'), '}')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="embedded_xml_process_attribute_set">
      <xsl:with-param name="attribute_set" select="$attribute_set" />
      <xsl:with-param name="attribute_sort_order" select="$aso" />
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="ncols" select="$ncols" />
      <xsl:with-param name="position" select="0" />
      <xsl:with-param name="num_attributes" select="count($attribute_set)" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_process_attribute_set

DESCRIPTION : This template is called by `embedded_xml_element_attributes' to
  recursively process and output a set of attributes on a node. The sort order
  is scanned. If an attribute exists with a name equal to the first string in
  the sort order, then it is output (using the `embedded_xml_process_attribute'
  template), and this template is called again with one less attribute, and one
  less name in the sort order. If no attribute exists with a name equal to the
  first string in the sort order, then this template is called again with the
  same attribute set and one less name in the sort order. Finally, if no sort
  order sting is received, then the entire attribute set is output sorted
  alphabetically.
=============================================================================-->
<xsl:template name="embedded_xml_process_attribute_set">
  <xsl:param name="attribute_set" />  <!-- remaining attributes to output -->
  <xsl:param name="attribute_sort_order" /> <!-- sort string (see top) -->
  <xsl:param name="indent" />         <!-- indent this attribute? -->
  <xsl:param name="ncols" />          <!-- number of attributes per line -->
  <xsl:param name="position" />       <!-- index of first attribute in set -->
  <xsl:param name="num_attributes" /> <!-- number of atts on current node -->

  <!--
    $look_for_attribute stores the name of the attribute that we're going
    to look for first. If $attribute_sort_order contains a comma then we're
    going to look for whatever comes before the comma, otherwise the entire
    string.
  -->
  <xsl:variable name="look_for_attribute">
    <xsl:choose>
      <xsl:when test="contains($attribute_sort_order, ',') and
           not(starts-with($attribute_sort_order, ','))">
         <xsl:value-of select="substring-before($attribute_sort_order, ',')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$attribute_sort_order" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$look_for_attribute != ''">

    <!--
      The attribute sort order for the next search is pre-calculated here. If
      $attribute_sort_order contains a comma, then $stripped_sort_order consists
      of the current order less the first term, otherwise it is an empty string.
    -->
    <xsl:variable name="stripped_sort_order">
      <xsl:choose>
        <xsl:when test="contains($attribute_sort_order, ',') and
             not(starts-with($attribute_sort_order, ','))">
           <xsl:value-of select="substring-after($attribute_sort_order, ',')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

      <xsl:choose>
        <xsl:when test="$attribute_set[name() = $look_for_attribute]">
          <xsl:call-template name="embedded_xml_process_attribute">
            <xsl:with-param name="attribute"
              select="$attribute_set[name() = $look_for_attribute]" />
            <xsl:with-param name="indent"    select="$indent" />
            <xsl:with-param name="ncols"     select="$ncols" />
            <xsl:with-param name="position"  select="$position+1" />
            <xsl:with-param name="num_attributes" select="$num_attributes" />
          </xsl:call-template>
          <xsl:call-template name="embedded_xml_process_attribute_set">
            <xsl:with-param name="attribute_set"
                select="$attribute_set[name() != $look_for_attribute]" />
            <xsl:with-param name="attribute_sort_order"
                select="$stripped_sort_order" />
            <xsl:with-param name="indent" select="$indent" />
            <xsl:with-param name="ncols" select="$ncols" />
            <xsl:with-param name="position" select="$position+1" />
            <xsl:with-param name="num_attributes" select="$num_attributes" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="embedded_xml_process_attribute_set">
            <xsl:with-param name="attribute_set" select="$attribute_set" />
            <xsl:with-param name="attribute_sort_order"
                select="$stripped_sort_order" />
            <xsl:with-param name="indent" select="$indent" />
            <xsl:with-param name="ncols" select="$ncols" />
            <xsl:with-param name="position" select="$position" />
            <xsl:with-param name="num_attributes" select="$num_attributes" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="$attribute_set">
        <xsl:sort select="name()" />
        <xsl:call-template name="embedded_xml_process_attribute">
          <xsl:with-param name="attribute" select="." />
          <xsl:with-param name="indent"    select="$indent" />
          <xsl:with-param name="ncols"     select="$ncols" />
          <xsl:with-param name="position"  select="$position+position()" />
          <xsl:with-param name="num_attributes" select="$num_attributes" />
        </xsl:call-template>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_process_attribute

DESCRIPTION : This template is called by `embedded_xml_process_attribute_set'
  to output a single attribute. It is here that the `indent' and `ncols'
  formatting attributes finally come into play. Unfortunately, to be able to
  use them effectively, we also need to know the position of the current
  attribute within the current node's attribute set, as well as the total
  number of attributes on the current node.
=============================================================================-->
<xsl:template name="embedded_xml_process_attribute">
  <xsl:param name="attribute" />      <!-- attribute node to output -->
  <xsl:param name="indent" />         <!-- indent this attribute? -->
  <xsl:param name="ncols" />          <!-- number of attributes per line -->
  <xsl:param name="position" />       <!-- index of current attribute node -->
  <xsl:param name="num_attributes" /> <!-- number of atts on current node -->

  <phrase role="xec">
    <xsl:choose>
      <xsl:when test="(($ncols = 0) and ($indent &gt; 0)) or
        (($ncols &gt; 0) and (($position - 1) mod $ncols = 0))">
        <xsl:value-of select="$xml_new_line" />
        <xsl:call-template name="embedded_xml_print_non_breaking_spaces">
          <xsl:with-param name="num_spaces" select="$indent" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </phrase>
  <phrase role="xa">
    <xsl:value-of select="name($attribute)" />
    <xsl:text>="</xsl:text>
  </phrase>
  <phrase role="xac">
    <xsl:value-of select="$attribute" />
  </phrase>
  <phrase role="xa">
    <xsl:text>"</xsl:text>
  </phrase>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_process_element_namespaces

DESCRIPTION : This template is called for every element in the input DOM, and
  it processes and outputs the namespaces on that element apart from
  declarataions of the XML or this stylesheet's namespace.
=============================================================================-->
<xsl:template name="embedded_xml_process_element_namespaces">
  <xsl:variable name="parent_namespaces" select="../namespace::*" />
  
  <xsl:variable name="indent">
    <xsl:call-template name="embedded_xml_check_xth_parameter">
      <xsl:with-param name="xth_parameter" select="'indent'" />
    </xsl:call-template>
  </xsl:variable>

  <!--
    There is a default namespace declared on the parent element but no default
    namespace declared on the current element - there must be an empty default
    namespace declaration on the current element. Output this first. This
    was proposed on the XSL List by Oliver Becker.
  -->
  <xsl:if test="$parent_namespaces[name()=''] and not(namespace::*[name()=''])">
    <phrase role="xec">
      <xsl:choose>
        <xsl:when test="$indent > 0">
          <xsl:value-of select="$xml_new_line" />
          <xsl:call-template name="embedded_xml_print_non_breaking_spaces">
            <xsl:with-param name="num_spaces" select="$indent" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>&#160;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </phrase>
    <phrase role="xns">
      <xsl:text>xmlns=""</xsl:text>
    </phrase>
  </xsl:if>

  <xsl:variable name="namespace_set" select="namespace::*[
      not(. = $XPP_NAMESPACE) and not(name() = 'xml')]" />

  <xsl:if test="$namespace_set">
    <xsl:variable name="output_namespaces"
        select="concat(',', @xpp:output_ns, ',')" />

    <xsl:variable name="xpp_sort_order" select="(ancestor-or-self::*/
        @xpp:namespace_sort_order)[position()=last()]" />

    <xsl:variable name="namespace_sort_order">
      <xsl:choose>
        <!--
          If the closest ancestor-or-self element to define a 
          @xpp:namespace_sort_order attribute defines an empty attribute,
          then we give the $NAMESPACE_SORT_ORDER command line parameter a shot.
        -->
        <xsl:when test="$xpp_sort_order and $xpp_sort_order != ''">
          <xsl:value-of select="$xpp_sort_order" />
        </xsl:when>
        <xsl:when test="$NAMESPACE_SORT_ORDER">
          <xsl:variable name="element_name_search_pattern"
              select="concat('[', name(), ']')" />
          <xsl:choose>
            <xsl:when test="contains($NAMESPACE_SORT_ORDER,
                $element_name_search_pattern)">
              <xsl:value-of select="substring-before(
                  substring-after(substring-after($NAMESPACE_SORT_ORDER,
                  $element_name_search_pattern), '{'), '}')" />
            </xsl:when>
            <xsl:when test="contains($NAMESPACE_SORT_ORDER, '[*]')">
              <xsl:value-of select="substring-before(
                  substring-after(substring-after(
                  $NAMESPACE_SORT_ORDER, '[*]'), '{'), '}')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="embedded_xml_process_namespace_set">
      <xsl:with-param name="namespace_set" select="$namespace_set" />
      <xsl:with-param name="parent_namespaces" select="$parent_namespaces" />
      <xsl:with-param name="namespace_sort_order"
          select="$namespace_sort_order" />
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="output_namespaces" select="$output_namespaces" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_process_namespace_set

DESCRIPTION : This template is called by `embedded_xml_element_namespaces' to
  recursively process and output a set of namespaces on a node. The sort order
  is scanned. If an namespace exists with a name equal to the first string in
  the sort order, then it is output (using the `embedded_xml_process_namespace'
  template), and this template is called again with one less namespace, and one
  less name in the sort order. If no namespace exists with a name equal to the
  first string in the sort order, then this template is called again with the
  same namespace set and one less name in the sort order. Finally, if no sort
  order sting is received, then the entire namespace set is output sorted
  alphabetically.

  Note that it seems impossible to store just the namespace nodes we're
  interested in the $namespace_set variable, so we get the whole lot, and have
  to filter them against the $parent_namespaces and $output_namespaces in
  this template.

  The tests used to check whether a namespace node matching the current node
  is declared on the parent of the current element was proposed on the XSL
  List by Michael Kay, and improved on by Oliver Becker.
=============================================================================-->
<xsl:template name="embedded_xml_process_namespace_set">
  <xsl:param name="namespace_set" />  <!-- remaining namespaces to output -->
  <xsl:param name="parent_namespaces" /> <!-- namespaces on parent element -->
  <xsl:param name="namespace_sort_order" /> <!-- sort string (see top) -->
  <xsl:param name="indent" />         <!-- indent this namespace? -->
  <xsl:param name="output_namespaces" /> <!-- ns to be output even if parent -->

  <!--
    $look_for_namespace stores the name of the namespace that we're going
    to look for first. If $namespace_sort_order contains a comma then we're
    going to look for whatever comes before the comma, otherwise the entire
    string.
  -->
  <xsl:variable name="look_for_namespace">
    <xsl:choose>
      <xsl:when test="contains($namespace_sort_order, ',') and
           not(starts-with($namespace_sort_order, ','))">
         <xsl:value-of select="substring-before($namespace_sort_order, ',')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$namespace_sort_order" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$look_for_namespace != ''">
      <!--
        The namespace sort order for the next search is pre-calculated here.
        If $namespace_sort_order contains a comma, then $stripped_sort_order
        consists of the current order less the first term, otherwise it is an
        empty string.
      -->
      <xsl:variable name="stripped_sort_order">
        <xsl:choose>
          <xsl:when test="contains($namespace_sort_order, ',') and
               not(starts-with($namespace_sort_order, ','))">
             <xsl:value-of select="substring-after(
                 $namespace_sort_order, ',')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!--
        We pre-evaulate two variables, any namespace with a name matching
        the name of the namespace we're looking for, or a default namespace
        declaration, if that's what we're looking for.
      -->
      <xsl:variable name="matching_namespace"
          select="$namespace_set[name() = $look_for_namespace]" />
      <xsl:variable name="matching_default_namespace"
          select="$namespace_set[$look_for_namespace = '-' and name() = '']" />

      <xsl:choose>
        <xsl:when test="$matching_namespace">
          <xsl:for-each select="$matching_namespace">
            <!--
              We need to make the namespace node the current node with the
              above for-each line, so that we can then use current() below to
              check if this namespace node matches a node declared on the
              parent of the current element. We also need to output this node
              if its name is contained in $output_namespaces.
            -->
            <xsl:if test="not($parent_namespaces[
                name() = name(current()) and . = current()]) or
                contains($output_namespaces, concat(',', name(), ','))">
              <xsl:call-template name="embedded_xml_process_namespace">
                <xsl:with-param name="namespace" select="$matching_namespace" />
                <xsl:with-param name="indent"    select="$indent" />
              </xsl:call-template>

              <xsl:call-template name="embedded_xml_process_namespace_set">
                <xsl:with-param name="namespace_set"
                    select="$namespace_set[name() != $look_for_namespace]" />
                <xsl:with-param name="parent_namespaces"
                    select="$parent_namespaces" />
                <xsl:with-param name="namespace_sort_order"
                    select="$stripped_sort_order" />
                <xsl:with-param name="indent" select="$indent" />
                <xsl:with-param name="output_namespaces"
                     select="$output_namespaces" />
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <!-- Look for default namespace declarations -->
        <xsl:when test="$matching_default_namespace">
          <xsl:for-each select="$matching_default_namespace">
            <!--
              We need to make the namespace node the current node with the
              above for-each line, so that we can then use current() below to
              check if this namespace node matches a node declared on the
              parent of the current element. We also need to output this node
              if $output_namespaces contains '-'.
            -->
            <xsl:if test="not($parent_namespaces[
                name() = '' and . = current()]) or
                contains($output_namespaces, ',-,')">
              <xsl:call-template name="embedded_xml_process_namespace">
                <xsl:with-param name="namespace"
                  select="$matching_default_namespace" />
                <xsl:with-param name="indent" select="$indent" />
              </xsl:call-template>

              <xsl:call-template name="embedded_xml_process_namespace_set">
                <xsl:with-param name="namespace_set"
                    select="$namespace_set[name() != '']" />
                <xsl:with-param name="parent_namespaces"
                    select="$parent_namespaces" />
                <xsl:with-param name="namespace_sort_order"
                    select="$stripped_sort_order" />
                <xsl:with-param name="indent" select="$indent" />
                <xsl:with-param name="output_namespaces"
                     select="$output_namespaces" />
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!--
            Proceed to the next namespace node in the sort order.
          -->
          <xsl:call-template name="embedded_xml_process_namespace_set">
            <xsl:with-param name="namespace_set" select="$namespace_set" />
            <xsl:with-param name="parent_namespaces"
                select="$parent_namespaces" />
            <xsl:with-param name="namespace_sort_order"
                select="$stripped_sort_order" />
            <xsl:with-param name="indent" select="$indent" />
            <xsl:with-param name="output_namespaces"
                 select="$output_namespaces" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <!--
        If we have no namespace sort order, or have eliminated all nodes from
        the sort order, we proceed through the remainder, with the default
        namespace output first, and then sorted by prefix alphabetically.
      -->
      <xsl:for-each select="$namespace_set">
        <xsl:sort select="name() != ''" />
        <xsl:sort select="name()" />
        <!--
          The test below checks that there isn't a namespace node declared on
          the parent of the current element that matches the current node, or
          if the name of the current node ('-' if default) occurs in the
          $output_namespaces string.
        -->
        <xsl:if test="not($parent_namespaces[
            name() = name(current()) and . = current()]) or
            (name() = '' and contains($output_namespaces, ',-,')) or
            (name() != '' and contains($output_namespaces, concat(
            ',', name(), ',')))">
          <xsl:call-template name="embedded_xml_process_namespace">
            <xsl:with-param name="namespace" select="." />
            <xsl:with-param name="indent" select="$indent" />
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_process_namespace

DESCRIPTION : This template is called by `embedded_xml_process_namespace_set'
  to output a single namespace. Unlike the attribute output process, only
  the `indent' formatting instructions are followed here, because the presence
  of default namespace nodes makes `ncols' impossible to enforce.
=============================================================================-->
<xsl:template name="embedded_xml_process_namespace">
  <xsl:param name="namespace" />      <!-- namespace node to output -->
  <xsl:param name="indent" />         <!-- indent this namespace? -->

  <xsl:if test="$strip.namespaces = 0">
  <phrase role="xec">
    <xsl:choose>
      <xsl:when test="$indent &gt; 0">
        <xsl:value-of select="$xml_new_line" />
        <xsl:call-template name="embedded_xml_print_non_breaking_spaces">
          <xsl:with-param name="num_spaces" select="$indent" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </phrase>
  <xsl:value-of select="$xml_new_line" />
  <xsl:call-template name="embedded_xml_print_non_breaking_spaces">
    <xsl:with-param name="num_spaces" select="$indent + 2" />
  </xsl:call-template>
  <phrase role="xns">
    <xsl:text>xmlns</xsl:text>
    <xsl:if test="name($namespace)">
      <xsl:text>:</xsl:text>
      <xsl:value-of select="name($namespace)" />
    </xsl:if>
    <xsl:text>="</xsl:text>
  </phrase>
  <phrase role="xnsc">
    <xsl:value-of select="$namespace" />
  </phrase>
  <phrase role="xns">
    <xsl:text>"</xsl:text>
  </phrase>
  </xsl:if>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_print_non_breaking_spaces

DESCRIPTION : This template is called by `embedded_xml_process_attribute' to
  print out `num_spaces' non-breaking spaces for the indentation of attributes.
=============================================================================-->
<xsl:template name="embedded_xml_print_non_breaking_spaces">
  <xsl:param name="num_spaces" />
  <xsl:if test="$num_spaces &gt; 0">
    <xsl:text>&#160;</xsl:text>
    <xsl:call-template name="embedded_xml_print_non_breaking_spaces">
      <xsl:with-param name="num_spaces" select="$num_spaces - 1" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_check_xth_parameter

DESCRIPTION : This template is used to check the values of the various
  formatting attributes in the `xml_to_html' namespace. It is called by
  `embedded_xml_process_element_attributes'.
=============================================================================-->
<xsl:template name="embedded_xml_check_xth_parameter">
  <xsl:param name="xth_parameter" />
  <xsl:choose>
    <xsl:when test="@xpp:*[local-name() = $xth_parameter]">
      <xsl:value-of select="number(@xpp:*[local-name() = $xth_parameter])" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>0</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--============================================================================
NAMED TEMPLATE : embedded_xml_process_carriage_returns

DESCRIPTION : This template is called when processing processing-instruction,
  text and comment nodes, and it replaces carriage returns with <br> elements.
  Note that a real carriage return is also inserted to make the HTML output
  that much more pleasant to view. This template is adapted from a template
  submitted to the XSL-List by Steve Muench of Oracle.
=============================================================================-->
<xsl:template name="embedded_xml_process_carriage_returns">
  <xsl:param name="input_text" />
  <xsl:choose>
    <xsl:when test="contains($input_text, $xml_new_line)">
      <xsl:value-of select="substring-before($input_text, $xml_new_line)" />
      <xsl:value-of select="$xml_new_line" />
      <xsl:call-template name="embedded_xml_process_carriage_returns">
        <xsl:with-param name="input_text"
            select="substring-after($input_text, $xml_new_line)" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$input_text" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
