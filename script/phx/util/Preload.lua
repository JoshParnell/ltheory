--[[----------------------------------------------------------------------------
  Provides a simple mechanism for registering 'preload' functions to be run
  at application initialization time (*after* an OpenGL context exists). Useful
  for pre-loading shared game assets (e.g. in upvalues); avoids potential stalls
  due to lazy loading.
----------------------------------------------------------------------------]]--
local Preload = {}
local fns = {}

function Preload.Add (fn)
  fns[#fns + 1] = fn
end

function Preload.Run ()
  Profiler.Begin('Preload.Run')
  for i = 1, #fns do fns[i]() end
  Profiler.End()
end

return Preload
