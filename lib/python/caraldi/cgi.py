# -*- coding: UTF-8 -*
import traceback, sys, types, UserDict

def contentType (type, encoding=None):
    if not encoding:
        print 'Content-Type: ' + type
    else:
        print 'Content-Type: ' + type + '; charset=' + encoding
    print

def reportErrorHTML (type, msg, tb):
    # print_exc in stdout!
    contentType('text/html')
    print '<pre style="color: red">', str(type) + ":", str(msg) + '</pre>'
    print '<!--'
    sys.stderr = sys.__stdout__
    traceback.print_exception(type, msg, tb)
    sys.stderr = sys.__stderr__
    print '-->'

# Convertir les paramètes de type str représentant des entiers en un type int
class FieldStorageDict (UserDict.UserDict):
    def __init__(self, fs):
        UserDict.UserDict.__init__(self, self.fieldStorageToDictionary(fs))

    def fieldStorageToDictionary(self, fs):
        mydict = {}
        for k in fs.keys():
            if (type(fs.getvalue(k)) == list):
                mydict[k] = fs.getvalue(k)
            elif (fs.getvalue(k).isdigit()):
                mydict[k] = int(fs.getvalue(k))
            else:
                mydict[k] = fs.getvalue(k)
        return mydict

# Entourer les paramètes de type str avec des guillemets
class XSLTDict (UserDict.UserDict):
    def __init__(self, dict):
        UserDict.UserDict.__init__(self, self.convertStrings(dict))

    def convertStrings(self, dict):
        mydict = {}
        for k in dict.keys():
            if type(dict[k]) == list:
                #mydict[k] = str(dict[k])
                #mydict[k] = ''
                pass
            elif type(dict[k]) in types.StringTypes:
                mydict[k] = '"' + dict[k] + '"'
            else:
                mydict[k] = str(dict[k])
        return mydict
