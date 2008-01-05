#! /usr/bin/env python
# -*- coding: UTF-8 -*-

import mailbox, re
import sys, os
import email.Header, email.Utils

columns = 100

def decode(f):
    #print email.Header.decode_header(f)
    #print email.Utils.decode_params(email.Header.decode_header(f))
    #params = email.Utils.decode_params(email.Header.decode_header(f))
    params = email.Header.decode_header(f)
    s=''
    for a, b in params:
        # TODO big hack: decode_header should not strip spaces
        s = s + a + ' '
    return re.sub(' +$', '', s)

def _test():
    args = sys.argv[1:]
    if not args:
        for key in 'MAILDIR', 'MAIL', 'LOGNAME', 'USER':
            if key in os.environ:
                mbox = os.environ[key]
                break
        else:
            print "$MAIL, $LOGNAME nor $USER set -- who are you?"
            return
    else:
        for mbox in args:
            if mbox[:1] == '+':
                mbox = os.environ['HOME'] + '/Mail/' + mbox[1:]
            elif not '/' in mbox:
                if os.path.isfile('/var/mail/' + mbox):
                    mbox = '/var/mail/' + mbox
                else:
                    mbox = '/usr/mail/' + mbox
            if os.path.isdir(mbox):
                if os.path.isdir(os.path.join(mbox, 'cur')):
                    mb = mailbox.Maildir(mbox)
                else:
                    mb = mailbox.MHMailbox(mbox)
            else:
                fp = open(mbox, 'r')
                mb = mailbox.PortableUnixMailbox(fp)

            # Constituer la liste des messages
            msgs = []
            while 1:
                msg = mb.next()
                if msg is None:
                    break
                msgs.append(msg)
                # Je ne veux pas récupérer le contenu du message
                msg.fp = None

            summaries = []

            for msg in msgs:
                status = msg.getheader('x-status')
                #print 'status='+str(status)
                if (status != None):
                    if 'F' in status:
                        f = msg.getheader('from') or ""

                        # Enlever l'adresse email
                        f = re.sub('<.*>', '', f)
                        oldstyle = "^.+ \((.+)\)$"
                        f = re.sub(oldstyle, "\\1", f)
                        f = decode(f)
                        # Enlever les guillemets autour du nom
                        f = re.sub('^"(.+)"$', '\\1', f)

                        s = msg.getheader('subject') or ""
                        s = decode(s)
                        s = re.sub('\n', '', s)
                        d = msg.getheader('date') or ""

                        summaries.append('%26.26s   %20.20s   %48.48s' % (f, d[5:], s))

            if summaries:
                fmbox = '*' + re.sub(os.environ['HOME'] + "/mail/", "=", mbox) + '*'
                print
                print fmbox.center(columns).replace(' ', '-').replace('*', ' ')

                for summary in summaries:
                    print summary




if __name__ == '__main__':
    _test()
