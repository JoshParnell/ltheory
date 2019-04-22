-- Plane -----------------------------------------------------------------------
local Plane

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    PointClassification   Plane_ClassifyPoint   (Plane*, Vec3f*);
    PolygonClassification Plane_ClassifyPolygon (Plane*, Polygon*);
    Error                 Plane_Validate        (Plane*);
    void                  Plane_FromPolygon     (Polygon*, Plane*);
    void                  Plane_FromPolygonFast (Polygon*, Plane*);
  ]]
end

do -- Global Symbol Table
  Plane = {
    ClassifyPoint   = libphx.Plane_ClassifyPoint,
    ClassifyPolygon = libphx.Plane_ClassifyPolygon,
    Validate        = libphx.Plane_Validate,
    FromPolygon     = libphx.Plane_FromPolygon,
    FromPolygonFast = libphx.Plane_FromPolygonFast,
  }

  local mt = {
    __call  = function (t, ...) return Plane_t(...) end,
  }

  if onDef_Plane then onDef_Plane(Plane, mt) end
  Plane = setmetatable(Plane, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Plane')
  local mt = {
    __index = {
      clone           = function (x) return Plane_t(x) end,
      classifyPoint   = libphx.Plane_ClassifyPoint,
      classifyPolygon = libphx.Plane_ClassifyPolygon,
      validate        = libphx.Plane_Validate,
    },
  }

  if onDef_Plane_t then onDef_Plane_t(t, mt) end
  Plane_t = ffi.metatype(t, mt)
end

return Plane
