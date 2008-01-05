all:
	cp ../../../sbin/clean-backups .
	sed -i -e 's/^\([^#].*\)\bcaraldi/\1cleanbackups/g' clean-backups
	cp ../caraldi/util.py cleanbackups.py

deb:
	dpkg-buildpackage -rfakeroot -I.svn -I.*.sw* -IMakefile

clean:
	rm -rf dist build
