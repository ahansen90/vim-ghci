vim9script noclear

import autoload '../autoload/ghci.vim' as ghci
import autoload '../autoload/commands.vim' as commands

if !exists("g:vim_ghci_socket")
    g:vim_ghci_socket = '/tmp/vim-ghci.sock'
endif

if !exists("g:vim_ghci_autoload")
    g:vim_ghci_autoload = 0
endif

# command! -nargs=1 -bang GhciStart ghci.GhciStart(<q-args>)

command! -nargs=1 Ghci commands.Ghci(<q-args>)
command! -bang -nargs=? -range GhciInfo commands.Info(<q-args>, <range>, "<bang>")
command! -nargs=0 -range GhciTypeAt commands.TypeAt(<range>)
command! -nargs=0 GhciAddModule {
  commands.Add()
  commands.Module()
}

nnoremap <silent> <Plug>GhciInfo :GhciInfo<CR>
xnoremap <silent> <Plug>GhciInfo :GhciInfo<CR>
nnoremap <silent> <Plug>GhciTypeAt :GhciTypeAt<CR>
xnoremap <silent> <Plug>GhciTypeAt :GhciTypeAt<CR>

def Autoload()
  if g:vim_ghci_autoload
    GhciAddModule
  endif
enddef
augroup VimGhci
  autocmd!
  autocmd BufEnter *.hs call Autoload()
augroup END

defcompile
