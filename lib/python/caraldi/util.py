################################################################################
# Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Revision:      $Id: existctl,v 1.6 2004/09/10 08:12:35 jbquenot Exp $
################################################################################
# Copyright (c) 2004-2006, Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * The name of the contributors may not be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
################################################################################
# TODO logger class attribute, not instance attribute
#
# Traverse directories to find files and call the callback function visitFile
# each time.  Warning: lstat() does not follow symbolic links unlike stat()
# Override the class to change visitFile behaviour.

import os, sys, glob, re, signal, time, stat, string, shutil, zipfile
from stat import *

class DefaultLogger:
    CRITICAL = 50
    FATAL = CRITICAL
    ERROR = 40
    WARNING = 30
    WARN = WARNING
    INFO = 20
    DEBUG = 10
    NOTSET = 0

    def debug(self, msg):
        print msg

class NullWriter:
    def write(self, str):
        pass

#
# Thanks to Anthony Baxter (see http://www.python.org/tim_one/000326.html)
#
def uniq(old):
    nd={}
    for e in old:
        nd[e]=None
    return nd.keys()

def execute(args):
    status = spawn(args)
    if status != 0:
        sys.exit(status)
def spawn(args):
    return os.spawnv(os.P_WAIT, "/usr/bin/env", ["env"] + args)

def zipEntriesDiffer(masterf, slavef):
    return oneWayZipEntriesDiffer(masterf, slavef) or oneWayZipEntriesDiffer(slavef, masterf)

def oneWayZipEntriesDiffer(masterf, slavef):
    # Idea from http://www.jlwalkerassociates.com/tools/diffjar/README.html
    # Python implementation using http://docs.python.org/lib/module-zipfile.html
    masterzipinfo = zipfile.ZipFile(masterf).infolist()
    slavezip = zipfile.ZipFile(slavef)
    slave_members = slavezip.namelist()

    for info in masterzipinfo:
        # entries in master and slave are not necessarily at the same
        # position in the archive
        if not(info.filename in slave_members):
            return 1
        slaveinfo = slavezip.getinfo(info.filename)
        if info.CRC != slaveinfo.CRC:
            return 1
    return 0

def join(dir, file):
    result = ""
    if dir:
        result = result + re.sub("/$", "", dir) + "/"
    result = result + re.sub("^/", "", file)
    return result

def getLogger(target=None):
    try:
        import logging
        logging.basicConfig()
        logger = logging.getLogger(target)
        logger.setLevel(logging.WARN)
    except ImportError:
        print >>sys.stderr, 'Warning: logging not available'
        logger = DefaultLogger()

    return logger

class DirStat:
    logger = getLogger(__name__)
    def __init__ (self, dir=None):
        self.__total_bytes = 0
        self.__total_files = 0
        self.matches = []
        self.patterns = []
        self.fullPathPatterns = []
        self.depthFirstSearch = 0
        self.nonRecursive = 0

        if (dir):
            self.walk (dir)

    def debug(self, debug):
        DirStat.logger.setLevel(DefaultLogger.DEBUG)

    def compilePattern(self, rawpattern):
        DirStat.logger.debug("rawpattern = %s" % rawpattern)
        if rawpattern[0] == '-':
            excludePattern = True
        elif rawpattern[0] == '+':
            excludePattern = False
        else:
            raise "Pattern '%s' is not an exclusion nor an inclusion, please use - or + as first character" % rawpattern
        modifiersPos = rawpattern.find("(")
        if modifiersPos != -1:
            modifiers = rawpattern[modifiersPos+1:-1]
            pattern = rawpattern[1:modifiersPos]
        else:
            modifiers = None
            pattern = rawpattern[1:]
        DirStat.logger.debug("pattern = %s" % pattern)
        DirStat.logger.debug("modifiers = %s" % modifiers)
        return (excludePattern, pattern, modifiers)

    def modifiersMatch(self, modifiers, stat):
        mode = stat[ST_MODE]
        if modifiers and modifiers.find(".") != -1 and not(S_ISREG(mode)):
            return False
        return True

    def isExcluded(self, dir, file, stat):
        exclude = False
        for rawpattern in self.patterns:
            (excludePattern, pattern, modifiers) = self.compilePattern(rawpattern)

            if file == ".":
                continue
            globlist = glob.glob(join(dir, pattern))
            path = join(dir, file)
            DirStat.logger.debug("Testing whether %s belongs to %s" % (path, globlist))

            if path in globlist and self.modifiersMatch(modifiers, stat):
                DirStat.logger.debug("Ignoring %s" % path)
                exclude = excludePattern
                DirStat.logger.debug("exclude = %s" % exclude)
                continue

        for rawpattern in self.fullPathPatterns:
            (excludePattern, pattern, modifiers) = self.compilePattern(rawpattern)
            excludePath = join(self.rootDir, pattern)
            DirStat.logger.debug("excludePath = %s" % (excludePath))
            globlist = glob.glob(excludePath)
            path = join(dir, file)
            DirStat.logger.debug("Testing whether %s belongs to %s" % (path, globlist))
            if path in globlist and self.modifiersMatch(modifiers, stat):
                DirStat.logger.debug("Ignoring %s" % path)
                exclude = excludePattern
                DirStat.logger.debug("exclude = %s" % exclude)
                continue

        return exclude

    #
    # Directory traversal function
    #
    def walk (self, dir):
        '''recursively descend the directory rooted at dir, calling the callback
        function visitFile for each regular file, visitDirectory for each
        directory, and visitLink for each link'''

        if self.rootDir == None:
            self.rootDir = dir

        stat = os.lstat(dir)
        if (S_ISREG(stat[ST_MODE])):
            self.visitFile(dir, stat)
        else:
            if not(self.depthFirstSearch):
                self.visitDirectory(dir, stat)
            list = os.listdir(dir)
            list.sort()
            for f in list:
                pathname = join(dir, f)

                if not(os.path.exists(pathname)) and not(os.path.islink(pathname)):
                    # The current program may be deleting files
                    print >>sys.stderr, '%s has been deleted, skipping' % pathname
                    continue

                stat = os.lstat(pathname)

                if self.isExcluded(dir, f, stat):
                    #print "Ignoring", f
                    continue
                mode = stat[ST_MODE]

                if S_ISDIR(mode):
                    # It's a directory, recurse into it
                    if not(self.nonRecursive):
                        self.walk (pathname)
                elif S_ISREG(mode):
                    # It's a file, call the callback function
                    self.visitFile(pathname, stat)
                elif S_ISLNK(mode):
                    if (os.path.exists(pathname)):
                        # It's a link, call the callback function
                        self.visitLink(pathname, stat)
                    else:
                        # Dangling link
                        self.visitDanglingLink(pathname, stat)
                else:
                    # Unknown file type, print a message
                    print >>sys.stderr, 'Skipping %s with mode %s' % (pathname, mode)

            if self.depthFirstSearch:
                self.visitDirectory(dir, stat)

    #
    # Actions to perform when encountering a file.  Override that function to
    # modify behaviour.
    #
    def visitFile (self, file, stat):
        print >>sys.stderr, 'Visited file', file
        self.__total_bytes = self.__total_bytes + stat[ST_SIZE]
        self.__total_files = self.__total_files + 1

    #
    # Actions to perform when encountering a link.  Override that function to
    # modify behaviour.
    #
    def visitLink (self, file, stat):
        print >>sys.stderr, 'Visited link', file

    def visitDanglingLink (self, file, stat):
        print >>sys.stderr, 'Visited dangling link', file

    #
    # Actions to perform when encountering a directory.  Override that function to
    # modify behaviour.
    #
    def visitDirectory (self, file, stat):
        print >>sys.stderr, 'Visited directory', file

    def __getattr__ (self, attr):
        if (attr == 'total_bytes'):
            return self.__total_bytes
        elif (attr == 'total_files'):
            return self.__total_files

class DaemonCtl:
    def __init__(self, args):
        self.args = args
        self.logger = getLogger("caraldi.DaemonCtl")

    def readProcessId(self):
        f = open(self.args['PID_FILE'], 'r')
        pid = int(f.readline())
        f.close()
        return pid

    def isProgramRunning(self, pid):
        # Send a dummy signal to the process.  If it died, an exception is
        # thrown
        try:
            os.kill(pid, signal.SIGCONT)
            return 1
        except OSError:
            return 0


    def start(self):
        cwd = os.getcwd()

        if os.path.exists(self.args['PID_FILE']):
            self.logger.debug("pid file %s exists" % self.args['PID_FILE'])
            # Read the process id
            pid = self.readProcessId()

            if self.isProgramRunning(pid):
                print >> sys.stderr, '%s already started' % self.args['APP_NAME']
                sys.exit(3)
        else:
            self.logger.debug("pid file %s does not exist" % self.args['PID_FILE'])

        if not(os.path.exists(self.args['COMMAND'])):
            print >> sys.stderr, '%s cannot be found' % self.args['COMMAND']
            sys.exit(3)

        # Append program output to a log file
        l = open(self.args['LOG_FILE'], 'w')
        orig_stderr = os.dup(sys.stderr.fileno())
        os.dup2(l.fileno(), sys.stdout.fileno())
        os.dup2(l.fileno(), sys.stderr.fileno())

        finfo = os.stat(self.args['COMMAND'])[ST_MODE]
        executable = S_IMODE(finfo) & 0111
        if not(executable):
            sys.stderr = os.fdopen(orig_stderr, 'w')
            print >> sys.stderr, 'Cannot run %s, execute bit is missing' % self.args['COMMAND']
            sys.exit(5)

        if self.args.has_key('APP_HOME'):
            # Change current directory to APP_HOME
            self.logger.debug("Changing directory to %s" % self.args['APP_HOME'])
            os.chdir(self.args['APP_HOME'])

        # Start program in the background
        args = [self.args['COMMAND']]
        if self.args.has_key("ARGS"):
            self.logger.debug("starting %s %s" % (self.args['COMMAND'], string.join(self.args["ARGS"])))
            for arg in self.args["ARGS"]:
                args.append(arg)
        self.logger.debug("starting with args: %s" % args)
        pid = os.spawnv(os.P_NOWAIT, self.args['COMMAND'], args)

        # Wait a little
        time.sleep(.4)
        (status_pid, status) = os.waitpid(pid, os.WNOHANG)

        # Check program exit status, if available
        if status_pid != 0 and os.WIFEXITED(status):
            sys.stderr = os.fdopen(orig_stderr, 'w')
            print >> sys.stderr, 'Could not start %s.  Check %s for errors.' % (self.args['APP_NAME'], self.args["LOG_FILE"])
            sys.exit(2)

        # It's alive, so write down the process id
        os.chdir(cwd)
        f = open(self.args['PID_FILE'], 'w')
        print >> f, pid
        f.close()

    def warnNotRunning(self):
        if self.args['cmdargs'][0] == "stop":
            print >> sys.stderr, '%s is not running' % self.args['APP_NAME']
        else:
            print >> sys.stderr, 'Warning: %s was not running' % self.args['APP_NAME']

    def cleanup(self):
        os.unlink(self.args['PID_FILE'])

    def stop(self):
        if os.path.exists(self.args['PID_FILE']):
            # Read the process id
            pid = self.readProcessId()
        else:
            self.warnNotRunning()
            return

        if not(self.isProgramRunning(pid)):
            self.warnNotRunning()
            self.cleanup()
            return

        # Terminate program
        os.kill(pid, signal.SIGTERM)

        while self.isProgramRunning(pid):
            time.sleep(.1)

        self.cleanup()

class FilesSubstitution(DirStat):
    def __init__(self, source, fileRegexp, replaceRegexp, subst):
        self.replaceRegexp = replaceRegexp
        self.fileRegexp = fileRegexp
        self.subst = subst
        self.init()
        self.walk(source)

    def visitDirectory(self, dir, stat):
        pass

    def visitFile(self, fileName, stat):
        if re.search("/CVS/|dontLeaveMeEmpty.txt|\.cvsignore", fileName):
            return

        if re.search(self.fileRegexp, fileName):
            file = open(fileName, "r")
            outfileName = fileName + ".new"
            outfile = open(outfileName, "wc")
            firstMatch = 1

            while 1:
                line = file.readline()

                if not(line):
                    break

                while re.search(self.replaceRegexp, line):
                    if firstMatch:
                        print "Processing %s" % fileName
                        firstMatch = 0

                    line = re.sub(self.replaceRegexp, self.subst, line)
                    #print
                    #print "Replacing %s" % line
                    #print "With %s" % newline
                outfile.write(line)

            file.close()
            outfile.close()
            shutil.copyfile(outfileName, fileName)
            os.unlink(outfileName)
