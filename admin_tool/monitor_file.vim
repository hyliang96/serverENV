runtime! debian.vim

" if has("syntax")
"  syntax off
" endif

" disable 'Press Enter or type command to continue' at startup.
" set shortmess=a
" set cmdheight=2

" command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'


function! Quit()
    " set modifiable
    " norm ggOquitvim
    execute ':silent ! touch '.expand('%:p:h').'/quitvim'
    " Silent touch  :echo
    update!
    quit!
endfunction

function! Timer()
    call feedkeys("f\e")
    checktime
    if getline(1) == "finished"
        call Quit()
    endif
endfunction
set updatetime=500  " milliseconds
set nomodifiable


set autoread
autocmd BufEnter,BufRead * call Timer()
autocmd CursorHold,CursorHoldI * call Timer()
autocmd CursorMoved,CursorMovedI * call Timer()

nnoremap <C-C> :call Quit()<CR>
vnoremap <C-C> :call Quit()<CR>
inoremap <C-C> <C-O>:call Quit()<CR>


set nocompatible                         " 关闭 vi 兼容模式
let g:loaded_matchparen=1
" set noshowmatch

" set nolazyredraw
" set ttymouse=xterm2
" nnoremap <esc>^[ <esc>^[
" set mouse=a
" map <ScrollWheelUp> <C-Y>
" map <ScrollWheelDown> <C-E>

" set bg=dark
" hi! EndOfBuffer ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
" highlight EndOfBuffer ctermfg=black ctermbg=black
" hi NonText guifg=bg
"
"






