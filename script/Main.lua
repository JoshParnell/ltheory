package.path = package.path .. ';./script/?.lua'
package.path = package.path .. ';./script/?.ext.lua'
package.path = package.path .. ';./script/?.ffi.lua'

require('env.env')

Env.Call(function ()
  require('phx.phx')
  GlobalRestrict.On()

  dofile('Config.App.lua')
  if io.exists ('Config.Local.lua') then dofile('Config.Local.lua') end

  Namespace.LoadInline('Util')
  Namespace.Load      ('UI')
  Namespace.Load      ('WIP')
  Namespace.Load      ('Gen')
  Namespace.LoadInline('Game')

  jit.opt.start(
    format('maxtrace=%d',   Config.jit.tune.maxTrace),
    format('maxrecord=%d',  Config.jit.tune.maxRecord),
    format('maxirconst=%d', Config.jit.tune.maxConst),
    format('maxside=%d',    Config.jit.tune.maxSide),
    format('maxsnap=%d',    Config.jit.tune.maxSnap),
    format('hotloop=%d',    Config.jit.tune.hotLoop),
    format('hotexit=%d',    Config.jit.tune.hotExit),
    format('tryside=%d',    Config.jit.tune.trySide),
    format('instunroll=%d', Config.jit.tune.instUnroll),
    format('loopunroll=%d', Config.jit.tune.loopUnroll),
    format('callunroll=%d', Config.jit.tune.callUnroll),
    format('recunroll=%d',  Config.jit.tune.recUnroll),
    format('sizemcode=%d',  Config.jit.tune.sizeMCode),
    format('maxmcode=%d',   Config.jit.tune.maxMCode)
  )

  require('App.' .. Config.app):run()
  GlobalRestrict.Off()
end)
