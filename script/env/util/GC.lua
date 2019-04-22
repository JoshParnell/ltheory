local GC = {}

local passes    = 0
local callbacks = {}
local proxyMT   = {}

local function createProxy ()
  if not proxyMT.__gc then
    proxyMT.__gc = function ()
      passes = passes + 1
      for i = 1, #callbacks do callbacks[i]() end
      createProxy()
    end
  end

  local proxy = newproxy(true)
  debug.setmetatable(proxy, proxyMT)
end

-- Force a full GC pass
function GC.Collect ()
  collectgarbage('collect')
end

-- Average GC frequency since Engine_Init
function GC.GetFrequency ()
  return passes / Engine.GetTime()
end

-- GC Memory in Kb
function GC.GetMemory ()
  return collectgarbage('count')
end

-- Cumulative number of full GC passes
function GC.GetPasses ()
  return passes
end

function GC.RegisterCallback (fn)
  table.insert(callbacks, fn)
end

function GC.Start ()
  collectgarbage('restart')
end

function GC.Stop ()
  collectgarbage('stop')
end

function GC.UnregisterCallback (fn)
  for i = 1, #callbacks do
    if callbacks[i] == fn then table.remove(callbacks, i) end
  end
end

createProxy()

return GC
