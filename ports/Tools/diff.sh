#! /bin/sh -e

if ! portlint > /tmp/$$ 2>&1 ; then
    cat /tmp/$$
    rm /tmp/$$
    exit 1
fi
CATEGORY=$(make -V CATEGORIES | sed -e 's/ .*$//')
PORTNAME=$(basename $(realpath .))
diff --ignore-matching-lines='\$FreeBSD.*\$' --exclude=".swp" --exclude='.*.sw*' --exclude=.svn --exclude=work --exclude=admin -ruN /usr/ports/$CATEGORY/$PORTNAME .
