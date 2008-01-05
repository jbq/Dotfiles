#! /usr/bin/env python

import caraldi, sys, os, subprocess

class EolStyleWalker(caraldi.DirStat):
	def visitFile(self, file, stat):
		svnpg = subprocess.Popen(["svn", "pg", "svn:eol-style", file], stdout=subprocess.PIPE)
		(stdout, stderr) = svnpg.communicate()
		eolstyle = stdout.rstrip()

		if eolstyle == "":
			svnmimetype = subprocess.Popen(["svn", "pg", "svn:mime-type", file], stdout=subprocess.PIPE)
			(stdout, stderr) = svnmimetype.communicate()
			mimetype = stdout.rstrip()
			if mimetype == "application/octet-stream":
				print "Not touching %s with mime-type %s" % (file, mimetype)
			else:
				print "%s has no svn:eol-style, fixing" % file
				if caraldi.spawn(["svn", "ps", "svn:eol-style", "native", file]):
					print "Converting line endings"
					caraldi.execute(["dos2unix", file])
					caraldi.execute(["svn", "ps", "svn:eol-style", "native", file])
		elif eolstyle != "native":
			print "%s has unknown svn:eol-style %s" % (file, eolstyle)
	def visitDirectory(self, dir, stat):
		pass
		#print
		#caraldi.DirStat.visitDirectory(self, dir, stat)

if __name__ == "__main__":
	walker = EolStyleWalker()
	#walker.debug(True)
	walker.patterns = ["-*(.)", "-.svn", "-target", "-.*", "+.settings", "+*.prefs", "+*.properties", "+*.sql", "+*.java", "+*.html", "+*.htm", "+*.css", "+*.js", "+*.vm", "+*.xml", "+*.txt"]

	if len(sys.argv) == 1:
		walker.walk(".")
	for dir in sys.argv[1:]:
		print
		print "Walking in %s" % dir
		walker.walk(dir)
