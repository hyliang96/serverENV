runtime! debian.vim

" disable 'Press Enter or type command to continue' at startup.
set shortmess=a
set cmdheight=2


function! Quit()
    set modifiable
    norm ggOquitvim
    write!
    quit!
endfunction

function! Timer()
    call feedkeys("f\e")
    checktime
    if getline(1) == "finished"
        call Quit()
    endif
endfunction
set updatetime=100  " milliseconds
set nomodifiable

set autoread
autocmd CursorHold,CursorHold * call Timer()
autocmd CursorMoved,CursorMovedI * call Timer()

nnoremap <C-C> :call Quit()<CR>
vnoremap <C-C> :call Quit()<CR>

set nocompatible                         " 关闭 vi 兼容模式

