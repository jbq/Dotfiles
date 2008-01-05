(define %visual-acuity%
;; "presbyopic")
;; "large-type")
"normal")

(define %body-font-family% "Palatino")

;; Allow raw TeX insertion in imagedata
(define preferred-mediaobject-notations
  (list "TEX" "EPS" "PS" "JPG" "JPEG" "PNG" "linespecific"))

(define %verbatim-size-factor% #f)

;; center literallayout[@role='center']
(element literallayout
  (if (equal? (attribute-string "class") (normalize "monospaced"))
      ($verbatim-display$
       %indent-literallayout-lines%
       %number-literallayout-lines%)
      (if (equal? (attribute-string "role") (normalize "center"))
	  ($centered-linespecific-display$
       %indent-literallayout-lines%
       %number-literallayout-lines%)
	  ($linespecific-display$
       %indent-literallayout-lines%
       %number-literallayout-lines%)
)))

;; center literallayout[@role='center']
(define ($centered-linespecific-display$ indent line-numbers?)
  (let ((vspace (if (INBLOCK?)
		   0pt
		   (if (INLIST?) 
		       %para-sep% 
		       %block-sep%))))
    (make paragraph
		quadding: 'center
      use: linespecific-style
      space-before: (if (and (string=? (gi (parent)) (normalize "entry"))
 			     (absolute-first-sibling?))
			0pt
			vspace)
      space-after:  (if (and (string=? (gi (parent)) (normalize "entry"))
 			     (absolute-last-sibling?))
			0pt
			vspace)
      start-indent: (if (INBLOCK?)
			(inherited-start-indent)
			(+ %block-start-indent% (inherited-start-indent)))
      (if (or indent line-numbers?)
	  ($linespecific-line-by-line$ indent line-numbers?)
	  (process-children)))))

(define (article-titlepage-recto-elements)
 (list
  (normalize "pubdate")
  (normalize "title")
  (normalize "mediaobject")
  (normalize "releaseinfo")
  (normalize "subtitle")
  (normalize "author")
  (normalize "authorgroup")
  (normalize "affiliation")
 )
)

(define (article-titlepage-verso-elements)
 (list
  (normalize "legalnotice")
  (normalize "abstract")
 )
)

(define (book-titlepage-recto-elements)
 (list
  (normalize "pubdate")
  (normalize "title")
  (normalize "mediaobject")
  (normalize "releaseinfo")
  (normalize "subtitle")
  (normalize "author")
  (normalize "authorgroup")
  (normalize "affiliation")
 )
)

(define (book-titlepage-verso-elements)
 (list
  (normalize "legalnotice")
  (normalize "copyright")
  (normalize "abstract")
 )
)

(define %generate-article-toc%
	;; Should a Table of Contents be produced for Articles?
	#f)

(define %generate-article-titlepage-on-separate-page%
	;; Should the article title page be on a separate page?
	#f)

(define %section-autolabel% 
	;; If true, unlabeled sections will be enumerated.
	#f)

(define %admon-graphics%
	;; Use graphics in admonitions?
	#f)

(define %admon-graphics-path%
	;; Path to admonition graphics
	"$(HOME)/share/xml/docbook/admonition/")

<!-- I want things marked up with 'sgmltag' eg., 

	<para>You can use <sgmltag>para</sgmltag> to indicate
	paragraphs.</para>

	to automatically have the opening and closing braces inserted,
	and it should be in a mono-spaced font. -->

(element sgmltag
	(if (equal? (attribute-string "class") (normalize "element"))
	($mono-seq$
		(make sequence
			(literal "<")
			(process-children)
			(literal ">")))
	($mono-seq$ (process-children)))
)

(element command ($mono-seq$))
(element application ($bold-seq$))

<!-- Warnings and cautions are put in boxed tables to make them stand
	out. The same effect can be better achieved using CSS or similar,
	so have them treated the same as <important>, <note>, and <tip>
-->
(element warning ($admonition$))
(element (warning title) (empty-sosofo))
(element (warning para) ($admonpara$))
(element (warning simpara) ($admonpara$))
(element caution ($admonition$))
(element (caution title) (empty-sosofo))
(element (caution para) ($admonpara$))
(element (caution simpara) ($admonpara$))

(define (local-en-label-title-sep)
	(list
		(list (normalize "warning") ": ")
	(list (normalize "caution") ": ")))

(define (local-fr-label-title-sep)
	(list
		(list (normalize "warning") ": ")
	(list (normalize "caution") ": ")))

;(element abstract ($italic-seq$))

(element database ($mono-seq$))
(element type ($mono-seq$))
(element symbol ($mono-seq$))

; center formal objects
(mode formal-object-title-mode
  (element title
    (let* ((object (parent (current-node)))
	   (nsep   (gentext-label-title-sep (gi object))))
      (make paragraph
	font-weight: 'bold
	space-before: (if (object-title-after (parent (current-node)))
			  %para-sep%
			  0pt)
	space-after: (if (object-title-after (parent (current-node)))
			 0pt
			 %para-sep%)
	quadding: 'center
	start-indent: (+ %block-start-indent% (inherited-start-indent))
	keep-with-next?: (not (object-title-after (parent (current-node))))
	(if (member (gi object) (named-formal-objects))
	    (make sequence
	      (literal (gentext-element-name object))
	      (if (string=? (element-label object) "")
		  (literal nsep)
		  (literal " " (element-label object) nsep)))
	    (empty-sosofo))
	(process-children))))
)

(define ($object-titles-after$) (list (normalize "figure") (normalize "table") (normalize "equation")))
