# New ports collection makefile for:	maven
# Date created:				17 October 2003
# Whom:					Rui Lopes <rui@ruilopes.com>
#
# $FreeBSD: ports/devel/maven/Makefile,v 1.8 2005/02/24 15:37:18 hq Exp $
#

PORTNAME=	maven
PORTVERSION=	1.0.2
PORTREVISION=	1
CATEGORIES=	devel java
MASTER_SITES=	${MASTER_SITE_APACHE}
MASTER_SITE_SUBDIR=	${PORTNAME}/binaries

MAINTAINER=	jbq@caraldi.com
COMMENT=	Java project management and project comprehension tool

USE_BZIP2=	yes
USE_JAVA=	yes
JAVA_VERSION=	1.3+
NO_BUILD=	yes
DATADIR=	${JAVASHAREDIR}/${PORTNAME}

SUB_FILES=	maven.sh \
		pkg-message
SUB_LIST=	JAVA_HOME=${JAVA_HOME}

DIRECTORIES=	lib lib/endorsed plugins

do-install:
	${MKDIR} ${DATADIR}/bin
	${INSTALL_SCRIPT} ${WRKSRC}/bin/install_repo.sh ${DATADIR}/bin
	${INSTALL_SCRIPT} ${WRKDIR}/maven.sh ${DATADIR}/bin/maven
	${LN} -fs ${DATADIR}/bin/maven ${PREFIX}/bin
	${INSTALL_DATA} ${WRKSRC}/bin/forehead.conf ${DATADIR}/bin
	${INSTALL_DATA} ${WRKSRC}/*.xsd ${DATADIR}
.for dir in ${DIRECTORIES}
	${MKDIR} ${DATADIR}/${dir}
	${INSTALL_DATA} ${WRKSRC}/${dir}/*.jar ${DATADIR}/${dir}
.endfor

post-install:
.if !defined(BATCH)
	@${CAT} ${PKGMESSAGE}
.endif

# This target is only meant to be used by the port maintainer.
x-generate-plist:
	(${PORTSDIR}/Tools/scripts/plist -d -m ${MTREE_FILE} ${PREFIX}|${SED} -E 's,.*share/nls/.+$$,,g;s,${DATADIR:S,^${PREFIX}/,,},%%DATADIR%%,g'|${TR} -s '\n') > temp-pkg-plist

.include <bsd.port.mk>
