<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
	<!ENTITY print-ss PUBLIC "-//Norman Walsh//DOCUMENT DocBook Print Stylesheet//EN" CDATA dsssl>
	<!ENTITY common-ss SYSTEM "common.dsl">
]>
<style-sheet>
	<style-specification use="print-stylesheet">
		<style-specification-body> ;; customize the print stylesheet
&common-ss;
;; properly indent varlistentry terms
(element (varlistentry term)
    (make paragraph
          space-before: (if (first-sibling?)
                            %block-sep%
                            0pt)
          keep-with-next?: #t
          first-line-start-indent: 0pt
;          start-indent: 0pt
          (process-children)))

(define %show-ulinks% #t)

(define %paper-type% "A4")

(define %hyphenation% #t)

(define %cals-cell-before-column-margin% 3pt)

(define bop-footnotes #t)

; (define %default-quadding% 'justify)
(define %top-margin%
 (if (equal? %visual-acuity% "large-type")
  10.5pi
  9pi))
		</style-specification-body>
	</style-specification>
	<external-specification id="print-stylesheet" document="print-ss">
</style-sheet>
