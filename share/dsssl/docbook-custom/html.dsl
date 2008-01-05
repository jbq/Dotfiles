<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
	<!ENTITY html-ss PUBLIC "-//Norman Walsh//DOCUMENT DocBook HTML Stylesheet//EN" CDATA dsssl>
	<!ENTITY common-ss SYSTEM "common.dsl">
]>
<style-sheet>
	<style-specification use="html-stylesheet">
		<style-specification-body> ;; customize the html stylesheet
&common-ss;
(define %root-filename%
	;; Name for the root HTML document
	"index")

(define use-output-dir
	;; If an output-dir is specified, should it be used?
	#t)

(define %output-dir%
	;; The directory to which HTML files should be written
	"html")

(define %html-ext%
	;; Default extension for HTML output files
	".html")
</style-specification-body>
	</style-specification>
	<external-specification id="html-stylesheet" document="html-ss">
</style-sheet>
