-- Vec4d -----------------------------------------------------------------------
local Vec4d

local ffi = require('ffi')

do -- Global Symbol Table
  Vec4d = {
  }

  local mt = {
    __call  = function (t, ...) return Vec4d_t(...) end,
  }

  if onDef_Vec4d then onDef_Vec4d(Vec4d, mt) end
  Vec4d = setmetatable(Vec4d, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Vec4d')
  local mt = {
    __index = {
      clone = function (x) return Vec4d_t(x) end,
    },
  }

  if onDef_Vec4d_t then onDef_Vec4d_t(t, mt) end
  Vec4d_t = ffi.metatype(t, mt)
end

return Vec4d
