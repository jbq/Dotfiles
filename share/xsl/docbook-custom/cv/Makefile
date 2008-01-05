all: fo-titlepage.xsl html-titlepage.xsl

html-titlepage.xsl: html-titlepage.xml
	xsltproc -o html-titlepage.xsl ../docbook/template/titlepage.xsl html-titlepage.xml

fo-titlepage.xsl: fo-titlepage.xml
	xsltproc -o fo-titlepage.xsl ../docbook/template/titlepage.xsl fo-titlepage.xml
