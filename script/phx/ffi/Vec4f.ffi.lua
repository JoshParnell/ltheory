-- Vec4f -----------------------------------------------------------------------
local Vec4f

local ffi = require('ffi')

do -- Global Symbol Table
  Vec4f = {
  }

  local mt = {
    __call  = function (t, ...) return Vec4f_t(...) end,
  }

  if onDef_Vec4f then onDef_Vec4f(Vec4f, mt) end
  Vec4f = setmetatable(Vec4f, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Vec4f')
  local mt = {
    __index = {
      clone = function (x) return Vec4f_t(x) end,
    },
  }

  if onDef_Vec4f_t then onDef_Vec4f_t(t, mt) end
  Vec4f_t = ffi.metatype(t, mt)
end

return Vec4f
