""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:          autocommands.vim
" Author:        Jean-Baptiste Quenot
" Purpose:       Define autocommands based on file type or file name
" Date Created:  2001-10-01 00:00:00
" CVS Id:        $Id: autocommands.vim 1079 2004-11-05 22:31:16Z jbq $
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Used for listchars below
scriptencoding utf-8

" Do not let PHP indent plugin reset my formatoptions setting
let g:PHP_autoformatcomment = 0

" Load plugin detection scripts and smart indentation scripts
filetype plugin indent on

au FileType xml,docbk,ant,xslt,xsd,html,tex,jsp,xquery call SetMarkupEditing()
au FileType cvs,svn,mail,sendpr call SetTextEditing()
au FileType mail setlocal spell

" Use latin1 for:
" - Java properties prohibits Unicode
" - send-pr because Unicode PR shows a latin 1
au FileType cvs,jproperties,sendpr set fileencoding=latin1

au FileType apache,puppet,sh,vhdl,vim,dsl,java,javascript,c,perl,css,php,sql,ruby,python,erlang,eruby,haxe,thrift,logstash,groovy call SetProgramEditing()
au FileType haxe setlocal smartindent
let g:jsx_ext_required = 0

" Properly format XML comments
au FileType xml,docbk,ant,xslt,xsd setlocal comments=sr:<!--+,mb:\|,ex:+-->
au FileType xquery setlocal comments=sr:(\:,mb:\:,ex:\:)
" Set foldmethod syntax for XML, even if it slows down the editor
au FileType xml,docbk,ant,xslt,xsd setlocal foldmethod=syntax
" Load docbook macros for Docbook, Website and Slides
au FileType xml runtime dbhelper.vim
au BufRead *.txt call SetTextEditing()
au BufRead *.json* call SetTextEditing()
au BufRead *.json5 setlocal ft=javascript
au BufRead *.jad setlocal ft=java
au BufRead *.hx setlocal ft=haxe

function NormalizeQuotes()
    execute('%s:>>:> >:g')
    execute('%s:\v\>\s*([^> ]):> \1:g')
    "execute('%s:^>\s*>\s*>\s*>\s*$::g')
    "execute('%s:^>\s*>\s*>\s*$::g')
    "execute('%s:^>\s*>\s*$::g')
    "execute('%s:^>\s*$::g')
endfunction

function SuperReformatMail()
    call MySuperReformatMail(&tw)
endfunction

function MySuperReformatMail(cols)
    silent! call NormalizeQuotes()
    "execute('%g:^$:d')
    call MyReformatMail(a:cols)
    "silent! call NormalizeQuotes()
endfunction

function ReformatMail()
    call MyReformatMail(&tw)
endfunction

function Escaped_format_cmd(cols)
    return escape(Format_cmd(a:cols), "|")
endfunction

function Format_cmd(cols)
    return "! iconv -f utf-8 -t latin1 | par j w" . a:cols . " | iconv -f latin1 -t utf-8"
endfunction

" TODO How to specify default values for arguments?
function MyReformatMail(cols)
    let line = search ('^-- ')
    " par does not handle Unicode, so we first convert to latin1, and back to
    " Unicode
    exe '1,' . (line - 1) . Format_cmd(a:cols)
endfunction

function SetEditing()
    "call SetFileFormat()
    setlocal expandtab
    setlocal autoindent
    if ((! exists("&tw")) || (&tw == 0))
        setlocal tw=80
    endif
    setlocal list
    if version >= 600
        " foldmethod 'syntax' ne marche pas pour HTML, Java, JavaScript
        setlocal foldmethod=indent | setlocal foldenable | setlocal foldlevel=1
    endif
    call ContextDependentEditing()

    "
    " justify paragraphs with proper width
    "
    exe 'imap <C-N><C-J> <C-O>vip' . Escaped_format_cmd(&tw) . '<CR><C-O>}<C-O><CR>'
    exe 'nmap <C-N><C-J> vip' . Escaped_format_cmd(&tw) . '<CR>}<CR>'
    exe 'vmap <C-N><C-J>' . Escaped_format_cmd(&tw) . '<CR>}<CR>'
endfunction

function SetProgramEditing()
    call SetEditing()
    setlocal formatoptions=croql
endfunction

function SetMarkupEditing()
    call SetEditing()
    setlocal tw=120
    setlocal formatoptions=tcroql
endfunction

function SetTextEditing()
    call SetEditing()
    setlocal formatoptions=t
endfunction

function SetFileFormat()
    if (&readonly == 0 && &ff != 'unix' && &ft != 'dosbatch')
        setlocal ff=unix
    endif
endfunction

autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal g`\"" |
\ endif

" Show tabs and trailing spaces with special characters
" Does not work on Fink Darwin (lack of Unicode support)
if (system("uname") =~ "Darwin")
    set listchars=tab:>-,trail:-
else
    set listchars=tab:»·,trail:·
endif

" au FileType html,php,jsp so ~/.vim/html.vim
" au BufEnter freebsd.mc set ft=m4

function UpdateDateTimeText()
    " Set mark 's'
    normal ms

    " Move cursor to top of window
    normal H

    " Set mark 't'
    normal mt

    " Move cursor to top of file
    normal gg

    " Search pattern
    let lastmodpat = "^\\(.*Date:\\s*\\)$"
    let lastmodline = search(lastmodpat)

    if lastmodline > 0
        let strftime = strftime("%Y-%m-%d")
        call setline(lastmodline, substitute(getline(lastmodline), lastmodpat, "\\1" . strftime, ""))
    endif

    " Move cursor to mark 't'
    normal `t

    " Scroll window so that cursor is at the top
    normal zt

    " Move cursor to mark 's'
    normal `s
endfunction
function UpdateLastModified()
    " Set mark 's'
    normal ms

    " Move cursor to top of window
    normal H

    " Set mark 't'
    normal mt

    " Move cursor to top of file
    normal gg

    " Search pattern
    let lastmodpat = "^\\(.*Last Modified:\\s\\+\\).*$"
    let lastmodline = search(lastmodpat)

    if lastmodline > 0
        let strftime = strftime("%Y-%m-%d %H:%M:%S")
        call setline(lastmodline, substitute(getline(lastmodline), lastmodpat, "\\1" . strftime, ""))
    endif

    " Move cursor to mark 't'
    normal `t

    " Scroll window so that cursor is at the top
    normal zt

    " Move cursor to mark 's'
    normal `s
endfunction

function UpdateDocbookPubdate()
    " Set mark 's'
    normal ms

    " Move cursor to top of window
    normal H

    " Set mark 't'
    normal mt

    " Move cursor to top of file
    normal gg

    " Search pattern
    let articleline = search("<\\([a-zA-Z:]\\+\\) .*\\<lang=")

    if articleline > 0
        let lang = substitute(getline(articleline), "^.* lang=.\\([a-z_\\.]*\\)..*", "\\1", "")
    else
        let lang = ""
    endif

    "if (! exists("uname"))
    "    silent let uname = system("uname")
    "endif

    if lang == "fr"
            if isdirectory("/usr/share/locale/fr_FR.UTF-8") || system("grep fr_FR.UTF-8 /var/lib/locales/supported.d/local") == 0
                let locale = "fr_FR.UTF-8"
            else
                let locale = "fr_FR"
            endif
    else
            if isdirectory("/usr/share/locale/en_US.UTF-8") || system("grep en_US.UTF-8 /var/lib/locales/supported.d/local") == 0
                let locale = "en_US.UTF-8"
            else
                let locale = "en_US"
            endif
    endif

    exe("language time " . locale)

    " Cut pattern in parts so that no substitution is made here!
    let pubdatepattern = "<pubda" . "te>.*</pubda" . "te>"
    if lang == "fr" || lang == "es"
        let format = "%A %e %B %Y"
    else
        let format = "%A %B %e, %Y"
    endif

    let subst = "<pubdate>" . strftime(format) . "</pubdate>"
    let pubdateline = search(pubdatepattern)

    if pubdateline > 0
        call setline(pubdateline, substitute(getline(pubdateline), pubdatepattern, subst, ""))
    endif

    " Move cursor to mark 't'
    normal `t

    " Scroll window so that cursor is at the top
    normal zt

    " Move cursor to mark 's'
    normal `s
endfunction

function UpdateDateTime()
    " Set mark 's'
    normal ms

    " Move cursor to top of window
    normal H

    " Set mark 't'
    normal mt

    " Move cursor to top of file
    normal gg

    " Search pattern
    while search('<date></date>', 'W') > 0
        " Advance 6 columns
        normal 6l
        normal h"=strftime("%d.%m.%Y")p
    endwhile

    normal gg

    " Search pattern
    while search('<time></time>', 'W') > 0
        " Advance 6 columns
        normal 6l
        normal h"=strftime("%H:%M:%S")p
    endwhile

    " Move cursor to mark 't'
    normal `t

    " Scroll window so that cursor is at the top
    normal zt

    " Move cursor to mark 's'
    normal `s
endfunction

function UpdateFileName()
    " Set mark 's'
    normal ms

    " Move cursor to top of window
    normal H

    " Set mark 't'
    normal mt

    " Move cursor to top of file
    normal gg

    " Search pattern
    normal /File:\s\+/e+1
    if (histdel("search", -1))
        let @/ = histget("search", -1)
    else
        echo 'Could not delete last search'
    endif

    " If current line matches pattern and contains '///'...
    if getline(".") =~ 'File:\s\+///'
        " Delete pattern and paste the '%' register containing file name
        normal D"%p
    endif

    " Move cursor to mark 't'
    normal `t

    " Scroll window so that cursor is at the top
    normal zt

    " Move cursor to mark 's'
    normal `s
endfunction

function UpdateDateCreated()
    " Set mark 's'
    normal ms

    " Move cursor to top of window
    normal H

    " Set mark 't'
    normal mt

    " Move cursor to top of file
    normal gg

    " Search pattern
    let pattern = '^\(.*Date [Cc]reated:\s\+\)///'
    let lineNumber = search(pattern)

    if lineNumber > 0
        call setline(lineNumber, substitute(getline(lineNumber), pattern, '\1' . strftime("%Y-%m-%d %H:%M:%S") . '\2', ''))
    endif

    " Move cursor to mark 't'
    normal `t

    " Scroll window so that cursor is at the top
    normal zt

    " Move cursor to mark 's'
    normal `s
endfunction

"au BufWritePre * silent! call UpdateDateCreated()
"au BufWritePre * silent! call UpdateLastModified()
"au BufWritePre *.txt silent! call UpdateDateTimeText()
" Call first UpdateDocbookPubdate because it sets the language
"au BufWritePre *.xml,*.xmap silent! call UpdateDocbookPubdate()
"au BufWritePre *.xml silent! call UpdateDateTime()

function ContextDependentEditing()
    if match(expand("%:p"), "repos/wicket") != -1
        setlocal noet
    endif
    "if match(expand("%:p"), "/home/jbq/var/files/nomao") != -1 || match(expand("%:p"), "/home/jbq/nomao") != -1
    "endif
endfunction

au BufRead *.ahtml set ft=html
au BufRead *.xsp set ft=xml
