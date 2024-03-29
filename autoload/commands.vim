vim9script

import autoload './ghci.vim'

export def Ghci(cmd: string, range: number)
  var query = GetQuery(cmd, range)

  var lines = ghci.SendCommand(query)
  var popup_win = popup_create(lines, {
    title: 'Result',
    border: [],
    minwidth: 50,
    moved: "any"
  })
  var popup_buf = winbufnr(popup_win)
  appendbufline(popup_buf, 0, '>>> ' .. cmd)
  setbufvar(popup_buf, '&syntax', 'haskell')

  ghci.AddLinesToBuffer(query, lines)
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
  var cmd = ':info' .. bang .. ' ' .. query
  var lines = ghci.SendCommand(cmd)
  ghci.AddLinesToBuffer(cmd, lines)
  CursorPopup('Info', lines)
enddef

export def Instances(expr: string, range: number)
  var query = GetQuery(expr, range)
  var cmd = ':instances ' .. query
  var lines = ghci.SendCommand(cmd)
  ghci.AddLinesToBuffer
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
  ghci.AddLinesToBuffer(cmd, lines)
  CursorPopup('Type', lines)
enddef

export def HaskellComplete(findstart: number, base: string): any
  var isImport = getline('.') =~ '^import'
  def FindStart(): number
    var line = getline('.')
    var start = col('.') - 1
    if isImport
      start = 7
    else
      while start > 0 && (line[start - 1] =~ '\a' || line[start - 1] == '.')
        start -= 1
      endwhile
    endif
    return start
  enddef

  if findstart == 1
    return FindStart()
  else
    var pattern: string
    if isImport
      pattern = 'import ' .. base
    else
      pattern = base
    endif
    var lines = ghci.SendCommand(':complete repl "' .. pattern .. '"')

    var matches = lines[1 : ]->map((_, match) => substitute(match, '"', '', 'ge'))
    return {words: matches}
  endif
enddef

export def Module(): string
  var pos = getpos('.')
  var regBackup = @m

  :g/^module/execute 'y m | @m = split(@m)[1]'
  var moduleName = @m

  var cmd = ':module + *' .. moduleName
  ghci.SendCommand(cmd, 0)
  ghci.AddLinesToBuffer(cmd, [])

  @m = regBackup
  setpos('.', pos)
  return moduleName
enddef

export def Add()
  var cmd = ':add *' .. expand("%:p")
  ghci.SendCommand(cmd, 0)
  ghci.AddLinesToBuffer(cmd, [])
enddef

export def Reload()
  var cmd = ':reload!'
  ghci.SendCommand(cmd, 0)
  ghci.AddLinesToBuffer(cmd, [])
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
