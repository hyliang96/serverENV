set autoread
autocmd CursorHold,CursorHold * call Timer()
autocmd CursorMoved,CursorMovedI * call Timer()
function! Timer()
    call feedkeys("f\e")
    checktime
endfunction
set updatetime=100  " milliseconds
set nomodifiable
