if exists('g:loaded_debate')
  finish
endif
let g:loaded_debate = 1

" List Helpers
" Swap xs[i] and xs[j] in place.
function! s:swap(xs, i, j)
  let l:max = len(a:xs)
  if !(0 <= a:i && a:i < l:max) || !(0 <= a:j && a:j < l:max) || a:i == a:j
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
    if a:arg != -1
      execute a:arg + 1 . 'argument' . l:bang
    endif
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

  let l:args = s:swap(argv(), l:from, l:to)
  call s:update_args(l:args, l:to, a:bang)
endfunction

" Remove duplicates from the argument list.
function! s:arg_uniq(bang)
  let l:arg = argv()[argidx()]
  let l:args = s:uniq_ordered(argv())
  call s:update_args(l:args, index(l:args, l:arg), a:bang)
endfunction

command! -bang -bar -range -addr=arguments DebateSwap call s:arg_swap(<line1>, <line2>, <bang>0)
command! -bang -bar DebateSwapPrev .-1DebateSwap<bang>
command! -bang -bar DebateSwapNext .+1DebateSwap<bang>
command! -bang -bar DebateUniq call s:arg_uniq(<bang>0)

nnoremap <leader>an :DebateSwapNext<CR>
nnoremap <leader>aN :DebateSwapPrev<CR>
nnoremap <leader>au :DebateUniq<CR>

" vim:set sw=2:
