################################################################################
# Copyright (c) 2004, Jean-Baptiste Quenot <jb.quenot@caraldi.com>
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
#
# Purpose:       Install a patched distribution automatically
# Date Created:  2006-07-27 16:02:44
# Revision:      $Id: confstyle 130 2003-09-09 13:26:36Z jbq $
#
# Usage: Inherit from class PatchDist and implement the build and install methods
#
# TODO:
#
# * provide methods to allow overriding packageName, packageFile, packageURL
#
# Requires installed programs: tar, patch, wget
#

import sys, os, os.path, glob, zipfile, shutil, caraldi, re
PATCH_COOKIE = "work/.patch-done"
BUILD_COOKIE = "work/.build-done"

def system(command):
    if (os.system(command)):
        raise "Command failed: %s" % command

def copyJar(src, dest):
    if not(os.path.exists(dest)) or caraldi.zipEntriesDiffer(src, dest):
        print "Installing %s" % dest
        if not(os.path.exists(os.path.dirname(dest))):
            os.makedirs(os.path.dirname(dest))
        shutil.copyfile(src, dest)

def checkVersionControl(artifact):
    add=0
    svnversion = os.popen("svnversion %s" % artifact)
    output = svnversion.read().rstrip()
    status = svnversion.close()
    if status == 0 and output == "exported":
        add = 1
    elif not(status == 0):
        add=1

    if add == 1:
        print
        print "Adding %s to version control" % artifact
        system("svn add %s" % artifact)
def createIvyFile(artifact, version):
    # FIXME this command is not reliable
    if not(os.path.exists("%s/ivy.xml" % artifact)):
        find = os.popen("find %s/.. -name ivy.xml | tail -1" % (artifact))
        ivyfile = find.read().rstrip()
        find.close()
        print
        print "Copying ivy.xml from %s" % os.path.dirname(ivyfile)
        system("svn cp %s %s" % (ivyfile, artifact))
    print
    print "Replacing revision number in %s/ivy.xml" % artifact
    system("""sed -i -e 's/revision="[^"]*"/revision="'%s'"/' %s/ivy.xml""" % (version, artifact))

class PatchDist:
    def __init__(self, portinfo):
        self.baseDir = os.path.abspath(".")
        self.packageName = "%s-%s" % (portinfo['PORTNAME'], portinfo['PORTVERSION'])
        self.portinfo = portinfo
        if portinfo.has_key('DISTNAME'):
            self.distName = portinfo['DISTNAME']
        else:
            self.distName = self.packageName
        if portinfo.has_key('WRKSRC'):
            self.workSource = portinfo['WRKSRC']
        else:
            self.workSource = "work/" + self.distName
        if portinfo.has_key('USE_ZIP'):
            self.extension = "zip"
        elif portinfo.has_key('USE_JAR'):
            self.extension = "jar"
        else:
            self.extension = "tar.gz"
        self.packageFile = os.path.abspath("%s.%s" % (self.distName, self.extension))
        self.packageURL = "%s%s" % (portinfo['MASTER_SITE'], os.path.basename(self.packageFile))
    def run(self):
        #print "Building %s" % self.packageName
        if not(os.path.exists("work")):
            os.mkdir("work")
        if not(os.path.exists(self.packageFile)):
            print
            print "Fetching %s" % self.packageURL
            self.fetch()
        if not(os.path.exists(self.workSource)):
            print
            print "Extracting %s" % self.packageFile
            self.extract()
        if not(os.path.exists(PATCH_COOKIE)):
            print
            print "Patching %s" % self.packageName
            self.patch()
            system("touch %s" % PATCH_COOKIE)
        if not(os.path.exists(BUILD_COOKIE)):
            print
            print "Building %s" % self.packageName
            self.build()
            system("touch %s" % BUILD_COOKIE)
        self.install()
        print
        print "PATCHDIST BUILD SUCCESSFUL"
    def extract(self):
        if self.portinfo.has_key('USE_ZIP'):
            system("cd work && unzip %s" % self.packageFile)
        elif self.portinfo.has_key('USE_JAR'):
            destDir = self.workSource + "/src"
            if not(os.path.exists(destDir)):
                os.makedirs(destDir)
                system("cd %s/src && jar xf %s" % (self.workSource, self.packageFile))
        else:
            system("cd work && tar zxf %s" % self.packageFile)
    def fetch(self):
        system("wget -O %s %s" % (self.packageFile, self.packageURL))
    def patch(self):
        for patch in glob.glob("patch-*"):
            self.srcsystem("patch -E -p0 < %s/%s" % (self.baseDir, patch))
    def build(self):
        pass
    def install(self):
        pass
    def srcsystem(self, command):
        system("cd %s && %s" % (self.workSource, command))

class JavaPatchDist(PatchDist):
    def __init__(self, portinfo):
        PatchDist.__init__(self, portinfo)
        if portinfo.has_key('PATCH_VERSION'):
            self.patchVersion = portinfo['PATCH_VERSION']
        else:
            self.patchVersion = "patched"
        if portinfo.has_key('JAVA_SRC'):
            self.javaSourcesDir = portinfo["JAVA_SRC"]
            self.buildSourcesCommand = "cd %s && jar cf %s/work/%s-%s-sources.jar ." % (self.javaSourcesDir, self.baseDir, self.packageName, self.patchVersion)
        if portinfo.has_key('JAVA_BUILD_CMD'):
            self.buildCommand = portinfo["JAVA_BUILD_CMD"]
        if portinfo.has_key('JAVA_REPO_GROUPID'):
            self.groupName = portinfo['JAVA_REPO_GROUPID']
        else:
            self.groupName = portinfo['PORTNAME']
    def build(self):
        self.srcsystem(self.buildCommand)
        self.srcsystem(self.buildSourcesCommand)
    def install(self):
        if not(self.ivyCache):
            raise "Please set JavaPatchDist's ivyCache attribute"
        if not(self.jarPath):
            raise "Please set JavaPatchDist's jarPath attribute"
        if not(self.repoDir):
            raise "Please set JavaPatchDist's repoDir attribute"

        artifactPath = "%s/%s/%s-%s" % (self.repoDir, self.portinfo['PORTNAME'], self.portinfo['PORTVERSION'], self.patchVersion)
        # Install classes jar
        src = "%s/%s" % (self.workSource, self.jarPath)
        dst = "%s/jars/%s-%s.jar" % (artifactPath, self.packageName, self.patchVersion)
        copyJar(src, dst)
        # XXX Update ivy cache (it is not automatic!)
        dst = "%s/%s/%s/jars/%s-%s.jar" % (self.ivyCache, self.groupName, self.portinfo['PORTNAME'], self.packageName, self.patchVersion)
        copyJar(src, dst)

        # Install sources jar
        src = "%s-%s-sources.jar" % (self.packageName, self.patchVersion)
        dst = "%s/sources/%s-%s.jar" % (artifactPath, self.packageName, self.patchVersion)
        copyJar("work/" + src, dst)
        # XXX Update ivy cache (it is not automatic!)
        dst = "%s/%s/%s/sources/%s-%s.jar" % (self.ivyCache, self.groupName, self.portinfo['PORTNAME'], self.packageName, self.patchVersion)
        copyJar("work/" + src, dst)

        checkVersionControl(artifactPath)
        createIvyFile(artifactPath, "%s-%s" % (self.portinfo['PORTVERSION'], self.patchVersion))

class UpdateIvyReferences(caraldi.DirStat):
    def __init__(self, organisation, name, newrevision):
        caraldi.DirStat.__init__(self)
        self.organisation = organisation
        self.name = name
        self.newrevision = newrevision
    def visitLink(self, path, stat):
        pass
    def visitFile(self, path, stat):
        if re.search("/ivy.xml$", path) and path.find('/target/') == -1:
            f = open(path)
            content = f.read()
            f.close()
            match = '<dependency org="%s" name="%s"' % (self.organisation, self.name)
            if content.find(match) != -1:
                print "Processing", path
                newcontent = re.sub(match + ' rev="[^"]*"', match + ' rev="%s"' % self.newrevision, content)
                f = open(path, 'w')
                f.write(newcontent)
                f.close()
    def visitDirectory(self, path, stat):
        pass
