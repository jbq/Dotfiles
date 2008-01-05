""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:          copypaste.vim
" Author:        Jean-Baptiste Quenot
" Purpose:       Define keyboard mappings for natural cut, copy, paste
" Date Created:  2002-03-25 18:53:18
" Last Modified: 2002-03-25 18:55:14
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" I used register "a" instead of "+" to avoid interaction with the "*"
" register used by the X Window manager and gvim

" CTRL-X is Cut
vnoremap <C-X> "ax

" CTRL-C is Copy
if version >= 600
	" On version < 600, Ctrl-C means interrupt task
	vnoremap <C-C> "ay
"else
"	vnoremap y "ay
endif

" nnoremap p "ap
" nnoremap P "aP
" vnoremap d "ad

" CTRL-V is Paste
nmap <C-V> "aP
imap <C-V> <ESC>"apa
cmap <C-V> <C-R>a
vmap <C-V> "ap

" Use ,<Ctrl-V> to do what CTRL-V used to do
nnoremap <C-N><C-V> <C-V>
nnoremap ,<C-V> <C-V>
cnoremap <C-N><C-V> <C-V>
inoremap <C-N><C-V> <C-V>
