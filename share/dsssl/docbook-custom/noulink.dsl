<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
	<!ENTITY print-ss SYSTEM "print.dsl" CDATA dsssl>
]>
<style-sheet>
	<style-specification use="print-stylesheet">
		<style-specification-body> ;; customize the print stylesheet
(define %show-ulinks% #f)
		</style-specification-body>
	</style-specification>
	<external-specification id="print-stylesheet" document="print-ss">
</style-sheet>
