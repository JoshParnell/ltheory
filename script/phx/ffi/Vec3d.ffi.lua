-- Vec3d -----------------------------------------------------------------------
local Vec3d

local ffi = require('ffi')

do -- Global Symbol Table
  Vec3d = {
  }

  local mt = {
    __call  = function (t, ...) return Vec3d_t(...) end,
  }

  if onDef_Vec3d then onDef_Vec3d(Vec3d, mt) end
  Vec3d = setmetatable(Vec3d, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Vec3d')
  local mt = {
    __index = {
      clone = function (x) return Vec3d_t(x) end,
    },
  }

  if onDef_Vec3d_t then onDef_Vec3d_t(t, mt) end
  Vec3d_t = ffi.metatype(t, mt)
end

return Vec3d
