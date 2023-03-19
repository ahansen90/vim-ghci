vim9script noclear

import autoload '../autoload/ghci.vim' as ghci
import autoload '../autoload/commands.vim' as commands

command! -nargs=1 -bang GhciConnect ghci.GhciConnect(<f-args>)
command! -nargs=1 -bang GhciStart ghci.GhciStart(<q-args>)

command! -nargs=1 Ghci commands.Ghci(<q-args>)
command! -bang -nargs=? -range GhciInfo commands.Info(<q-args>, <range>, <bang>)
command! -nargs=0 -range GhciTypeAt commands.TypeAt(<range>)
command! -nargs=0 GhciAddModule {
  commands.Add()
  commands.Module()
}

nnoremap <silent> <Plug>GhciInfo :GhciInfo<CR>
xnoremap <silent> <Plug>GhciInfo :GhciInfo<CR>
nnoremap <silent> <Plug>GhciTypeAt :GhciTypeAt<CR>
xnoremap <silent> <Plug>GhciTypeAt :GhciTypeAt<CR>

defcompile
