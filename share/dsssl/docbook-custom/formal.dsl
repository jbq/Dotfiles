<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
	<!ENTITY print-ss SYSTEM "print.dsl" CDATA dsssl>
]>
<style-sheet>
	<style-specification use="print-stylesheet">
		<style-specification-body> ;; customize the print stylesheet
(define %section-autolabel% #t)

(define %generate-article-toc% #t)

(define (toc-depth nd)
  (if (string=? (gi nd) (normalize "book")) 7
  	(if (string=? (gi nd) (normalize "article")) 4 1)
  )
)

(define %generate-article-toc-on-titlepage% #f)
(define %generate-article-titlepage-on-separate-page% #t)
		</style-specification-body>
	</style-specification>
	<external-specification id="print-stylesheet" document="print-ss">
</style-sheet>
