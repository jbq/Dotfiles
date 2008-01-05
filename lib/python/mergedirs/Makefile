all:
	svn cat http://svn.caraldi.com/trunk/bin/mergedirs > mergedirs
	svn co http://svn.caraldi.com/trunk/lib/python/caraldi
	python setup.py sdist

clean:
	rm -rf dist caraldi
	rm -f mergedirs
