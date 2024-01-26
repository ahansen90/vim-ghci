vim9script

ch_logfile('/tmp/vim-ghci-log', 'w')

var buf = bufnr('ghci', 1)
bufload(buf)
setbufvar(buf, '&syntax', 'haskell')
setbufvar(buf, '&buftype', 'nofile')

export def GhciConnect(): channel
  var ghci = ch_open('unix:' .. g:vim_ghci_socket, {
    mode: 'nl'
  })
  ch_sendraw(ghci, ':set -fdefer-type-errors')
  ch_read(ghci, {timeout: 50})
  return ghci
enddef

# export def GhciStart(cmd: string)
#   g:vim_ghci_enabled = 1
#   ch_logfile('/tmp/vim-ghci-log', 'w')

#   var expandedCmd = expandcmd(cmd)

#   var ghci_job = job_start(expandedCmd, {
#     pty: 1
#   })

#   ghci = job_getchannel(ghci_job)

#   SendCommand(':set -fdefer-type-errors')
# enddef

export def ReadLines(ghci: channel): list<string>
  # Ignore first message since it's just an echo of the command
  ch_read(ghci)
  var resp = ch_read(ghci, {timeout: 1000})
  var lines = []
  var txt = ''
  while resp != ''
    var cleanedResp = substitute(resp, '\e\[[0-9;]*m', '', 'g')
    lines->add(cleanedResp)
    resp = ch_read(ghci)
  endwhile

  return lines
enddef

export def SendCommand(cmd: string, timeout = 200): list<string>
  var ghci = GhciConnect()
  ch_setoptions(ghci, {timeout: timeout})
  ch_sendraw(ghci, cmd .. '')
  var lines: list<string>
  if timeout > 0
    lines = ReadLines(ghci)
  else
    lines = []
  endif
  ch_close(ghci)
  return lines
enddef

export def AddLinesToBuffer(cmd: string, lines: list<string>)
  appendbufline(buf, '$', '>>> ' .. cmd)

  for line in lines
    appendbufline(buf, '$', line)
  endfor
enddef
