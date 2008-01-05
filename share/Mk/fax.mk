################################################################################
# Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Purpose:       BSD Makefile for producing PDF fax
# Date Created:  2004-02-18 13:26:06
# Revision:      $Id: fax.mk 661 2004-04-20 21:39:40Z jbq $
################################################################################

XSL?=	$(HOME)/usr/share/xsl
BASE!=	basename $(.CURDIR)

all: $(BASE).pdf

$(BASE).pdf: $(BASE).xml $(XSL)/fax.xsl $(XSL)/common.xsl
	xsltproc --catalogs $(XSL)/fax.xsl $(BASE).xml > $(BASE).fo
	xep -fo $(BASE).fo $(BASE).pdf

ed:
.if defined(DISPLAY)
	vir $(BASE).xml
.else
	vim $(BASE).xml
.endif

clean:
	rm -f $(BASE).fo $(BASE).pdf

new:
	@test -e $(BASE).xml || ( cp -f $(MK)/fax.xml $(BASE).xml && echo $(BASE).xml created )

again: clean all

view:
	gnome-open ${BASE}.pdf
