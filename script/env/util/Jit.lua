local Config = require('env.util.Config')

local jp  = require('jit.p')
local jv  = require('jit.v')
local jd  = require('jit.dump2')
local bc  = require('jit.bc')

local Jit = {}

function Jit.GetBytecode (fn)
  local lines = {}
  local target = bc.targets(fn)
  for pc=1,1000000000 do
    local s = bc.line(fn, pc, target[pc] and '=>')
    if not s then break end
    lines[#lines + 1] = s
  end
  return table.concat(lines, '')
end

function Jit.StartDump ()
  jd.on('timT', 'log/jd.txt')
end

function Jit.StartProfile ()
  if Config.jit.profileVM then
    jp.start('fv2', 'log/jp.txt')
  else
    jp.start('vzF2i1', 'log/jp.txt')
    -- jp.start('Flvi1a', 'log/p.txt')
  end
end

function Jit.StartVerbose ()
  jv.on('log/jv.txt')
end

function Jit.StopDump ()
  jd.off()
end

function Jit.StopProfile ()
  jp.stop()
end

function Jit.StopVerbose ()
  jv.off()
end

return Jit
