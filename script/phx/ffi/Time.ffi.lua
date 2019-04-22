-- Time ------------------------------------------------------------------------
local Time

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Time Time_GetLocal ();
    Time Time_GetUTC   ();
    uint Time_GetRaw   ();
  ]]
end

do -- Global Symbol Table
  Time = {
    GetLocal = libphx.Time_GetLocal,
    GetUTC   = libphx.Time_GetUTC,
    GetRaw   = libphx.Time_GetRaw,
  }

  local mt = {
    __call  = function (t, ...) return Time_t(...) end,
  }

  if onDef_Time then onDef_Time(Time, mt) end
  Time = setmetatable(Time, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Time')
  local mt = {
    __index = {
      clone    = function (x) return Time_t(x) end,
    },
  }

  if onDef_Time_t then onDef_Time_t(t, mt) end
  Time_t = ffi.metatype(t, mt)
end

return Time
