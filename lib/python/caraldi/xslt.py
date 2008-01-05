import sys, tempfile, exceptions
import libxml2
import cgi

class Error(exceptions.Exception):
    def __init__(self, msg):
        self.msg = msg
    def __str__(self):
        return self.msg

class DevNull:
    def write(self, str):
        pass
sys.stdout = DevNull()
import libxslt
sys.stdout = sys.__stdout__

libxmlErrors = []
def callback(ctx, str):
    libxmlErrors.append(str.rstrip())

#def fieldStorageToDictionary(fs):
#   mydict = {}
#   for k in fs.keys():
#       mydict[k] = fs.getvalue(k)
#   return mydict

def transformFile (url, stylesheet, params=None):
    doc = libxml2.parseFile(url)
    return transform (doc, stylesheet, params)

def transform(doc, styleSheet, params=None):
    # Redirect libxml error messages
    libxml2.registerErrorHandler(callback, None)
    libxslt.registerErrorHandler(callback, None)

    # Transforms doc (XML data) with style (XSLT stylesheet file name)
    try:
      styledoc = libxml2.parseFile(styleSheet)
    except libxml2.parserError, e:
        raise "Could not parse %s" % styleSheet, e
    styledoc.xincludeProcess()
    style = libxslt.parseStylesheetDoc(styledoc)

    if not(style):
        raise Error("Could not compile stylesheet %s: %s" % (styleSheet, '\n'.join(libxmlErrors)))

    #print >>sys.stderr, params
    result = style.applyStylesheet(doc, params)

    if not(result):
        raise Error("Could not apply stylesheet %s: %s" % (styleSheet, '\n'.join(libxmlErrors)))

    if libxmlErrors:
        raise Error("Could not apply stylesheet %s: %s" % (styleSheet, '\n'.join(libxmlErrors)))

    doc.freeDoc()

    # Save result
    # 22/09/02: problem: serialize converts < and > to &lt; and &gt;.
    # 23/09/02: actually, no, it causes other problems, dunno :)
    # saveResultToFd resets file descriptor so stylesheet must contain content
    # type header when saving to stdout (special file name: '-' or fd 1)
    testfile = tempfile.TemporaryFile()
    style.saveResultToFd(testfile.fileno(), result)
    testfile.seek(0)
    content = ''
    while 1:
        line = testfile.read()
        if not line:
            break
        content = content + line
    testfile.close()

    result.freeDoc()
    style.freeStylesheet()

    return content
    #return result.serialize()

def transformData(data, stylesheet, params=None):
    doc = libxml2.parseDoc(data)
    return transform (doc, stylesheet, params)

if __name__ == '__main__':
    print transform ('<?xml version="1.0"?><error></error>',
        'http://opensourceconsulting.info/xsl/todolist.xsl')
