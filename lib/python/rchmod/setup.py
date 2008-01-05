from distutils.core import setup
setup(name="rchmod",
        version="1.0",
        description="Normalize file modes recursively",
        license = 'BSD',
        author="Jean-Baptiste Quenot",
        author_email="jbq@caraldi.com",
        url="http://caraldi.com/jbq/blog/",
        py_modules = ["rchmod"],
        scripts = ["rchmod"])
