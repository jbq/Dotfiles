#! /usr/bin/env python

################################################################################
# File:          history.py
# Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Purpose:       Produce a todo-list from a projectinfo XML document
# Date Created:  2004-02-11 17:16:48
# Revision:      $Id: confstyle 130 2003-09-09 13:26:36Z jbq $
################################################################################

# Pour faire marcher ce script sur FreeBSD, il faut installer utf8locale et
# libxslt

import caraldi.projectinfo, cgi, prefs, sys, getopt

opts, args = getopt.getopt (sys.argv[1:], 'v:d', ['view=', 'debug'])

params = {}

# Fetch options
for o, a in opts:
    if o in ("-v", "--view"):
        params['view']=a
    elif o in ("-d", "--debug"):
        logger.setLevel(logging.DEBUG)

params['doc'] = args[0]
params['details'] = 1
params['minDate'] = "01.10.2007"

caraldi.projectinfo.Processor(cgi.FieldStorage(), prefs.prefs, params).projectHistory()
