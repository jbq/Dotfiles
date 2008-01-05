# -*- coding: UTF-8 -*
#
################################################################################
# Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Purpose:       Process Project Info XML documents
# Date Created:  2005-02-10 14:55:30
# Revision:      $Id: confstyle 130 2003-09-09 13:26:36Z jbq $
#
# TODO: unify processDateInterval and processDate, the former should use the
# latter
################################################################################

import string, time, sys, traceback, logging, datetime, exceptions, re, prefs
from types import *
import libxslt
import libxml2
import os, sys, caraldi.cgi, caraldi.xslt

logging.basicConfig()
logger = logging.getLogger(sys.argv[0])
logger.setLevel(logging.DEBUG)

class Error(exceptions.Exception):
    def __init__(self, msg):
        self.msg = msg
    def __str__(self):
        return self.msg

def add_bugzilla_links(doc):
    ctx = doc.xpathNewContext()
    # IGNORECASE and DOTALL
    rexp = r"(?is)^(.*)(bug)\s+([0-9]+)(.*)$"
    for textNode in ctx.xpathEvalExpression("//item//text() | //body//text()"):
        textNodeCtx = doc.xpathNewContext()
        textNodeCtx.setContextNode(textNode)
        bugzilla_list = textNodeCtx.xpathEvalExpression('ancestor-or-self::node()[@bugzilla]')

        if bugzilla_list:
            # Take last declared bugzilla URL, ie nearest from text node
            bugzilla = bugzilla_list[-1].prop("bugzilla")

            textNodeValue = str(textNode)
            if re.match(rexp, textNodeValue):
                newnode = doc.newDocNode(None, "a", re.sub(rexp, r"\2 \3", textNodeValue))
                newnode.newProp("href", re.sub(rexp, r"%s/show_bug.cgi?id=\3" % bugzilla, textNodeValue))
                textNode.replaceNode(newnode)
                # Cannot use newDocText() because it does not preserve entities
                # such as &lt;, using newDocNodeEatName() instead
                before = doc.newDocNodeEatName(None, "span", re.sub(rexp, r"\1", textNodeValue))
                after = doc.newDocNodeEatName(None, "span", re.sub(rexp, r"\4", textNodeValue))
                newnode.addPrevSibling(before)
                newnode.addNextSibling(after)

class Processor:
    def __init__(self, form, prefs, params=None):
        self.prefs = prefs
        self.prefs['documentRoot'] = os.path.abspath(self.prefs['documentRoot'])
        sys.excepthook = caraldi.cgi.reportErrorHTML

        # Command-line environment: simulate CGI
        if not os.environ.has_key('SERVER_NAME'):
            os.environ['SERVER_NAME'] = 'opensourceconsulting.info'
            self.params = params
        else:
            self.params = caraldi.cgi.FieldStorageDict(form).data

        # id can be repeated
        if self.params.has_key('id'):
            # Only one id, not interpreted as list by cgi.FieldStorage
            if type(self.params['id']) != list:
                idlist = []
                # Convert id to string because XML attributes are strings
                idlist.append(str(self.params['id']))
                self.params['id'] = idlist

        self.xsltparams = caraldi.cgi.XSLTDict (self.params).data

    def normpath(self, doc):
        url = os.path.normpath(caraldi.join(self.prefs['documentRoot'], doc))

        if url.find(self.prefs['documentRoot']) != 0:
            # Attempt to access outside of document root
            raise Error("File not found")

        return url

    def projectHistory(self):
        urls = []

        if type(self.params['doc']) == list:
            for doc in self.params['doc']:
                urls.append(self.normpath(doc))
        else:
            logger.debug("urls = %s" % urls)
            urls.append(self.normpath(self.params['doc']))
            logger.debug("urls = %s" % urls)

        if self.params.has_key('view'):
            stylesheet = "file://" + caraldi.join(self.prefs['stylesheetsDir'], 'history-%s.xsl' % self.params['view'])
        else:
            stylesheet = "file://" + caraldi.join(self.prefs['stylesheetsDir'], 'history.xsl')

        # Get XML data
        projectInfo = ProjectHistory(urls, self.params, self.prefs)
        xml = projectInfo.output.serialize()

        if self.params.has_key('dump') and self.params['dump']:
            caraldi.cgi.contentType('text/xml')
            print xml

        else:
            result = caraldi.xslt.transformData(xml, stylesheet, self.xsltparams)

            if self.params.has_key('dump2') and self.params['dump2']:
                caraldi.cgi.contentType('text/xml')
                print str(result)
                return

            if self.params.has_key('view') and self.params['view'] == 'dotproject':
                stylesheetPath = caraldi.join(self.prefs['stylesheetsDir'], 'sql.xsl')
                if not(os.path.exists(stylesheetPath)):
                    raise "Could not find stylesheet: sql.xsl"
                stylesheet = "file://" + stylesheetPath
                caraldi.cgi.contentType('text/plain', 'UTF-8')
                print caraldi.xslt.transformData(str(result), stylesheet, {})
            else:
                caraldi.cgi.contentType('text/html', 'UTF-8')
                print str(result)

    def todoList(self):
        url = self.normpath(self.params['doc'])
        stylesheet = "file://" + caraldi.join(self.prefs['stylesheetsDir'], 'todolist.xsl')

        # Get XML data
        projectInfo = TodoList(url, self.params, self.prefs)
        xml = projectInfo.output.serialize()

        if self.params.has_key('dump') and self.params['dump']:
            caraldi.cgi.contentType('text/xml')
            print xml

        else:
            result = caraldi.xslt.transformData(xml, stylesheet, self.xsltparams)
            caraldi.cgi.contentType('text/html', 'UTF-8')
            print str(result)

class DaysHoursMinutes:
    timespent = None

    def __init__(self, timespent):
        self.timespent = timespent

    def format(self):
        array = {}
        # Days last 8h
        array['days'] = int(self.timespent / 28800)
        array['hours'] = int(self.timespent % 28800 / 3600)
        array['minutes'] = int(self.timespent % 3600 / 60)

        #logger.debug("timespent=" + str(self.timespent))
        #logger.debug("days=" + str(array['days']) + ", hours=" + str(array['hours']) + ", minutes=" + str(array['minutes']))

        format = ''

        if (array['days']):
            format += '%(days)ud'
        if (array['hours']):
            format += '%(hours)uh'
        if (array['minutes']):
            format += '%(minutes)um'
        return format % array


class SessionNodeFormatError(Exception):
    def __init__(self, node, msg):
        self.node = node
        self.message = msg

class TimeNodeFormatError(Exception):
    def __init__(self, node, msg):
        self.node = node
        self.message = msg

class DateFormatError(Exception):
    def __init__(self, msg):
        self.message = msg

class DateNodeFormatError(Exception):
    def __init__(self, node, msg):
        self.node = node
        self.message = msg

class SessionFormatError(Exception):
    pass

class NumberFormatError(Exception):
    pass

libxmlErrors = []
def libxmlErrorHandler(ctx, str):
    libxmlErrors.append(str.rstrip())

#
# Takes two DOM nodes or two strings (date and time) and returns a date array
#
class DateTimeParser:
    timeNode = None
    dateNode = None
    timeStr = None
    dateStr = None

    def __init__ (self, date, time):
        if type(date) is StringType:
            self.dateStr = date
            self.timeStr = time
        else:
            self.dateNode = date
            self.timeNode = time

            if self.timeNode != None:
                self.timeStr = self.timeNode.getContent()

            if self.dateNode != None:
                self.dateStr = self.dateNode.getContent()

    def dateTime(self):
        if self.timeStr == None:
            self.timeStr = '00:00:00'

        if self.dateStr == None:
            self.dateStr = '01/01/1970'

        logger.debug("timeStr=%s, dateStr=%s" %(self.timeStr, self.dateStr))

        dateArray = string.split(self.dateStr, '.')

        if len(dateArray) < 3:
            dateArray = string.split(self.dateStr, '/')

        if len(dateArray) < 3:
            if self.dateNode == None:
                raise DateFormatError ('Wrong format for date')
            else:
                raise DateNodeFormatError (self.dateNode, 'Wrong format for date')

        day = dateArray[0]
        month = dateArray[1]
        year = dateArray[2]
        timeArray = string.split(self.timeStr, ':')

        if len(timeArray) < 2:
            if self.timeNode == None:
                raise TimeFormatError ('Wrong format for time')
            else:
                raise TimeNodeFormatError (self.timeNode, "Wrong format for time: '%s'" % self.timeStr)

        if len(timeArray) == 2:
            second = 0
        else:
            second = timeArray[2]

        hour = timeArray[0]
        minute = timeArray[1]

        #logger.debug("year=" + str(year) + ", month=" + str(month) + ", day=" + str(day) + ", hour=" + str(hour) + ", minute=" + str(minute) + ", second=" + str(second))
        mydatetime = datetime.datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))

        return mydatetime

    def parse(self):
        return self.dateTime().timetuple()

class ProjectInfo:
    #
    # Class attributes: input, ctxt, output
    #
    ABSOLUTE_DATES = 0
    RELATIVE_DATES = 1
    params = None
    # XML Document
    output = None

    def __init__ (self, fileList, params, prefs):
        logger.debug("fileList = %s" % fileList)
        self.params = params
        self.prefs = prefs
        libxml2.registerErrorHandler(libxmlErrorHandler, None)
        libxslt.registerErrorHandler(libxmlErrorHandler, None)
        libxml2.lineNumbersDefault(1)
        try:
            self.input = libxml2.newDoc('1.0')
            inputDocumentNode = self.input.newDocNode(None, "document", None)
            self.input.addChild(inputDocumentNode)

            for file in fileList:
                doc = libxml2.parseFile(file)
                doc.xincludeProcess()
                add_bugzilla_links(doc)
                if self.prefs.has_key('dotProject.host'):
                    self.fetch_users(doc)
                    self.fetch_dpid(doc)
                inputDocumentNode.addChild(doc)

            self.ctxt = self.input.xpathNewContext()

        except libxml2.parserError, msg:
            raise libxml2.parserError('%s in document %s' % (msg, file))

        self.output = libxml2.newDoc('1.0')

        # Define locale to be used by strftime and other time-related helper
        # functions.  UTF-8 is important because formatted dates contain non
        # 7-bit ASCII characters
        import locale
        locale.setlocale(locale.LC_CTYPE, 'fr_FR.UTF-8')
        locale.setlocale(locale.LC_TIME, 'fr_FR.UTF-8')

    def __repr__ (self):
        return self.output.serialize()

    def fetch_users(self, doc):
        import MySQLdb
        db=MySQLdb.connect(host=self.prefs['dotProject.host'],user=self.prefs['dotProject.user'],passwd=self.prefs['dotProject.passwd'],db=self.prefs['dotProject.db'])
        ctx = doc.xpathNewContext()
        # IGNORECASE and DOTALL
        for textNode in ctx.xpathEvalExpression("//session[@uid]"):
            uid = textNode.prop('uid')
            cursor = db.cursor()
            cursor.execute("SELECT user_id, user_first_name, user_last_name FROM users WHERE user_username = '%s'" % uid)
            result = cursor.fetchone()
            textNode.setProp('dpUserName', "%s %s" % (result[1], result[2]))
            textNode.setProp('dpUserID', "%s" % result[0])

    def fetch_dpid(self, doc):
        import MySQLdb
        db=MySQLdb.connect(host=self.prefs['dotProject.host'],user=self.prefs['dotProject.user'],passwd=self.prefs['dotProject.passwd'],db=self.prefs['dotProject.db'])
        ctx = doc.xpathNewContext()
        # IGNORECASE and DOTALL
        for textNode in ctx.xpathEvalExpression("//session[@dpid]"):
            uid = textNode.prop('dpid')
            cursor = db.cursor()
            cursor.execute("SELECT task_name FROM tasks WHERE task_id = '%s'" % uid)
            result = cursor.fetchone()
            textNode.setProp('dpTask', result[0])

    def isToday (self, date):
        # TODO use datetime module
        today = time.localtime(time.time())
        return (today[0] == date[0] or today[0] % 1000 == date[0]) \
            and date[1] == today[1] and date[2] == today[2]

    def isTomorrow (self, date):
        # TODO use datetime module
        today = time.localtime(time.time() + 24 * 3600)
        return (today[0] == date[0] or today[0] % 1000 == date[0]) \
            and date[1] == today[1] and date[2] == today[2]

    def isYesterday (self, date):
        # TODO use datetime module
        today = time.localtime(time.time() - 24 * 3600)
        return (today[0] == date[0] or today[0] % 1000 == date[0]) \
            and date[1] == today[1] and date[2] == today[2]

    def isPast (self, date):
        # TODO use datetime module
        return time.mktime(date) < time.time()

    def isNearFuture (self, date):
        # TODO use datetime module
        soon = time.mktime(date)
        now = time.time()
        return soon > now and ((soon - now) < 7 * 24 * 3600)

    def processUnknownDate(self, session, relativeDates=0):
        sessionContext = self.input.xpathNewContext()
        sessionContext.setContextNode(session)

        if sessionContext.xpathEvalExpression("from"):
            return self.processDateInterval(session)
        else:
            return self.processDate(session, relativeDates)

    #
    # Normalize date and time: add normalized date and time called ndate and
    # ntime, add a numeric timestamp and a relative date like 'today' or
    # 'yesterday'
    #
    def processDate(self, node, relativeDates=0):
        # Extract date and time from current XML fragment
        dateNode = self.getFirstChildByName(node, 'date')
        timeNode = self.getFirstChildByName(node, 'time')

        nDaytimeNode = node.newChild(None, 'ndaytime', '00:00:00')

        # If no time is provided, assume 00:00:00
        if timeNode == None:
            nTimeNode = node.newChild(None, 'ntime', '00:00:00')
        else:
            nTimeNode = timeNode

        # Make a timestamp from date and time
        try:
            timestamp = DateTimeParser(dateNode, nTimeNode).parse()
            daytimestamp = DateTimeParser(dateNode, nDaytimeNode).parse()
        except Exception:
            logger.error(node.serialize())
            raise

        # Generate a new node for normalized date
        node.newChild(None, 'ndate', time.strftime('%A %e %B %Y', timestamp))

        # Generate a new node for normalized time if needed
        if timeNode:
            node.newChild(None, 'ntime', time.strftime('%X', timestamp))

        # Generate a new node for seconds since 1970
        node.newChild(None, 'timestamp', str(int(time.mktime(timestamp))))
        node.newChild(None, 'daytimestamp', str(int(time.mktime(daytimestamp))))
        node.newChild(None, 'datetime', time.strftime('%F 00:00:00', daytimestamp))

        # Generate a new node for relative date like Today or Tomorrow
        if relativeDates:
            relativeDate = node.newChild(None, 'relative', None)

            if self.isToday(timestamp):
                relativeDate.newChild(None, 'today', None)
            elif self.isTomorrow(timestamp):
                relativeDate.newChild(None, 'tomorrow', None)
            elif self.isYesterday(timestamp):
                relativeDate.newChild(None, 'yesterday', None)

            if self.isPast(timestamp):
                relativeDate.newChild(None, 'past', None)
            elif self.isNearFuture(timestamp):
                relativeDate.newChild(None, 'near-future', None)
        #else:
        #    node.newChild(None, 'relative', time.strftime('%A %e %B %Y', timestamp))
        return {"fromTime": int(time.mktime(timestamp))}

    #
    # Normalize date created and date due using processDate
    #
    def normalizeTodo (self, todo):
        self.currentDateTime = None
        for node in self.getChildrenByName(todo, 'datecreated'):
            self.processUnknownDate(node, self.ABSOLUTE_DATES)
        for node in self.getChildrenByName(todo, 'datedue'):
            self.processUnknownDate(node, self.RELATIVE_DATES)

    def processDateInterval(self, session):
        minFrom = None
        maxTo = None

        fromNode = self.getFirstChildByName(session, 'from')
        toNode = self.getFirstChildByName(session, 'to')

        if (toNode == None):
            toNode = session.newChild(None, 'to', None)
            # Be careful, 24:00 is not accepted by DateTimeParser
            toNode.newChild(None, 'time', '00:00')
            wholeDay = 1
        else:
            wholeDay = 0

        for node in [fromNode, toNode]:
            logger.debug("currentDateTime=%s" % self.currentDateTime)
            dateNode = self.getFirstChildByName(node, 'date')
            timeNode = self.getFirstChildByName(node, 'time')

            if timeNode == None and dateNode == None:
                raise SessionNodeFormatError(node, 'No date nor time specified')

            daytimeNode = node.newChild(None, 'daytime', '00:00')

            if timeNode == None:
                timeNode = node.newChild(None, 'time', '00:00')

            if dateNode == None:
                # Inscrire la dernière date mémorisée
                # Incrémenter la date de fin si nécessaire (autour de minuit)
                try:
                    newDateTime = DateTimeParser(None, timeNode).dateTime()
                except Exception:
                    logger.error("There was an error with session/" + node.name + "/time node: " + session.serialize())
                    raise

                if not(self.currentDateTime):
                    raise "Internal error: no currentDateTime"
                # Replace year, month and date initialized at 1970, 01, 01 by
                # DateTimeParser because we passed None date node
                newDateTime = newDateTime.replace(self.currentDateTime.year, self.currentDateTime.month, self.currentDateTime.day)

                if wholeDay:
                    # Avancer d'un jour si aucune date n'était précisée dans
                    # session/to
                    newDateTime = newDateTime.fromtimestamp(time.mktime(newDateTime.timetuple()) + 24 * 3600)

                if self.currentDateTime > newDateTime:
                    # Avancer d'un jour si l'heure session/to/time est
                    # inférieure à l'heure session/from/time
                    newDateTime = newDateTime.fromtimestamp(time.mktime(newDateTime.timetuple()) + 24 * 3600)
                logger.debug("newDateTime=%s" % newDateTime)
                dateNode = node.newChild(None, 'date', newDateTime.strftime('%x'))

            # Mémoriser la dernière date inscrite
            try:
                self.currentDateTime = DateTimeParser(dateNode, timeNode).dateTime()
                logger.debug("Now, currentDateTime=%s" % self.currentDateTime)
                currentDate = DateTimeParser(dateNode, daytimeNode).dateTime()
            except Exception:
                logger.error("There was an error with session/" + node.name + "/{date,time} nodes: " + session.serialize())
                raise

            # Ajouter les éléments timestamp ndate et ntime à session/from
            # ou session/to
            timestamp = int(time.mktime(self.currentDateTime.timetuple()))
            daytimestamp = int(time.mktime(currentDate.timetuple()))
            node.newChild(None, 'timestamp', str(timestamp))
            node.newChild(None, 'daytimestamp', str(daytimestamp))
            if (self.currentDateTime.year < 1900):
                self.currentDateTime = self.currentDateTime.replace(self.currentDateTime.year + 2000, self.currentDateTime.month, self.currentDateTime.day)
            node.newChild(None, 'ndate', time.strftime('%A %e %B %Y', self.currentDateTime.timetuple()))
            node.newChild(None, 'datetime', self.currentDateTime.strftime('%F 00:00:00'))
            node.newChild(None, 'ntime', self.currentDateTime.strftime('%X'))

            # Mémoriser les champs minimum et maximum
            if (minFrom == None):
                minFrom = self.currentDateTime
            if (maxTo == None):
                maxTo = self.currentDateTime
            if (timestamp < int(time.mktime(minFrom.timetuple()))):
                minFrom = self.currentDateTime
            if (timestamp > int(time.mktime(maxTo.timetuple()))):
                maxTo = self.currentDateTime
            # END <<< for node in [fromNode, toNode]: >>>

        # Get session/from/timestamp and session/to/timestamp to compute
        # time spent
        fromTime = int(self.getFirstChildByName(fromNode, 'timestamp').getContent())
        toTime = int(self.getFirstChildByName(toNode, 'timestamp').getContent())
        timespent = toTime - fromTime

        # Add elements session/timespent, session/timespent/seconds and
        # session/timespent/representation
        timespentNode = session.newChild(None, 'timespent', None)

        # Session lasts whole day, but it's not 24h work really, it counts
        # only for 8h
        if (timespent == 86400):
            timespent = 28800

        timespentNode.newChild(None, 'seconds', str(timespent))
        timespentNode.newChild(None, 'representation', DaysHoursMinutes(timespent).format())

        return {"minFrom": minFrom, "maxTo": maxTo, "fromTime": fromTime}

    def normalizeSessions (self, sessions):
        result = None
        self.currentDateTime = None
        for session in self.getChildrenByName(sessions, 'session'):
            logger.debug(": currentDateTime=%s" % self.currentDateTime)
            logger.debug("read session on line %u" % session.lineNo())

            result = self.processUnknownDate(session)

            # Filter out sessions not in date range if specified
            if self.params.has_key('minDate'):
                try:
                    minTime = int(time.mktime(DateTimeParser(self.params['minDate'], None).parse()))
                except Exception:
                    logger.error("There was an error with minDate: " + self.params['minDate'])
                    raise
                if result['fromTime'] < minTime:
                    session.unlinkNode()
                    session.freeNode()
            if self.params.has_key('maxDate'):
                try:
                    maxTime = int(time.mktime(DateTimeParser(self.params['maxDate'], None).parse()))
                except Exception:
                    logger.error("There was an error with maxDate: " + self.params['maxDate'])
                    raise

                # Greater or equals
                if result['fromTime'] >= maxTime + 24 * 3600:
                    session.unlinkNode()
                    session.freeNode()

        # results can be None if <sessions> contains no <session>
        if result:
            if result.has_key("minFrom"):
                newNode = sessions.newChild(None, 'minFrom', None)
                newNode.newChild(None, 'ndate', result["minFrom"].strftime('%x'))

            if result.has_key("maxTo"):
                newNode = sessions.newChild(None, 'maxTo', None)
                newNode.newChild(None, 'ndate', result["maxTo"].strftime('%x'))

    def getChildrenByName(self, node, name):
        array = []
        node = node.get_children()

        if not node:
            return array

        while 1:
            node = node.get_next()
            if not node:
                break
            if not node.isText() and node.name == name:
                array.append(node)
        return array

    def getAttribute(self, node, name):
        node = node.get_children()
        array = []
        while 1:
            if not node:
                break
            if node.isAttribute() and node.name == name:
                return node
            node = node.get_next()
        return None

    def getFirstChildByName(self, node, name):
        node = node.get_children()
        array = []
        while 1:
            if not node:
                break
            if not node.isText() and node.name == name:
                return node
            node = node.get_next()
        return None

class TodoList (ProjectInfo):
    #
    # Class attributes: input, ctxt, output
    #
    def __init__ (self, file, params, prefs):
        ProjectInfo.__init__(self, [file], params, prefs)
        try:
            self.build ()
        except NumberFormatError, msg:
            raise NumberFormatError (str(msg) + ' in file ' + file)

    def build (self):
        # Remove all todo sessions from input tree, we don't need them
        for node in self.ctxt.xpathEvalExpression('//todo/sessions'):
            node.unlinkNode ()
            node.freeNode ()

        # Build the output tree
        todolist = self.output.newChild(None, 'todolist', None)
        for todo in self.ctxt.xpathEvalExpression ('//todo'):
            if self.params.has_key('id'):
                #logger.error("todo.id=" + todo.prop('id'))
                #logger.error("params.id=" + str(self.params['id']))
                if not(todo.prop('id') in self.params['id']):
                    todo.unlinkNode()
                    todo.freeNode()
                    continue
            self.normalizeTodo (todo)
            todolist.addChild (todo)
        now = todolist.newChild(None, 'now', None)
        now.newChild(None, 'timestamp', str(int(time.mktime(time.localtime()))))

class ProjectHistory (ProjectInfo):
    def __init__ (self, fileList, params, prefs):
        try:
            ProjectInfo.__init__(self, fileList, params, prefs)
            self.build ()
        except SessionNodeFormatError:
            snfe = sys.exc_value
            raise SessionFormatError (str(snfe.message) + ' in file ' + file + ' on line ' + str(snfe.node.lineNo()))
        except libxml2.parserError, msg:
            raise Error("Cannot parse document: %s: %s" % (msg, ' '.join(libxmlErrors)))
        except Exception, msg:
            logger.error("Could not build project history: %s" % msg)
            raise

    def build (self):
        # Remove all todo descriptions from input tree, we don't need them
        for node in self.ctxt.xpathEvalExpression('//todo/description'):
            node.unlinkNode ()
            node.freeNode ()

        # Build the output tree
        todolist = self.output.newChild(None, 'todolist', None)

        for projectinfoNode in self.ctxt.xpathEval('//projectinfo'):
            projectinfoContext = self.input.xpathNewContext()
            projectinfoContext.setContextNode(projectinfoNode)
            projectinfo = todolist.newChild(None, "projectinfo", "")

            # Note: copyPropList does not work
            # See http://lists.entrouvert.be/pipermail/glasnost-cvs-commits/2004-March/004175.html
            attribute = projectinfoNode.properties
            while attribute is not None:
                projectinfo.newProp(attribute.name, attribute.content)
                attribute = attribute.next

            for todo in projectinfoContext.xpathEval('todo'):
                if self.params.has_key('id'):
                    if not(todo.prop('id') in self.params['id']):
                        todo.unlinkNode()
                        todo.freeNode()
                        continue
                sessions = self.getFirstChildByName(todo, 'sessions')

                if sessions != None:
                    self.normalizeTodo (todo)
                    self.normalizeSessions (sessions)
                    projectinfo.addChild (todo)

                    self.ctxt.setContextNode(sessions)
                    timespent = self.ctxt.xpathEvalExpression('sum(session/timespent/seconds) + 3600*8*count(session[not(timespent)])')
                    node = sessions.newChild(None, 'timespent', None)
                    node.newChild(None, 'seconds', str(int(timespent)))
                    node.newChild(None, 'representation', DaysHoursMinutes(timespent).format())
