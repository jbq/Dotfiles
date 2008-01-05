################################################################################
# File:          svg-batik.mk
# Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Date Created:  2003-01-27 17:51:25
# CVS Id:        $Id: svg-batik.mk 129 2003-09-09 13:26:25Z jbq $
################################################################################

.SUFFIXES:	.pdf .png .svg
PDF_TARGETS!=	ls *.svg |  sed -e 's/\.svg$$/.pdf/'
PNG_TARGETS!=	ls *.svg |  sed -e 's/\.svg$$/.png/'
SOURCES!=	ls *.svg

DISPLAY=	:0.0
#BATIK=		java -Xmx120m -jar ~/share/java/classes/batik-1.5/batik-rasterizer.jar
BATIK=		java -Xmx120m org.apache.batik.apps.rasterizer.Main

all:		$(PDF_TARGETS) $(PNG_TARGETS)

.svg.pdf:
	$(BATIK) -m application/pdf $< || ( rm -f $@ ; true )

.svg.png:
	$(BATIK) -m image/png $< || ( rm -f $@ ; true )

clean:
	find . -size 0 | xargs rm -f
