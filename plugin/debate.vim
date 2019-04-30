if exists('g:loaded_debate')
  finish
endif
let g:loaded_debate = 1

" List Helpers
" Swap xs[i] and xs[j] in place.
function! s:swap(xs, i, j)
  let l:max = len(a:xs)
  if !(0 <= a:i && a:i < l:max) || !(0 <= a:j && a:j < l:max)
    return []
  end

  let [a:xs[a:i], a:xs[a:j]] = [a:xs[a:j], a:xs[a:i]]

  return a:xs
endfunction

" Return a function that compares two elements based on their original position
" in the list.
function! s:idx_compare(xs)
  return {x, y ->
    \ index(a:xs, x) == index(a:xs, y) ? 0 : index(a:xs, x) > index(a:xs, y) ? 1 : -1}
endfunction

" Filter out duplicate items but leave the list in the same order.
function! s:uniq_ordered(xs)
  return sort(uniq(sort(copy(a:xs))), s:idx_compare(a:xs))
endfunction

" Argument List Functions
" Set the argument list and current argument.
function! s:update_args(args, arg, bang) abort
  let l:bang = a:bang ? '!' : ''

  if a:args != []
    execute 'args' . l:bang . ' ' . join(a:args, ' ')
  endif
  if a:arg != -1
    execute a:arg + 1 . 'argument' . l:bang
  endif
endfunction

" Swap from and to in the argument list.
function! s:arg_swap(from, to, bang)
  let l:from = max([a:from - 1, 0])
  let l:to = max([a:to - 1, 0])

  " nDebateSwap = .,nDebateSwap
  if l:from == l:to
    let l:from = argidx()
  endif

  if l:from != l:to
    let l:args = s:swap(argv(), l:from, l:to)
    call s:update_args(l:args, l:to, a:bang)
  endif
endfunction

" Remove duplicates from the argument list.
function! s:arg_uniq(bang)
  let l:arg = argv()[argidx()]
  let l:args = s:uniq_ordered(argv())
  call s:update_args(l:args, index(l:args, l:arg), a:bang)
endfunction

" Reverse the argument list.
function! s:arg_reverse(bang)
  let l:idx = argc() - argidx() - 1
  let l:args = reverse(argv())
  call s:update_args(l:args, l:idx, a:bang)
endfunction

" Remove the current file from the argument list and edit the next in the list.
function! s:arg_delete(bang)
  let l:idx = argidx()
  .argdelete
  let l:nargs = argc()

  " Don't change files if the argument list is empty
  if l:nargs == 0
    let l:idx = -1
  else
    " Move forward up to the last argument
    let l:idx = min([l:idx, l:nargs - 1])
  endif
  call s:update_args([], l:idx, a:bang)
endfunction

" Argument list manipulations
command! -bang -bar -range -addr=arguments DebateSwap call s:arg_swap(<line1>, <line2>, <bang>0)
command! -bang -bar DebateSwapPrev .-1DebateSwap<bang>
command! -bang -bar DebateSwapNext .+1DebateSwap<bang>
command! -bang -bar DebateUniq call s:arg_uniq(<bang>0)
command! -bang -bar DebateReverse call s:arg_reverse(<bang>0)
command! -bang -bar DebateDelete call s:arg_delete(<bang>0)

nnoremap <silent> <leader>an :DebateSwapNext<CR>
nnoremap <silent> <leader>aN :DebateSwapPrev<CR>
nnoremap <silent> <leader>au :DebateUniq<CR>
nnoremap <silent> <leader>ar :DebateReverse<CR>
nnoremap <silent> <leader>ad :DebateDelete<CR>

let s:domap = 1
let s:arrows = ['<C-Left>', '<C-Right>', '<C-Up>', '<C-Down>', 'A', 'B', 'C', 'D']
for s:arrow in s:arrows
  if s:arrow =~ '^[ABCD]$'
    let s:arrow = '<ESC>[1;5' . s:arrow
  endif
  if maparg(s:arrow, 'n') != ''
    let s:domap = 0
    break
  endif
endfor
if s:domap
  " Make ctrl-arrows switch between args
  nnoremap <C-Left> :previous<CR>
  nnoremap <C-Right> :next<CR>
  nnoremap <C-Up> :first<CR>
  nnoremap <C-Down> :last<CR>

  " Make ctrl-arrows work in screen
  nnoremap <ESC>[1;5D :previous<CR>
  nnoremap <ESC>[1;5C :next<CR>
  nnoremap <ESC>[1;5A :first<CR>
  nnoremap <ESC>[1;5B :last<CR>
endif

" Make gf and friends put the file on the arglist
nnoremap gf gf:argedit %<CR>
vnoremap gf gf:argedit %<CR>
nnoremap gF gF:argedit %<CR>
vnoremap gF gF:argedit %<CR>

" vim:set sw=2:
