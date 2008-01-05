################################################################################
# Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Purpose:       Generate slides
# Date Created:  2004-04-29 15:51:07
# CVS Id:        $Id: docbk.mk 666 2004-04-21 16:17:21Z jbq $
################################################################################

HTML_STY?=		docbook-custom/slides-dhtml.xsl
#HTML_STY?=		docbook-custom/slides.xsl
.if defined(LAYOUT)
FO_STY ?=		docbook-custom/${LAYOUT}/slides-fo.xsl
.else
FO_STY ?=		docbook-custom/slides-fo.xsl
.endif

.include "docbk.mk"

# vi:ft=make
