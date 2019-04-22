-- IntersectSphereProfiling ----------------------------------------------------
local IntersectSphereProfiling

local ffi = require('ffi')

do -- Global Symbol Table
  IntersectSphereProfiling = {
  }

  local mt = {
    __call  = function (t, ...) return IntersectSphereProfiling_t(...) end,
  }

  if onDef_IntersectSphereProfiling then onDef_IntersectSphereProfiling(IntersectSphereProfiling, mt) end
  IntersectSphereProfiling = setmetatable(IntersectSphereProfiling, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('IntersectSphereProfiling')
  local mt = {
    __index = {
      clone = function (x) return IntersectSphereProfiling_t(x) end,
    },
  }

  if onDef_IntersectSphereProfiling_t then onDef_IntersectSphereProfiling_t(t, mt) end
  IntersectSphereProfiling_t = ffi.metatype(t, mt)
end

return IntersectSphereProfiling
