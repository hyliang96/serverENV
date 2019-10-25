set autoread
autocmd CursorHold,CursorHold * call Timer()
autocmd CursorMoved,CursorMovedI * call Timer()
function! Timer()
    call feedkeys("f\e")
    checktime
    if getline(1) == "finished"
        set modifiable
        norm ggOquitvim
        write
        quit!
    endif
endfunction
set updatetime=1000  " milliseconds
set nomodifiable


" disable 'Press Enter or type command to continue' at startup.
set shortmess=a
set cmdheight=2
