set autoread
autocmd CursorHold,CursorHold * call Timer()
autocmd CursorMoved,CursorMovedI * call Timer()
function! Timer()
    call feedkeys("f\e")
    checktime
    if getline(1) == "finished"
        set modifiable
        norm ggOquitvim
        norm quit!
    endif
endfunction
set updatetime=100  " milliseconds
set nomodifiable
