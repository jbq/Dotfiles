""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" File:          reformat.vim
" Author:        Jean-Baptiste Quenot <jb.quenot@caraldi.com>
" Purpose:       Reformat paragraphs according to file type
" Date Created:  2002-06-28 13:24:42
" Revision:      $Id: reformat.vim 1073 2004-11-05 21:35:01Z jbq $
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Copyright (c) 2004, Jean-Baptiste Quenot <jb.quenot@caraldi.com>
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"
" * Redistributions of source code must retain the above copyright notice, this
"   list of conditions and the following disclaimer.
" * Redistributions in binary form must reproduce the above copyright notice,
"   this list of conditions and the following disclaimer in the documentation
"   and/or other materials provided with the distribution.
" * The name of the contributors may not be used to endorse or promote products
"   derived from this software without specific prior written permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
" FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
" OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
" OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" reformat text
imap <C-J> <C-O>:call ReformatParagraph()<cr>
nmap <C-J> :call ReformatParagraph()<cr>
vmap <C-J> gq<cr>
nmap Q <C-J>
vmap Q <C-J>

function ReformatParagraph ()
	if &filetype == 'docbk'
		exe 'normal! ?<\(sim\)*para[^>]*>' . "\n" . 'v/<\/\(sim\)*para>' . "\n" . 'gq'
	elseif &filetype == 'php' || &filetype == 'html' || &filetype == 'java'
		exe 'normal! ?<p[^>]*>' . "\n" . 'v/<\/p>' . "\n" . 'gq'
	elseif &filetype == 'python'
		exe 'normal! ?"""' . "\n" . 'v/"""' . "\n" . 'gq'
	elseif &filetype == 'c'
		exe 'normal! ?/*' . "\n" . 'v/*\/' . "\n" . 'gq'
	else
		exe 'normal! gqap' . "\n"
		return
	endif

	if (histdel("search", -1))
		let @/ = histget("search", -1)
	else
		echo 'Could not delete last search'
	endif
endfunction
