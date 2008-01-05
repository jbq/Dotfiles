from distutils.core import setup

versionfile=open("version")
version = versionfile.read().rstrip()
setup(name="mergedirs",
        version="%s" % version,
        description="Merge two directories interactively",
        license = 'BSD',
        author="Jean-Baptiste Quenot",
        author_email="jb.quenot@caraldi.com",
        url="http://caraldi.com/jbq/",
        packages = ["caraldi"],
        scripts = ["mergedirs"])
