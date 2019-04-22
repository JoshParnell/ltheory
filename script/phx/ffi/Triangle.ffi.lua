-- Triangle --------------------------------------------------------------------
local Triangle

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void  Triangle_ToPlane     (Triangle const*, Plane*);
    void  Triangle_ToPlaneFast (Triangle const*, Plane*);
    float Triangle_GetArea     (Triangle const*);
    Error Triangle_Validate    (Triangle const*);
  ]]
end

do -- Global Symbol Table
  Triangle = {
    ToPlane     = libphx.Triangle_ToPlane,
    ToPlaneFast = libphx.Triangle_ToPlaneFast,
    GetArea     = libphx.Triangle_GetArea,
    Validate    = libphx.Triangle_Validate,
  }

  local mt = {
    __call  = function (t, ...) return Triangle_t(...) end,
  }

  if onDef_Triangle then onDef_Triangle(Triangle, mt) end
  Triangle = setmetatable(Triangle, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Triangle')
  local mt = {
    __index = {
      clone       = function (x) return Triangle_t(x) end,
      toPlane     = libphx.Triangle_ToPlane,
      toPlaneFast = libphx.Triangle_ToPlaneFast,
      getArea     = libphx.Triangle_GetArea,
      validate    = libphx.Triangle_Validate,
    },
  }

  if onDef_Triangle_t then onDef_Triangle_t(t, mt) end
  Triangle_t = ffi.metatype(t, mt)
end

return Triangle
