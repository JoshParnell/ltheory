-- Sphere ----------------------------------------------------------------------
local Sphere

local ffi = require('ffi')

do -- Global Symbol Table
  Sphere = {
  }

  local mt = {
    __call  = function (t, ...) return Sphere_t(...) end,
  }

  if onDef_Sphere then onDef_Sphere(Sphere, mt) end
  Sphere = setmetatable(Sphere, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Sphere')
  local mt = {
    __index = {
      clone = function (x) return Sphere_t(x) end,
    },
  }

  if onDef_Sphere_t then onDef_Sphere_t(t, mt) end
  Sphere_t = ffi.metatype(t, mt)
end

return Sphere
