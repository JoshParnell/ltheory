-- BSP -------------------------------------------------------------------------
local BSP

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    BSP* BSP_Create               (Mesh*);
    void BSP_Free                 (BSP*);
    bool BSP_IntersectRay         (BSP*, Ray const*, float* tHit);
    bool BSP_IntersectLineSegment (BSP*, LineSegment const*, Vec3f* pHit);
    bool BSP_IntersectSphere      (BSP*, Sphere const*, Vec3f* pHit);
  ]]
end

do -- Global Symbol Table
  BSP = {
    Create               = libphx.BSP_Create,
    Free                 = libphx.BSP_Free,
    IntersectRay         = libphx.BSP_IntersectRay,
    IntersectLineSegment = libphx.BSP_IntersectLineSegment,
    IntersectSphere      = libphx.BSP_IntersectSphere,
  }

  if onDef_BSP then onDef_BSP(BSP, mt) end
  BSP = setmetatable(BSP, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('BSP')
  local mt = {
    __index = {
      managed              = function (self) return ffi.gc(self, libphx.BSP_Free) end,
      free                 = libphx.BSP_Free,
      intersectRay         = libphx.BSP_IntersectRay,
      intersectLineSegment = libphx.BSP_IntersectLineSegment,
      intersectSphere      = libphx.BSP_IntersectSphere,
    },
  }

  if onDef_BSP_t then onDef_BSP_t(t, mt) end
  BSP_t = ffi.metatype(t, mt)
end

return BSP
