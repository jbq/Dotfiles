all:
	cp ../../../bin/rchmod .
	sed -i -e 's/^\([^#].*\)\bcaraldi/\1rchmod/g' rchmod
	cp ../caraldi/util.py rchmod.py

deb:
	dpkg-buildpackage -rfakeroot -I.svn -I.*.sw* -IMakefile

clean:
	rm -rf dist bin
