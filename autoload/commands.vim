vim9script

import autoload './ghci.vim'

export def Ghci(cmd: string)
  var lines = ghci.SendCommand(cmd)
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

def GetQuery(expr: string, range: number): string
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

  return query
enddef

export def Info(expr: string, range: number, bang = '')
  var query = GetQuery(expr, range)
  var lines = ghci.SendCommand(':info' .. bang .. ' ' .. query)
  CursorPopup('Info', lines)
enddef

export def Instances(expr: string, range: number)
  var query = GetQuery(expr, range)
  var lines = ghci.SendCommand(':instances ' .. query)
  CursorPopup('Instances', lines)
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

  var lines = ghci.SendCommand(cmd)
  CursorPopup('Type', lines)
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

  if findstart == 1
    return FindStart()
  else
    var pattern: string
    if getline('.') =~ '^import'
      pattern = 'import ' .. base
    else
      pattern = base
    endif
    var lines = ghci.SendCommand(':complete repl "' .. pattern .. '"')

    var matches = lines[1 : ]->map((_, match) => substitute(match, '"', '', 'ge'))
    return {words: matches}
  endif
enddef

export def Module()
  var pos = getpos('.')
  :g/^module/execute 'y m | @m = split(@m)[1]'
  ghci.SendCommand(':module + *' .. @m, 0)
  setpos('.', pos)
enddef

export def Add()
  ghci.SendCommand(':add *' .. expand("%:p"), 0)
enddef

export def Reload()
  ghci.SendCommand(':reload!', 0)
  Module()
enddef

def CursorPopup(title: string, lines: list<string>): number
  var popup_win = popup_atcursor(lines, {
    title: title,
    border: []
  })
  var popup_buf = winbufnr(popup_win)
  setbufvar(popup_buf, '&syntax', 'haskell')

  return popup_buf
enddef

defcompile
