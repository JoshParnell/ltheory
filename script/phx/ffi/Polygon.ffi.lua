-- Polygon ---------------------------------------------------------------------
local Polygon

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void  Polygon_ToPlane           (Polygon*, Plane*);
    void  Polygon_ToPlaneFast       (Polygon*, Plane*);
    void  Polygon_Split             (Polygon*, Plane splitPlane, Polygon* back, Polygon* front);
    void  Polygon_SplitSafe         (Polygon*, Plane splitPlane, Polygon* back, Polygon* front);
    void  Polygon_GetCentroid       (Polygon*, Vec3f*);
    void  Polygon_ConvexToTriangles (Polygon*, int32* triangles_capacity, int32* triangles_size, Triangle** triangles_data);
    Error Polygon_Validate          (Polygon*);
  ]]
end

do -- Global Symbol Table
  Polygon = {
    ToPlane           = libphx.Polygon_ToPlane,
    ToPlaneFast       = libphx.Polygon_ToPlaneFast,
    Split             = libphx.Polygon_Split,
    SplitSafe         = libphx.Polygon_SplitSafe,
    GetCentroid       = libphx.Polygon_GetCentroid,
    ConvexToTriangles = libphx.Polygon_ConvexToTriangles,
    Validate          = libphx.Polygon_Validate,
  }

  local mt = {
    __call  = function (t, ...) return Polygon_t(...) end,
  }

  if onDef_Polygon then onDef_Polygon(Polygon, mt) end
  Polygon = setmetatable(Polygon, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Polygon')
  local mt = {
    __index = {
      clone             = function (x) return Polygon_t(x) end,
      toPlane           = libphx.Polygon_ToPlane,
      toPlaneFast       = libphx.Polygon_ToPlaneFast,
      split             = libphx.Polygon_Split,
      splitSafe         = libphx.Polygon_SplitSafe,
      getCentroid       = libphx.Polygon_GetCentroid,
      convexToTriangles = libphx.Polygon_ConvexToTriangles,
      validate          = libphx.Polygon_Validate,
    },
  }

  if onDef_Polygon_t then onDef_Polygon_t(t, mt) end
  Polygon_t = ffi.metatype(t, mt)
end

return Polygon
