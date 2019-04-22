-- TimeStamp -------------------------------------------------------------------
local TimeStamp

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    TimeStamp TimeStamp_Get           ();
    double    TimeStamp_GetDifference (TimeStamp start, TimeStamp end);
    double    TimeStamp_GetElapsed    (TimeStamp start);
    double    TimeStamp_GetElapsedMs  (TimeStamp start);
    TimeStamp TimeStamp_GetFuture     (double seconds);
    TimeStamp TimeStamp_GetRelative   (TimeStamp start, double seconds);
    double    TimeStamp_ToDouble      (TimeStamp);
  ]]
end

do -- Global Symbol Table
  TimeStamp = {
    Get           = libphx.TimeStamp_Get,
    GetDifference = libphx.TimeStamp_GetDifference,
    GetElapsed    = libphx.TimeStamp_GetElapsed,
    GetElapsedMs  = libphx.TimeStamp_GetElapsedMs,
    GetFuture     = libphx.TimeStamp_GetFuture,
    GetRelative   = libphx.TimeStamp_GetRelative,
    ToDouble      = libphx.TimeStamp_ToDouble,
  }

  if onDef_TimeStamp then onDef_TimeStamp(TimeStamp, mt) end
  TimeStamp = setmetatable(TimeStamp, mt)
end

return TimeStamp
