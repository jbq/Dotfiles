#! /usr/local/bin/python

################################################################################
# File:          todo.py
# Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Purpose:       Produce a project history from a projectinfo XML document
# Date Created:  2004-02-11 17:17:32
# Revision:      $Id: confstyle 130 2003-09-09 13:26:36Z jbq $
################################################################################

# Pour faire marcher ce script sur FreeBSD, il faut installer utf8locale et
# libxslt

import caraldi.projectinfo, cgi, prefs

caraldi.projectinfo.Processor(cgi.FieldStorage(), prefs.prefs).todoList()
