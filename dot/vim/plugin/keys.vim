""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:          keys.vim
" Author:        Jean-Baptiste Quenot
" Purpose:       Define some useful keyboard mappings
" Last Modified: 2004-12-28 13:53:33
" backspace in Visual mode deletes selection
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" mappings in insert mode
" imap <C-A> <Home>
imap <C-A> <C-O>^
cmap <C-A> <Home>
imap <C-E> <End>

" redraw screen in insert mode
imap <C-L> <Esc><C-L>a

" simulate readline's Ctrl-K ``erase to end of line'' command
imap <C-K> <C-O>D
" Use <C-N><C-K> to do what <C-K> used to do
inoremap <C-N><C-K> <C-K>
cnoremap <C-N><C-K> <C-K>

if version >= 600
	" search and replace on all lines with confirmation
	nmap ;; :%s:\v::gc<Left><Left><Left><Left>
	" search and replace starting from current line with confirmation
	nmap :; :,$s:\v::gc<Left><Left><Left><Left>
else
	" search and replace on all lines with confirmation
	nmap ;; :%s:::gc<Left><Left><Left><Left>
	" search and replace starting from current line with confirmation
	nmap :; :,$s:::gc<Left><Left><Left><Left>
endif

imap <C-N><C-B>< &lt;
imap <C-N><C-B>> &gt;
imap <C-N><C-B>& &amp;
imap <C-N><C-B><Space> &nbsp;
imap <C-N>w «  »<Left><Left>
imap <C-N>< « 
imap <C-N>>  »
imap <C-N><Space>  

"
" The following is provided for compatibility with screen that uses CTRL-O to
" handle events
"
" Insert mode: Enter command mode
"
inoremap <C-N>o <C-O>
"
" Command mode: Go to older cursor position in jump list
"
nnoremap <C-N><C-I> <C-O>

cmap <C-G> <esc>

nnoremap < <<
nnoremap > >>
nnoremap = ==
" imap <C-N>= <C-O>=

" highlight current line
" map j j:exe '/\%' . line(".") . 'l.*'<cr>
" map <down> j
" map k k:exe '/\%' . line(".") . 'l.*'<cr>
" map <up> k

" Digraphs
inoremap ~n <C-K>?n

" may be used if locale is not properly set
"imap ^a â
"imap ^e ê
"imap ^i î
"imap ^o ô
"imap ^u û
"imap ¨a ä
"imap ¨e ë
"imap ¨i ï
"imap ¨o ö
"imap ¨u ü

" Disable recording
nmap q <esc>
vmap q <esc>

" backspace in Visual mode deletes selection
vnoremap <BS> d

" Map <C-H> to toggle search highlighting
" map <C-H> :set hlsearch!<cr>:set hlsearch?<cr>

"if version >= 600
"	noremap <down> <down>zx
"	noremap <up> <up>zx
"endif

inoremap <C-B> <C-O>b
inoremap <C-F> <C-O>e
