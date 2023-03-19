vim9script noclear

var ghci: channel

export def GhciConnect(socket_path: string)
  g:vim_ghci_enabled = 1
  ch_logfile('/tmp/vim-ghci-log', 'w')
  ghci = ch_open('unix:' .. socket_path, {
    mode: 'nl',
    timeout: 50
    # callback: (chan, msg) => {
    #   popup_atcursor(msg, {})
    # }
  })
  ch_sendraw(ghci, ':set -fdefer-type-errors')
enddef

export def GhciStart(cmd: string)
  g:vim_ghci_enabled = 1
  ch_logfile('/tmp/vim-ghci-log', 'w')

  var expandedCmd = expandcmd(cmd)

  var ghci_job = job_start(expandedCmd, {
    pty: 1
  })

  ghci = job_getchannel(ghci_job)

  SendCommand(':set -fdefer-type-errors')
enddef

export def Read(timeout = 50): string
  if exists("ghci")
    return ch_read(ghci, {timeout: timeout})
  else
    throw "GHCI instance not available. Please use GhciConnect or GhciStart."
    return ''
  endif
enddef

export def ReadLines(): list<string>
  # Ignore first message since it's just an echo of the command
  Read()
  var resp = Read(2000)
  var lines = []
  var txt = ''
  while resp != ''
    lines->add(resp)
    resp = Read()
  endwhile

  return lines
enddef

export def SendCommand(cmd: string)
  if exists("ghci")
    ch_sendraw(ghci, cmd .. '')
  else
    throw "GHCI instance not available. Please use GhciConnect or GhciStart."
  endif
enddef

defcompile
