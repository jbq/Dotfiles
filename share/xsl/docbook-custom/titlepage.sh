for i in *-fo-titlepage.xml ; do
    echo "${i%%.*}.xsl: $i"
    echo "	xsltproc -o ${i%%.*}.xsl docbook/template/titlepage.xsl $i"
    echo
done
