-- Intersect -------------------------------------------------------------------
local Intersect

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    bool Intersect_PointBox                  (Matrix* t1, Matrix* t2);
    bool Intersect_PointTriangle_Barycentric (Vec3f const*, Triangle const*);
    bool Intersect_RayPlane                  (Ray const*, Plane const*, Vec3f* pHit);
    bool Intersect_RayTriangle_Barycentric   (Ray const*, Triangle const*, float tEpsilon, float* tHit);
    bool Intersect_RayTriangle_Moller1       (Ray const*, Triangle const*, float* tHit);
    bool Intersect_RayTriangle_Moller2       (Ray const*, Triangle const*, float* tHit);
    bool Intersect_LineSegmentPlane          (LineSegment const*, Plane const*, Vec3f* pHit);
    bool Intersect_RectRect                  (Vec4f const*, Vec4f const*);
    bool Intersect_RectRectFast              (Vec4f const*, Vec4f const*);
    bool Intersect_SphereTriangle            (Sphere const*, Triangle const*, Vec3f* pHit);
  ]]
end

do -- Global Symbol Table
  Intersect = {
    PointBox                  = libphx.Intersect_PointBox,
    PointTriangle_Barycentric = libphx.Intersect_PointTriangle_Barycentric,
    RayPlane                  = libphx.Intersect_RayPlane,
    RayTriangle_Barycentric   = libphx.Intersect_RayTriangle_Barycentric,
    RayTriangle_Moller1       = libphx.Intersect_RayTriangle_Moller1,
    RayTriangle_Moller2       = libphx.Intersect_RayTriangle_Moller2,
    LineSegmentPlane          = libphx.Intersect_LineSegmentPlane,
    RectRect                  = libphx.Intersect_RectRect,
    RectRectFast              = libphx.Intersect_RectRectFast,
    SphereTriangle            = libphx.Intersect_SphereTriangle,
  }

  if onDef_Intersect then onDef_Intersect(Intersect, mt) end
  Intersect = setmetatable(Intersect, mt)
end

return Intersect
