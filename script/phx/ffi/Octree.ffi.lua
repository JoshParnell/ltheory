-- Octree ----------------------------------------------------------------------
local Octree

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Octree* Octree_Create       (Box3f bound);
    Octree* Octree_FromMesh     (Mesh*);
    void    Octree_Free         (Octree*);
    void    Octree_Add          (Octree*, Box3f bound, uint32 id);
    void    Octree_Draw         (Octree*);
    double  Octree_GetAvgLoad   (Octree*);
    int     Octree_GetMaxLoad   (Octree*);
    int     Octree_GetMemory    (Octree*);
    bool    Octree_IntersectRay (Octree*, Matrix*, Vec3f const* ro, Vec3f const* rd);
  ]]
end

do -- Global Symbol Table
  Octree = {
    Create       = libphx.Octree_Create,
    FromMesh     = libphx.Octree_FromMesh,
    Free         = libphx.Octree_Free,
    Add          = libphx.Octree_Add,
    Draw         = libphx.Octree_Draw,
    GetAvgLoad   = libphx.Octree_GetAvgLoad,
    GetMaxLoad   = libphx.Octree_GetMaxLoad,
    GetMemory    = libphx.Octree_GetMemory,
    IntersectRay = libphx.Octree_IntersectRay,
  }

  if onDef_Octree then onDef_Octree(Octree, mt) end
  Octree = setmetatable(Octree, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Octree')
  local mt = {
    __index = {
      managed      = function (self) return ffi.gc(self, libphx.Octree_Free) end,
      free         = libphx.Octree_Free,
      add          = libphx.Octree_Add,
      draw         = libphx.Octree_Draw,
      getAvgLoad   = libphx.Octree_GetAvgLoad,
      getMaxLoad   = libphx.Octree_GetMaxLoad,
      getMemory    = libphx.Octree_GetMemory,
      intersectRay = libphx.Octree_IntersectRay,
    },
  }

  if onDef_Octree_t then onDef_Octree_t(t, mt) end
  Octree_t = ffi.metatype(t, mt)
end

return Octree
