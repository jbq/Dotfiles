# New ports collection makefile for:  numlockx
# Whom:                               Jean-Baptiste Quenot <jb.quenot@caraldi.com>
# Date Created:                       2003-09-09 16:05:29
#
# $FreeBSD: ports/x11/numlockx/Makefile,v 1.5 2004/02/06 13:12:48 trevor Exp $
#

PORTNAME=	numlockx
PORTVERSION=	1.1
CATEGORIES=	x11
MASTER_SITES=	http://ktown.kde.org/~seli/numlockx/ \
		http://caraldi.com/jbq/numlockx/

MAINTAINER=	jb.quenot@caraldi.com
COMMENT=	This little thingy allows you to start X with NumLock turned on

GNU_CONFIGURE=	yes
PLIST_FILES=	bin/numlockx
USE_X_PREFIX=	yes

# Needed for the "configure" program to find XTest and XKB header files
CONFIGURE_ENV=	CPPFLAGS="-I${X11BASE}/include"

.include <bsd.port.mk>
