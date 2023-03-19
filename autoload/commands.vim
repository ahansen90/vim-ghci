vim9script

import './ghci.vim' as ghci

export def Ghci(cmd: string)
  ghci.SendCommand(cmd)
  var lines = ghci.ReadLines()
  var popup_win = popup_create(lines, {
    title: 'Result',
    border: [],
    minwidth: 50,
    moved: "any"
  })
  var popup_buf = winbufnr(popup_win)
  appendbufline(popup_buf, 0, '>>> ' .. cmd)
  setbufvar(popup_buf, '&syntax', 'haskell')
enddef

export def Info(expr: string, range: number, bang = '')
  var query: string

  if range == 0 && expr == ''
    query = expand("<cword>")
  elseif range == 0
    query = expr
  else
    normal! gv
    var i = @i
    normal! "iy
    query = @i
    @i = i
  endif

  ghci.SendCommand(':info' .. bang .. ' ' .. query)
  CursorPopup('Info')
enddef

export def TypeAt(range: number)
  if range == 0
    var pos = getpos('.')
    normal! viw
    setpos('.', pos)
  endif

  var cmd =
    ':type-at '
      .. expand('%:p')
      .. ' '
      .. line("'<")
      .. ' '
      .. col("'<")
      .. ' '
      .. line("'>")
      .. ' '
      .. (col("'>") + 1)

  ghci.SendCommand(cmd)
  CursorPopup('Type')
enddef

export def HaskellComplete(findstart: number, base: string): any
  def FindStart(): number
    var line = getline('.')
    var start = col('.') - 1
    while start > 0 && (line[start - 1] =~ '\a' || line[start - 1] == '.')
      start -= 1
    endwhile
    return start
  enddef

  def Complete()
    var pattern: string
    if getline('.') =~ '^import'
      pattern = 'import ' .. base
    else
      pattern = base
    endif
    ghci.SendCommand(':complete repl "' .. pattern .. '"')
  enddef

  if findstart == 1
    return FindStart()
  else
    Complete()

    # Ignore first response
    ghci.Read()

    var numCompletions = split(ghci.Read())[0]

    var respIdx = 0
    var matches = []
    while respIdx < str2nr(numCompletions)
      var match = substitute(ghci.Read(), '"', '', 'ge')
      matches->add(match)
      respIdx += 1
    endwhile

    return {words: matches}
  endif
enddef

export def Module()
  var pos = getpos('.')
  :g/^module/execute 'y m | @m = split(@m)[1]'
  ghci.SendCommand(':module + *' .. @m)
  setpos('.', pos)
enddef

export def Add()
  ghci.SendCommand(':add *' .. expand("%:p"))
enddef

export def Reload()
  ghci.SendCommand(':reload!')
  Module()
enddef

def CursorPopup(title: string): number
  var lines = ghci.ReadLines()
  var popup_win = popup_atcursor(lines, {
    title: title,
    border: []
  })
  var popup_buf = winbufnr(popup_win)
  setbufvar(popup_buf, '&syntax', 'haskell')

  return popup_buf
enddef

defcompile
