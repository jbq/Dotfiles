--- slimserver.orig	Sun Dec 31 13:43:59 2006
+++ slimserver	Sun Dec 31 13:44:41 2006
@@ -33,6 +33,8 @@
 
 PGREP=/usr/bin/pgrep
 
+export PATH=/usr/sbin:/usr/bin:/sbin:/bin
+
 slimserver_start_precmd()
 {
 	if [ ! -d ${statedir} ]; then
