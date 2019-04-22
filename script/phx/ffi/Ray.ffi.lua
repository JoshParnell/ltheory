-- Ray -------------------------------------------------------------------------
local Ray

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void Ray_GetPoint                      (Ray const*, float t, Vec3f* out);
    bool Ray_IntersectPlane                (Ray const*, Plane const*, Vec3f* pHit);
    bool Ray_IntersectTriangle_Barycentric (Ray const*, Triangle const*, float tEpsilon, float* tHit);
    bool Ray_IntersectTriangle_Moller1     (Ray const*, Triangle const*, float* tHit);
    bool Ray_IntersectTriangle_Moller2     (Ray const*, Triangle const*, float* tHit);
    void Ray_ToLineSegment                 (Ray const*, LineSegment*);
    void Ray_FromLineSegment               (LineSegment const*, Ray*);
  ]]
end

do -- Global Symbol Table
  Ray = {
    GetPoint                      = libphx.Ray_GetPoint,
    IntersectPlane                = libphx.Ray_IntersectPlane,
    IntersectTriangle_Barycentric = libphx.Ray_IntersectTriangle_Barycentric,
    IntersectTriangle_Moller1     = libphx.Ray_IntersectTriangle_Moller1,
    IntersectTriangle_Moller2     = libphx.Ray_IntersectTriangle_Moller2,
    ToLineSegment                 = libphx.Ray_ToLineSegment,
    FromLineSegment               = libphx.Ray_FromLineSegment,
  }

  local mt = {
    __call  = function (t, ...) return Ray_t(...) end,
  }

  if onDef_Ray then onDef_Ray(Ray, mt) end
  Ray = setmetatable(Ray, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Ray')
  local mt = {
    __index = {
      clone                         = function (x) return Ray_t(x) end,
      getPoint                      = libphx.Ray_GetPoint,
      intersectPlane                = libphx.Ray_IntersectPlane,
      intersectTriangle_Barycentric = libphx.Ray_IntersectTriangle_Barycentric,
      intersectTriangle_Moller1     = libphx.Ray_IntersectTriangle_Moller1,
      intersectTriangle_Moller2     = libphx.Ray_IntersectTriangle_Moller2,
      toLineSegment                 = libphx.Ray_ToLineSegment,
    },
  }

  if onDef_Ray_t then onDef_Ray_t(t, mt) end
  Ray_t = ffi.metatype(t, mt)
end

return Ray
