all: links fo-titlepage.xsl html-titlepage.xsl slides-titlepage-fo.xsl

links:
	./setup-docbook-links

fo-titlepage.xsl: fo-titlepage.xml
	xsltproc -o fo-titlepage.xsl docbook/template/titlepage.xsl fo-titlepage.xml

slides-titlepage-fo.xsl: slides-titlepage-fo.xml
	xsltproc -o slides-titlepage-fo.xsl docbook/template/titlepage.xsl slides-titlepage-fo.xml

html-titlepage.xsl: html-titlepage.xml
	xsltproc -o html-titlepage.xsl docbook/template/titlepage.xsl html-titlepage.xml
