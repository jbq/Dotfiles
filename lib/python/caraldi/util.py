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
#
# Traverse directories to find files and call the callback function visitFile
# each time.  Warning: lstat() does not follow symbolic links unlike stat()
# Override the class to change visitFile behaviour.

import os, sys, re, signal, time, string, zipfile

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

def zipEntriesDiffer(mainf, subordinatef):
    return oneWayZipEntriesDiffer(mainf, subordinatef) or oneWayZipEntriesDiffer(subordinatef, mainf)

def oneWayZipEntriesDiffer(mainf, subordinatef):
    # Idea from http://www.jlwalkerassociates.com/tools/diffjar/README.html
    # Python implementation using http://docs.python.org/lib/module-zipfile.html
    mainzipinfo = zipfile.ZipFile(mainf).infolist()
    subordinatezip = zipfile.ZipFile(subordinatef)
    subordinate_members = subordinatezip.namelist()

    for info in mainzipinfo:
        # entries in main and subordinate are not necessarily at the same
        # position in the archive
        if not(info.filename in subordinate_members):
            return 1
        subordinateinfo = subordinatezip.getinfo(info.filename)
        if info.CRC != subordinateinfo.CRC:
            return 1
    return 0

def join(dir, file):
    result = ""
    if dir:
        result = result + re.sub("/$", "", dir) + "/"
    result = result + re.sub("^/", "", file)
    return result

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
