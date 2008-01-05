""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:          mail.vim
" Author:        Jean-Baptiste Quenot
" Purpose:       Set some options useful for editing mail
" CVS Id:        $Id$
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" reformat email message until signature
nnoremap <F8> :call ReformatMail()<cr>

" mail colors
hi mailQuoted1		guifg=Magenta
hi mailQuoted2		guifg=Cyan
hi mailQuoted3		guifg=Yellow
hi mailQuoted4		guifg=Green
hi mailSignature	guifg=Red

hi mailQuoted1		ctermfg=Magenta
hi mailQuoted2		ctermfg=Cyan
hi mailQuoted3		ctermfg=Yellow
hi mailQuoted4		ctermfg=Green
hi mailSignature	ctermfg=Red

set expandtab
setlocal tw=66
