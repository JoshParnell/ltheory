-- BoxMesh ---------------------------------------------------------------------
local BoxMesh

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    BoxMesh* BoxMesh_Create  ();
    void     BoxMesh_Free    (BoxMesh*);
    void     BoxMesh_Add     (BoxMesh*, float px, float py, float pz, float sx, float sy, float sz, float rx, float ry, float rz, float bx, float by, float bz);
    Mesh*    BoxMesh_GetMesh (BoxMesh*, int res);
  ]]
end

do -- Global Symbol Table
  BoxMesh = {
    Create  = libphx.BoxMesh_Create,
    Free    = libphx.BoxMesh_Free,
    Add     = libphx.BoxMesh_Add,
    GetMesh = libphx.BoxMesh_GetMesh,
  }

  if onDef_BoxMesh then onDef_BoxMesh(BoxMesh, mt) end
  BoxMesh = setmetatable(BoxMesh, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('BoxMesh')
  local mt = {
    __index = {
      managed = function (self) return ffi.gc(self, libphx.BoxMesh_Free) end,
      free    = libphx.BoxMesh_Free,
      add     = libphx.BoxMesh_Add,
      getMesh = libphx.BoxMesh_GetMesh,
    },
  }

  if onDef_BoxMesh_t then onDef_BoxMesh_t(t, mt) end
  BoxMesh_t = ffi.metatype(t, mt)
end

return BoxMesh
