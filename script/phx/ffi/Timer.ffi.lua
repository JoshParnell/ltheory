-- Timer -----------------------------------------------------------------------
local Timer

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Timer* Timer_Create      ();
    void   Timer_Free        (Timer*);
    double Timer_GetAndReset (Timer*);
    double Timer_GetElapsed  (Timer*);
    void   Timer_Reset       (Timer*);
  ]]
end

do -- Global Symbol Table
  Timer = {
    Create      = libphx.Timer_Create,
    Free        = libphx.Timer_Free,
    GetAndReset = libphx.Timer_GetAndReset,
    GetElapsed  = libphx.Timer_GetElapsed,
    Reset       = libphx.Timer_Reset,
  }

  if onDef_Timer then onDef_Timer(Timer, mt) end
  Timer = setmetatable(Timer, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Timer')
  local mt = {
    __index = {
      managed     = function (self) return ffi.gc(self, libphx.Timer_Free) end,
      free        = libphx.Timer_Free,
      getAndReset = libphx.Timer_GetAndReset,
      getElapsed  = libphx.Timer_GetElapsed,
      reset       = libphx.Timer_Reset,
    },
  }

  if onDef_Timer_t then onDef_Timer_t(t, mt) end
  Timer_t = ffi.metatype(t, mt)
end

return Timer
