-- Metric ----------------------------------------------------------------------
local Metric

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    int32 Metric_Get     (Metric);
    cstr  Metric_GetName (Metric);
  ]]
end

do -- Global Symbol Table
  Metric = {
    None       = 0x0,
    DrawCalls  = 0x1,
    Immediate  = 0x2,
    PolysDrawn = 0x3,
    TrisDrawn  = 0x4,
    VertsDrawn = 0x5,
    Flush      = 0x6,
    FBOSwap    = 0x7,
    SIZE       = 0x7,
    Get     = libphx.Metric_Get,
    GetName = libphx.Metric_GetName,
  }

  if onDef_Metric then onDef_Metric(Metric, mt) end
  Metric = setmetatable(Metric, mt)
end

return Metric
