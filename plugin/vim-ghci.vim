vim9script noclear

import autoload '../autoload/ghci.vim' as ghci
import autoload '../autoload/commands.vim' as commands

if !exists("g:vim_ghci_socket")
    g:vim_ghci_socket = '/tmp/vim-ghci.sock'
endif

if !exists("g:vim_ghci_autoload")
    g:vim_ghci_autoload = 0
endif

command! -nargs=? -range Ghci commands.Ghci(<q-args>, <range>)
command! -bang -nargs=? -range GhciInfo commands.Info(<q-args>, <range>, "<bang>")
command! -bang -nargs=? -range GhciInstances commands.Instances(<q-args>, <range>)
command! -nargs=0 -range GhciTypeAt commands.TypeAt(<range>)
command! -nargs=0 GhciAddModule {
  commands.Add()
  var moduleName = commands.Module()
  echom 'Module ' .. moduleName .. ' added.'
}

nnoremap <silent> <Plug>GhciInfo :GhciInfo<CR>
xnoremap <silent> <Plug>GhciInfo :GhciInfo<CR>
nnoremap <silent> <Plug>GhciInfo! :GhciInfo!<CR>
xnoremap <silent> <Plug>GhciInfo! :GhciInfo!<CR>
nnoremap <silent> <Plug>GhciInstances :GhciInstances<CR>
xnoremap <silent> <Plug>GhciInstances :GhciInstances<CR>
nnoremap <silent> <Plug>GhciTypeAt :GhciTypeAt<CR>
xnoremap <silent> <Plug>GhciTypeAt :GhciTypeAt<CR>
nnoremap <silent> <Plug>GhciAddModule :GhciAddModule<CR>

export var HaskellComplete = commands.HaskellComplete

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
