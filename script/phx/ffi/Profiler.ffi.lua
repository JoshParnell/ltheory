-- Profiler --------------------------------------------------------------------
local Profiler

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void Profiler_Enable     ();
    void Profiler_Disable    ();
    void Profiler_Begin      (cstr);
    void Profiler_End        ();
    void Profiler_SetValue   (cstr, int);
    void Profiler_LoopMarker ();
    void Profiler_Backtrace  ();
  ]]
end

do -- Global Symbol Table
  Profiler = {
    Enable     = libphx.Profiler_Enable,
    Disable    = libphx.Profiler_Disable,
    Begin      = libphx.Profiler_Begin,
    End        = libphx.Profiler_End,
    SetValue   = libphx.Profiler_SetValue,
    LoopMarker = libphx.Profiler_LoopMarker,
    Backtrace  = libphx.Profiler_Backtrace,
  }

  if onDef_Profiler then onDef_Profiler(Profiler, mt) end
  Profiler = setmetatable(Profiler, mt)
end

return Profiler
