"
" " disable 'Press Enter or type command to continue' at startup.
" set shortmess=a
" set cmdheight=2
"
"
" function! Quit()
"     set modifiable
"     norm ggOquitvim
"     write!
"     quit!
" endfunction
"
" function! Timer()
"     call feedkeys("f\e")
"     checktime
"     if getline(1) == "finished"
"         call Quit()
"     endif
" endfunction
" set updatetime=1000  " milliseconds
" set nomodifiable
"
" set autoread
" autocmd CursorHold,CursorHold * call Timer()
" autocmd CursorMoved,CursorMovedI * call Timer()
"
"
" " unmap <C-c>
" " nmap <C-c> <silent> <C-c>
" " nnoremap q :call Quit()<CR>
" " nmap <C-C> :call Quit()<Cr>
"
"

nnoremap tt :echo 'hello' <CR>

set nocompatible                         " 关闭 vi 兼容模式

