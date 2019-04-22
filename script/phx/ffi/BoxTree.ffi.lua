-- BoxTree ---------------------------------------------------------------------
local BoxTree

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    BoxTree* BoxTree_Create       ();
    BoxTree* BoxTree_FromMesh     (Mesh*);
    void     BoxTree_Free         (BoxTree*);
    void     BoxTree_Add          (BoxTree*, Box3f bound, void* data);
    void     BoxTree_Draw         (BoxTree*, int maxDepth);
    int      BoxTree_GetMemory    (BoxTree*);
    bool     BoxTree_IntersectRay (BoxTree*, Matrix*, Vec3f const* ro, Vec3f const* rd);
  ]]
end

do -- Global Symbol Table
  BoxTree = {
    Create       = libphx.BoxTree_Create,
    FromMesh     = libphx.BoxTree_FromMesh,
    Free         = libphx.BoxTree_Free,
    Add          = libphx.BoxTree_Add,
    Draw         = libphx.BoxTree_Draw,
    GetMemory    = libphx.BoxTree_GetMemory,
    IntersectRay = libphx.BoxTree_IntersectRay,
  }

  if onDef_BoxTree then onDef_BoxTree(BoxTree, mt) end
  BoxTree = setmetatable(BoxTree, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('BoxTree')
  local mt = {
    __index = {
      managed      = function (self) return ffi.gc(self, libphx.BoxTree_Free) end,
      free         = libphx.BoxTree_Free,
      add          = libphx.BoxTree_Add,
      draw         = libphx.BoxTree_Draw,
      getMemory    = libphx.BoxTree_GetMemory,
      intersectRay = libphx.BoxTree_IntersectRay,
    },
  }

  if onDef_BoxTree_t then onDef_BoxTree_t(t, mt) end
  BoxTree_t = ffi.metatype(t, mt)
end

return BoxTree
