-- Vec4i -----------------------------------------------------------------------
local Vec4i

local ffi = require('ffi')

do -- Global Symbol Table
  Vec4i = {
  }

  local mt = {
    __call  = function (t, ...) return Vec4i_t(...) end,
  }

  if onDef_Vec4i then onDef_Vec4i(Vec4i, mt) end
  Vec4i = setmetatable(Vec4i, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Vec4i')
  local mt = {
    __index = {
      clone = function (x) return Vec4i_t(x) end,
    },
  }

  if onDef_Vec4i_t then onDef_Vec4i_t(t, mt) end
  Vec4i_t = ffi.metatype(t, mt)
end

return Vec4i
