""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:          folding.vim
" Author:        Jean-Baptiste Quenot
" Purpose:       Define some options for folding
" Last Modified: 2003-09-08 22:24:25
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Give me red folds
"highlight Folded guifg=red
"highlight Folded guibg=bg
"highlight Folded ctermfg=1

" vim: ctermbg=bg does not yet work in xterm
" highlight Folded ctermbg=bg
" highlight Normal ctermbg=0
"highlight Folded ctermbg=0

" Disable folding fillchars
if version >= 600
	set fillchars=vert:\|
endif
