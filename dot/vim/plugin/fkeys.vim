""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:          fkeys.vim
" Author:        Jean-Baptiste Quenot
" Purpose:       Define some useful function-keys
" CVS Id:        $Id: fkeys.vim 529 2004-02-25 13:41:30Z jbq $
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

imap <F3> <C-O>:call SaveAll()<CR>
vmap <F3> :call SaveAll()<CR>
nmap <F3> :call SaveAll()<CR>
imap <F4> <C-O>:call Make()<CR>
vmap <F4> :call Make()<CR>
nmap <F4> :call Make()<CR>

" Save all buffers (even if they are read-only)
function SaveAll()
    wa!
endf

" Save all buffers and execute 'make'
function Make()
    " Save all buffers (even if they are read-only)
    call SaveAll()

    if (! exists("uname"))
        silent let uname = system("uname")
    endif

    if file_readable("Makefile")
        set makeprg=make

        make
    endif

    if file_readable("GNUMakefile")
        if uname =~ "Linux"
            set makeprg=make
        else
            set makeprg=gmake
        endif

        make
    endif

    if file_readable("build.xml")
        set makeprg=ant
        make
    endif
endf

nmap    <F5> :bp<cr>
nmap    <F6> :bn<cr>
vmap    <F5> :bp<cr>
vmap    <F6> :bn<cr>
imap    <F5> <ESC>:bp<cr>
imap    <F6> <ESC>:bn<cr>

function SpellCheck()
      wa!
      exe("! gaspell --language-tag=fr %")
      e
endfunction

nmap <f8> :call SpellCheck()<cr>
imap <f8> <C-O>:call SpellCheck()<cr>
"nmap <f8> :w<cr>:!gaspell --language-tag=en %<cr>:e<cr><cr>
