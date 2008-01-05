all:
	cp ../../../bin/sync-system .
	sed -i -e 's/^\([^#].*\)\bcaraldi/\1syncsystem/g' sync-system
	cp ../caraldi/util.py syncsystem.py

deb:
	dpkg-buildpackage -rfakeroot -I.svn -I.*.sw* -IMakefile

clean:
	rm -rf dist bin
