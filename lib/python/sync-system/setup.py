from distutils.core import setup
setup(name="syncsystem",
        version="1.0",
        description="Copy a set of files preserving directory tree",
        license = 'BSD',
        author="Jean-Baptiste Quenot",
        author_email="jbq@caraldi.com",
        url="http://caraldi.com/jbq/blog/",
        py_modules = ["syncsystem"],
        scripts = ["sync-system"])
