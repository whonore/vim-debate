if exists('g:loaded_debate')
  finish
endif
let g:loaded_debate = 1

function! s:list_swap(xs, i, j)
  let l:max = len(a:xs)
  if !(0 <= a:i && a:i < l:max) || !(0 <= a:j && a:j < l:max) || a:i == a:j
    return []
  end

  let [a:xs[a:i], a:xs[a:j]] = [a:xs[a:j], a:xs[a:i]]

  return a:xs
endfunction

function! s:swap_arg(from, to, bang) abort
  let l:from = max([a:from - 1, 0])
  let l:to = max([a:to - 1, 0])
  let l:bang = a:bang ? '!' : ''

  " nDebateSwap = .,nDebateSwap
  if l:from == l:to
    let l:from = argidx()
  endif

  let l:args = s:list_swap(argv(), l:from, l:to)

  if l:args != []
    execute 'args' . l:bang . ' ' . join(l:args, ' ')
    execute l:to + 1 . 'argument' . l:bang
  endif
endfunction

command! -bang -bar -range -addr=arguments DebateSwap call s:swap_arg(<line1>, <line2>, <bang>0)
command! -bang -bar DebateSwapPrev .-1DebateSwap<bang>
command! -bang -bar DebateSwapNext .+1DebateSwap<bang>

nnoremap <leader>an :DebateSwapNext<CR>
nnoremap <leader>aN :DebateSwapPrev<CR>

" vim:set sw=2:
