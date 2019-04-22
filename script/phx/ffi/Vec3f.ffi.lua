-- Vec3f -----------------------------------------------------------------------
local Vec3f

local ffi = require('ffi')

do -- Global Symbol Table
  Vec3f = {
  }

  local mt = {
    __call  = function (t, ...) return Vec3f_t(...) end,
  }

  if onDef_Vec3f then onDef_Vec3f(Vec3f, mt) end
  Vec3f = setmetatable(Vec3f, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Vec3f')
  local mt = {
    __index = {
      clone = function (x) return Vec3f_t(x) end,
    },
  }

  if onDef_Vec3f_t then onDef_Vec3f_t(t, mt) end
  Vec3f_t = ffi.metatype(t, mt)
end

return Vec3f
