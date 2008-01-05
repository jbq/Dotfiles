################################################################################
# Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Purpose:       BSD Makefile for producing PDF letter
# Date Created:  2004-02-18 13:25:28
# Revision:      $Id: letter.mk 798 2004-07-12 19:39:25Z jbq $
################################################################################

XSL?=	$(HOME)/usr/share/xsl
BASE!=	basename $(.CURDIR)

all: $(BASE).pdf

.if defined(BIG) && ($(BIG) == YES)
params+=--param big 1
.endif

$(BASE).pdf: $(BASE).xml ${XSL}/letter.xsl $(XSL)/common.xsl
	xsltproc $(params) --catalogs ${XSL}/letter.xsl $(BASE).xml > $(BASE).fo
	xep -fo $(BASE).fo $(BASE).pdf

ed:
.if defined(DISPLAY)
	vir $(BASE).xml
.else
	vim $(BASE).xml
.endif

clean:
	rm -f $(BASE).fo $(BASE).pdf

view:
	gnome-open $(BASE).pdf
