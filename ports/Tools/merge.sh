CATEGORY=$(make -V CATEGORIES | sed -e 's/ .*$//')
PORTNAME=$(basename `pwd`)
mergedirs -e admin -e work -e README.html /usr/ports/$CATEGORY/$PORTNAME .
