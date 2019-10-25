set autoread
autocmd CursorHold,CursorHold * call Timer()
autocmd CursorMoved,CursorMovedI * call Timer()
function! Timer()
    call feedkeys("f\e")
    checktime
    if getline(1) == "finished"
        call Quit()
        quit!
    endif
endfunction
set updatetime=1000  " milliseconds
set nomodifiable

autocmd QuitPre * call Quit()
function! Quit()
    set modifiable
    norm ggOquitvim
    write
endfunction


" disable 'Press Enter or type command to continue' at startup.
set shortmess=a
set cmdheight=2
