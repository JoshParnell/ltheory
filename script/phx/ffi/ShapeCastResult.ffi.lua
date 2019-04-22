-- ShapeCastResult -------------------------------------------------------------
local ShapeCastResult

local ffi = require('ffi')

do -- Global Symbol Table
  ShapeCastResult = {
  }

  local mt = {
    __call  = function (t, ...) return ShapeCastResult_t(...) end,
  }

  if onDef_ShapeCastResult then onDef_ShapeCastResult(ShapeCastResult, mt) end
  ShapeCastResult = setmetatable(ShapeCastResult, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('ShapeCastResult')
  local mt = {
    __index = {
      clone = function (x) return ShapeCastResult_t(x) end,
    },
  }

  if onDef_ShapeCastResult_t then onDef_ShapeCastResult_t(t, mt) end
  ShapeCastResult_t = ffi.metatype(t, mt)
end

return ShapeCastResult
