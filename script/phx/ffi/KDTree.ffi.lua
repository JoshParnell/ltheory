-- KDTree ----------------------------------------------------------------------
local KDTree

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    KDTree* KDTree_FromMesh     (Mesh*);
    void    KDTree_Free         (KDTree*);
    void    KDTree_Draw         (KDTree*, int maxDepth);
    int     KDTree_GetMemory    (KDTree*);
    bool    KDTree_IntersectRay (KDTree*, Matrix*, Vec3f const* ro, Vec3f const* rd);
  ]]
end

do -- Global Symbol Table
  KDTree = {
    FromMesh     = libphx.KDTree_FromMesh,
    Free         = libphx.KDTree_Free,
    Draw         = libphx.KDTree_Draw,
    GetMemory    = libphx.KDTree_GetMemory,
    IntersectRay = libphx.KDTree_IntersectRay,
  }

  if onDef_KDTree then onDef_KDTree(KDTree, mt) end
  KDTree = setmetatable(KDTree, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('KDTree')
  local mt = {
    __index = {
      managed      = function (self) return ffi.gc(self, libphx.KDTree_Free) end,
      free         = libphx.KDTree_Free,
      draw         = libphx.KDTree_Draw,
      getMemory    = libphx.KDTree_GetMemory,
      intersectRay = libphx.KDTree_IntersectRay,
    },
  }

  if onDef_KDTree_t then onDef_KDTree_t(t, mt) end
  KDTree_t = ffi.metatype(t, mt)
end

return KDTree
