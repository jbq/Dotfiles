################################################################################
# File:          docbk.mk
# Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Purpose:       Make docbook output formats
# Date Created:  2002-04-04 14:06:54
# CVS Id:        $Id: docbk.mk 1015 2004-10-20 15:54:13Z jbq $
################################################################################

MK?=	$(HOME)/usr/share/Mk
XSL?=	${MK}/../xsl
RESOURCES?=		${XSL}/docbook-custom/${LAYOUT}/resources

UNAME!=	uname -s

################################################################################
# Default formats to generate; the first one is used in 'make view'
# This variable can be passed on the command line as an argument to make
FORMATS ?= html index
FORMAL?=	NO
GENERATE_TOC?=	NO

################################################################################
# Define viewers
PDFVIEWER=	gnome-open
HTMLVIEWER=	gnome-open
TXTVIEWER=	less

.if defined(DISPLAY)
XMLEDITOR=	vir
.else
XMLEDITOR=	vim
.endif

.if defined(LAYOUT)
FO_STY?=		docbook-custom/${LAYOUT}/fo.xsl
HTML_STY?=	docbook-custom/${LAYOUT}/html.xsl
.endif

################################################################################
# DocBook DSSSL Print Stylesheet
# DSSSL_PRINT_STY = /usr/local/share/sgml/docbook/dsssl/modular/print/docbook.dsl
# Personal DSSSL Print Stylesheet suitable for article
.if $(FORMAL) == YES
DSSSL_PRINT_STY?=	$(HOME)/usr/dsssl/docbook-custom/formal.dsl
.else
DSSSL_PRINT_STY?=	$(HOME)/usr/dsssl/docbook-custom/print.dsl
.endif

#
# PDF can be generated from several engines
#
#PDF_GENERATOR?=	passivetex
#PDF_GENERATOR?= dvipdf
#PDF_GENERATOR?= jadetex
#PDF_GENERATOR?= fop
PDF_GENERATOR?= xep
RTF_GENERATOR=	DSSSL

################################################################################
# DocBook XSL HTML Stylesheet
#
# DSSSL
#
# HTML_STY_PATH = /usr/local/share/sgml/docbook/dsssl/modular/html/docbook.dsl
# Personal DSSSL HTML Stylesheet suitable for article
# HTML_STY_PATH = $(HOME)/pub/pub/docbook/docbook.dsl\#html
# Tell me the dependencies (defaults to $HTML_STY_PATH)
HTML_STY_DEP=	$(HTML_STY_PATH)

HTMLSRC_STY?=	${XSL}/xml_pretty_printer/xml_to_html.xsl

#
# XSL
#
#HTML_STY?=	/usr/local/share/xsl/docbook/html/docbook.xsl
HTML_STY ?=	docbook-custom/html.xsl
HTML_STY_PATH =	${XSL}/${HTML_STY}

#
# Multiple XSL processors can be used
#XSL_PROCESSOR?=	saxon
XSL_PROCESSOR?=	xsltproc

################################################################################
# DocBook XSL FO Stylesheet
FO_STY?=	docbook-custom/fo.xsl
FO_STY_PATH =	${XSL}/${FO_STY}

################################################################################
# DSSSL processor to use
DSSSL_PROCESSOR=	jade

################################################################################
# Here is the SGML declaration for XML, used by [open]jade to handle XML docs
.if $(UNAME) == Linux
XML_DECL=	/usr/share/sgml/declaration/xml.dcl
.else
XML_DECL?=	/usr/local/share/sgml/docbook/dsssl/modular/dtds/decls/xml.dcl
.endif

#VALIDATE_CMD=	nsgmls -s $(XML_DECL)
#VALIDATE_CMD=	xmllint --noout --postvalid --xinclude
#VALIDATE_CMD=	xmllint --catalogs --noout --postvalid
#VALIDATE_CMD=	xmllint --noout --postvalid
VALIDATE_CMD=	xmllint --nonet --noout --postvalid --xinclude

################################################################################
# Chunked HTML output? (i.e. multiple files)
CHUNKED_HTML = no

# Velocity does not recognize charset from XML document
# What about using JXTemplate or XInclude?
WITH_VELOCITY?= NO

################################################################################
#  Everything up to here is customizable.  Do not modify the rest unless you   #
#  know exactly what you are doing ;)                                          #
################################################################################























































################################################################################
# Compute base name
DIRBASE != basename $(.CURDIR)

.if defined(DOCBOOK_LANG)
BASE=	$(DIRBASE).$(DOCBOOK_LANG)
.else
BASE=	$(DIRBASE)
.endif

################################################################################
# Compute HTML output
HTML_EXT?=	html
HTML != test $(CHUNKED_HTML) = yes && echo html/index.html || echo $(BASE).$(HTML_EXT)

################################################################################
# Setup default stylesheets dependencies
HTML_STY_DEP += $(HTML_STY_PATH)
DSSSL_PRINT_STY_DEP += $(DSSSL_PRINT_STY)
FO_STY_DEP += $(FO_STY_PATH)

HTML_DEP += $(HTML_STY_DEP)
DSSSL_PRINT_DEP += $(DSSSL_PRINT_STY_DEP)
FO_DEP += $(FO_STY_DEP)

SRC_DEP += $(BASE).xml
MERGED_SRC_DOCUMENT=	merge-$(BASE).xml
TEX_FILE=	$(BASE).tex
#.endif


# Get the first format to generate, used by 'make view'
MAIN_FORMAT != echo $(FORMATS) | cut -d' ' -f1

SRC_HREF?=	src-$(BASE).html
VIEW_PDF?=	NO
NO_ULINK?=	NO

.if defined (VIEW_SOURCE)
XSLTPROC_PARAMS += --param SRC_HREF "'$(SRC_HREF)'"
SAXON_PARAMS += SRC_HREF="$(SRC_HREF)"
.endif

.if defined (PDF_HREF)
XSLTPROC_PARAMS += --param PDF_HREF "'$(PDF_HREF)'"
SAXON_PARAMS += PDF_HREF="$(PDF_HREF)"
.endif

.if defined(CSS_DIR)
CSS_DIRECTORY	?= ${CSS_DIR}
.endif

.if defined (CSS_DIRECTORY)
XSLTPROC_PARAMS += --stringparam css.directory $(CSS_DIRECTORY)
SAXON_PARAMS += css.directory="$(CSS_DIRECTORY)"
.endif

.if defined (HTML_CSS_STY)
XSLTPROC_PARAMS += --stringparam html.stylesheet $(HTML_CSS_STY)
SAXON_PARAMS += html.stylesheet="$(HTML_CSS_STY)"
.endif

.if $(VIEW_PDF) == YES
XSLTPROC_PARAMS += --param PDF_HREF "'$(BASE).pdf'"
SAXON_PARAMS += PDF_HREF="$(BASE).pdf"
.endif

.if $(FORMAL) == YES
XSLTPROC_PARAMS += --param section.autolabel 1 --param generate.toc "'article toc'"
SAXON_PARAMS += section.autolabel=1 generate.toc "article toc"
.endif

.if $(GENERATE_TOC) == YES
XSLTPROC_PARAMS += --param generate.toc "'article toc'"
SAXON_PARAMS += generate.toc "article toc"
.endif

.if (defined(AUTOLABEL) && ${AUTOLABEL} == YES)
XSLTPROC_PARAMS += --param section.autolabel 1
SAXON_PARAMS += section.autolabel=1
.endif

.if (defined(RESOURCES))
XSLTPROC_PARAMS += --stringparam resources.dir ${RESOURCES}
SAXON_PARAMS += resources.dir="${RESOURCES}"
.endif

.if $(NO_ULINK) == YES
XSLTPROC_PARAMS+=	--param "ulink.show" "0"
.endif

.if $(PDF_GENERATOR) == "fop"
XSLTPROC_PARAMS+=	--param "fop.extensions" "1"
.if (exists(fop-config.xml))
FOP_ARGS=		-c fop-config.xml
.endif
.elif $(PDF_GENERATOR) == "xep"
XSLTPROC_PARAMS+=	--param "xep.extensions" "1"
.endif

all: $(FORMATS)

rmmerge:
	rm -f $(MERGED_SRC_DOCUMENT)

pdf: $(BASE).pdf

rtf: $(BASE).rtf

html: $(HTML)

htmldir: html/index.html

txt: $(BASE).txt

ed:
	$(XMLEDITOR) $(BASE).xml

edit: ed

love:
	@echo not war?

view: view-$(MAIN_FORMAT)

view-pdf:
	$(PDFVIEWER) $(BASE).pdf

view-html:
	$(HTMLVIEWER) $(HTML)

view-txt:
	$(PAGER) $(BASE).txt

print:
	lpr $(BASE).pdf

#again: touch all
again: clean all

touch:
	touch $(BASE).xml

.if defined(DOCBOOK_LANG)
INDEX=	index.$(DOCBOOK_LANG).$(HTML_EXT)
.else
INDEX=	index.$(HTML_EXT)
.endif

index: $(INDEX)
htmlsrc: $(SRC_HREF)
htmlsource: htmlsrc

################################################################################
$(INDEX): $(BASE).$(HTML_EXT)
	cp -fp $(BASE).$(HTML_EXT) $(INDEX)

CSS_DIRECTORY?=	/css

$(SRC_HREF): $(MERGED_SRC_DOCUMENT)
	xsltproc --novalid --param CSS_DIRECTORY "'$(CSS_DIRECTORY)'" \
--param PAGE_TITLE "'XML Source Code'" \
$(HTMLSRC_STY) $(MERGED_SRC_DOCUMENT) \
> $(SRC_HREF) || ( rm -f $(SRC_HREF) ; false )

$(BASE).txt: $(BASE).html
	html2text $(BASE).html

html/index.html: $(MERGED_SRC_DOCUMENT) $(HTML_DEP)
	test -d html || mkdir html
	xsltproc --novalid $(XSLTPROC_PARAMS) $(HTML_STY_PATH) $(MERGED_SRC_DOCUMENT) \
	2>&1 | grep -v Writing || true
	cp -p html/frames.html html/index.html

$(BASE).$(HTML_EXT): $(MERGED_SRC_DOCUMENT) $(HTML_DEP)
.if $(XSL_PROCESSOR) == "xsltproc"
	xsltproc -o $(BASE).$(HTML_EXT) --novalid $(XSLTPROC_PARAMS) $(HTML_STY_PATH) $(MERGED_SRC_DOCUMENT)
.elif $(XSL_PROCESSOR) == "saxon"
	saxon $(MERGED_SRC_DOCUMENT) $(HTML_STY_PATH) $(SAXON_PARAMS) > $(BASE).$(HTML_EXT)
.endif

.if $(RTF_GENERATOR) == "DSSSL"
$(BASE).rtf: $(MERGED_SRC_DOCUMENT) $(DSSSL_PRINT_DEP)
	$(DSSSL_PROCESSOR) -o $(BASE).rtf -t rtf -V rtf-backend -d $(DSSSL_PRINT_STY) $(XML_DECL) \
	$(MERGED_SRC_DOCUMENT)
	rm -f $(BASE).aux $(BASE).log $(TEX_FILE) $(BASE).out
.else
$(BASE).rtf: $(BASE).fo
	java ch.codeconsult.jfor.main.CmdLineConverter $(BASE).fo $(BASE).rtf
.endif

################################################################################
.if $(PDF_GENERATOR) == "jadetex"
# Use xml ---[openjade]---> tex ---[jadetex]---> pdf
$(BASE).pdf: $(MERGED_SRC_DOCUMENT) $(DSSSL_PRINT_DEP)
	$(DSSSL_PROCESSOR) -o $(TEX_FILE) -t tex -V tex-backend -d $(DSSSL_PRINT_STY) \
	$(XML_DECL) $(MERGED_SRC_DOCUMENT)
	pdfjadetex $(TEX_FILE) > /dev/null || ( rm -f $(BASE).pdf ; false )
	pdfjadetex $(TEX_FILE) > /dev/null || ( rm -f $(BASE).pdf ; false )
	pdfjadetex $(TEX_FILE) > /dev/null || ( rm -f $(BASE).pdf ; false )
	rm -f $(BASE).aux $(BASE).log $(TEX_FILE) $(BASE).out
.elif $(PDF_GENERATOR) == "fop"
# Use xml ---[xsltproc]---> fo ---[fop]---> pdf
$(BASE).pdf: $(BASE).fo
	fop ${FOP_ARGS} -fo $(BASE).fo -pdf $(BASE).pdf | ( grep -v 'not implemented' ; true )
.elif $(PDF_GENERATOR) == "xep"
# Use xml ---[xsltproc]---> fo ---[xep]---> pdf
$(BASE).pdf: $(BASE).fo
	xep -fo $(BASE).fo $(BASE).pdf
.elif $(PDF_GENERATOR) == "dvipdf"
# Use xml ---[openjade]---> tex ---[latex]---> dvi ---[dvipdf]---> pdf
$(BASE).pdf: $(MERGED_SRC_DOCUMENT) $(DSSSL_PRINT_DEP)
	$(DSSSL_PROCESSOR) -o $(TEX_FILE) -t tex -V tex-backend -d $(DSSSL_PRINT_STY) $(XML_DECL) $(MERGED_SRC_DOCUMENT)
	jadetex $(TEX_FILE)
	dvipdf $(BASE).dvi
.elif $(PDF_GENERATOR) == "passivetex"
# Use xml ---[xsltproc]---> fo ---[passivetex]---> pdf
$(BASE).pdf: $(BASE).fo
	pdfxmltex $(BASE).fo
.endif

################################################################################
$(BASE).fo: $(MERGED_SRC_DOCUMENT) $(FO_DEP)
.if $(XSL_PROCESSOR) == "xsltproc"
	xsltproc $(XSLTPROC_PARAMS) -o $(BASE).fo --novalid $(FO_STY_PATH) $(MERGED_SRC_DOCUMENT)
.elif $(XSL_PROCESSOR) == "saxon"
	saxon $(MERGED_SRC_DOCUMENT) $(FO_STY_PATH) > $(BASE).fo
.endif

merge: $(MERGED_SRC_DOCUMENT)
	
$(MERGED_SRC_DOCUMENT): $(SRC_DEP)
	$(VALIDATE_CMD) $(BASE).xml
	xmllint --xinclude --noent $(BASE).xml > $(MERGED_SRC_DOCUMENT)
.if defined(SOURCE_FILTER)
	${SOURCE_FILTER} < $(MERGED_SRC_DOCUMENT) > /tmp/docbk || ( rm -f $(MERGED_SRC_DOCUMENT) ; false )
	mv /tmp/docbk $(MERGED_SRC_DOCUMENT)
.endif
.if defined(WITH_VELOCITY) && (${WITH_VELOCITY} == yes || ${WITH_VELOCITY} == YES)
	java info.opensourceconsulting.VelocityEngine < $(MERGED_SRC_DOCUMENT) > /tmp/docbk || ( rm -f $(MERGED_SRC_DOCUMENT) ; false )
	rm -f velocity.log
	mv /tmp/docbk $(MERGED_SRC_DOCUMENT)
.endif
	rm -f $(BASE).xml.bak
	cp -p $(BASE).xml $(BASE).xml.bak

################################################################################
# Remove everything except source document
clean:
# Remove files generated by make
	rm -f $(BASE).xml.bak $(MERGED_SRC_DOCUMENT) velocity.log
# Remove targets
	rm -f $(BASE).rtf $(BASE).$(HTML_EXT) $(BASE).txt $(BASE).pdf $(BASE).fo $(INDEX) $(SRC_HREF)
	rm -rf html
# Remove files generated by TeX
	rm -f $(BASE).aux $(BASE).log $(TEX_FILE) $(BASE).out

new:
	@test -e $(BASE).xml || ( cp -f $(MK)/docbk.xml $(BASE).xml && echo $(BASE).xml created )

new-anyware:
	@test -e $(BASE).xml || ( cp -f $(MK)/docbk-anyware.xml $(BASE).xml && echo $(BASE).xml created )

cvsignore:
	echo $(SRC_HREF) $(INDEX) $(BASE).html $(BASE).pdf merge-$(BASE).xml $(BASE).xml.bak $(BASE).rtf $(BASE).fo index.html >> .cvsignore

svnignore:
	svn pg svn:ignore . > .svnignore
	echo $(SRC_HREF) >> .svnignore
	echo $(BASE).html >> .svnignore
	echo $(BASE).txt >> .svnignore
	echo $(BASE).pdf >> .svnignore
	echo merge-$(BASE).xml >> .svnignore
	echo $(BASE).xml.bak >> .svnignore
	echo $(BASE).rtf >> .svnignore
	echo $(BASE).fo >> .svnignore
	echo $(INDEX) >> .svnignore
	svn ps svn:ignore -F .svnignore .
	rm -f .svnignore

total:
	xsltproc ${XSL}/total.xsl ${BASE}.xml > total.xml

pub: ${BASE}.pdf
	cp ${BASE}.pdf $$(sed -ne 's/^.*<biblioid>\(.*\)<\/biblioid>.*$$/\1/p' < ${BASE}.xml | sed -e "s/\//_/g")_$$(sed -ne 's/^.*<title>\(.*\)<\/title>.*$$/\1/p' < ${BASE}.xml | sed -n 1p | sed -e "s/[ ']/_/g").pdf

# vi:ft=make
