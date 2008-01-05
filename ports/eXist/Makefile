# New ports collection makefile for:	eXist
# Date created:				2005-05-16 09:45:26
# Whom:					Jean-Baptiste Quenot <jb.quenot@caraldi.com>
#
# $FreeBSD$
#

PORTNAME=		eXist
PORTVERSION=		1.0b2
CATEGORIES=		www java
MASTER_SITES=		${MASTER_SITE_SOURCEFORGE}
MASTER_SITE_SUBDIR=	exist

MAINTAINER=		jb.quenot@caraldi.com
COMMENT=		Open Source Native XML Database

USE_ZIP=		yes
USE_JAVA=		yes
JAVA_VERSION=		1.3+
USE_PYTHON=		1.6+

APP_NAME=		${PORTNAME}
APP_HOME=		${LOCALBASE}/${PORTNAME}
PID_FILE?=		${APP_HOME}/${APP_NAME}.pid

SUBSTITUTIONS=		-e "s|%%APP_HOME%%|${APP_HOME}|g" \
			-e "s|%%APP_NAME%%|${APP_NAME}|g" \
			-e "s|%%FILESDIR%%|${FILESDIR}|g" \
			-e "s|%%GROUP%%|${GROUP}|g" \
			-e "s|%%GID%%|${GID}|g" \
			-e "s|%%JAVA_HOME%%|${JAVA_HOME}|g" \
			-e "s|%%JAVA%%|${JAVA}|g" \
			-e "s|%%LOG_FILE%%|${LOG_FILE}|g" \
			-e "s|%%PYTHON_CMD%%|${PYTHON_CMD}|g" \
			-e "s|%%PID_FILE%%|${PID_FILE}|g" \
			-e "s|%%PORT%%|${PORT}|g" \
			-e "s|%%PORTNAME%%|${PORTNAME}|g" \
			-e "s|%%PREFIX%%|${PREFIX}|g" \
			-e "s|%%RUNASUID%%|${RUNASUID}|g" \
			-e "s|%%RUNASUSER%%|${RUNASUSER}|g" \
			-e "s|%%WRKDIR%%|${WRKDIR}|g" \
			-e "s|%%WRKSRC%%|${WRKSRC}|g"

# Disable build as there is no Makefile
do-build:

# Do the install ourselves as there is no Makefile
do-install:
	@cd ${WRKSRC} && ${FIND} . | ${CPIO} -pdmuL -R ${LIBOWN}:${LIBGRP} ${APP_HOME}
	@${CHMOD} 755 ${APP_HOME}
	@${INSTALL_SCRIPT} ${FILES}/caraldi.py ${APP_HOME}/thirdparty
	@${SED} ${SUBST} ${FILES}/eXistctl > ${WRKDIR}/eXistctl
	@${SED} ${SUBST} ${FILES}/eXist.sh.in > ${WRKDIR}/eXist/sh
	@${INSTALL_SCRIPT} ${WRKDIR}/eXistctl ${LOCALBASE}/sbin
	@${INSTALL_SCRIPT} ${WRKDIR}/eXist.sh ${LOCALBASE}/etc/rc.d

.include <bsd.port.mk>
