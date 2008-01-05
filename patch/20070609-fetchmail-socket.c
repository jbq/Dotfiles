--- socket.c.orig	Sun Dec 17 01:05:31 2006
+++ socket.c	Sat Jun  9 14:51:48 2007
@@ -779,7 +779,8 @@
 
 	if (err != X509_V_OK && err != _prev_err && !(_check_fp != 0 && _check_digest && !strict)) {
 		_prev_err = err;
-		report(stderr, GT_("Server certificate verification error: %s\n"), X509_verify_cert_error_string(err));
+		if (strict)
+			report(stderr, GT_("Server certificate verification error: %s\n"), X509_verify_cert_error_string(err));
 		/* We gave the error code, but maybe we can add some more details for debugging */
 		switch (err) {
 		case X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT:
