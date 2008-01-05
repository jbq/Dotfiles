""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author:        Jean-Baptiste Quenot <jbq@anyware-tech.com>
" Purpose:       Add custom file types detection
" Date Created:  2004-08-19 09:06:35
" Revision:      $Id: filetype.vim 1073 2004-11-05 21:35:01Z jbq $
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

augroup filetypedetect
au! BufNewFile,BufRead *.xq setf xquery
au BufNewFile,BufRead muttng-*-\w\+ setf mail
au BufNewFile,BufRead *.xmap setf xml
augroup END
