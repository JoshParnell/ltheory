-- RayCastResult ---------------------------------------------------------------
local RayCastResult

local ffi = require('ffi')

do -- Global Symbol Table
  RayCastResult = {
  }

  local mt = {
    __call  = function (t, ...) return RayCastResult_t(...) end,
  }

  if onDef_RayCastResult then onDef_RayCastResult(RayCastResult, mt) end
  RayCastResult = setmetatable(RayCastResult, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('RayCastResult')
  local mt = {
    __index = {
      clone = function (x) return RayCastResult_t(x) end,
    },
  }

  if onDef_RayCastResult_t then onDef_RayCastResult_t(t, mt) end
  RayCastResult_t = ffi.metatype(t, mt)
end

return RayCastResult
