from distutils.core import setup
setup(name="cleanbackups",
        version="1.0",
        description="Clean backups",
        license = 'BSD',
        author="Jean-Baptiste Quenot",
        author_email="jbq@caraldi.com",
        url="http://caraldi.com/jbq/blog/",
        py_modules = ["cleanbackups"],
        scripts = ["clean-backups"])
