-- LodMesh ---------------------------------------------------------------------
local LodMesh

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    LodMesh* LodMesh_Create  ();
    void     LodMesh_Acquire (LodMesh*);
    void     LodMesh_Free    (LodMesh*);
    void     LodMesh_Add     (LodMesh*, Mesh*, float distMin, float distMax);
    void     LodMesh_Draw    (LodMesh*, float distanceSquared);
    Mesh*    LodMesh_Get     (LodMesh*, float distanceSquared);
  ]]
end

do -- Global Symbol Table
  LodMesh = {
    Create  = libphx.LodMesh_Create,
    Acquire = libphx.LodMesh_Acquire,
    Free    = libphx.LodMesh_Free,
    Add     = libphx.LodMesh_Add,
    Draw    = libphx.LodMesh_Draw,
    Get     = libphx.LodMesh_Get,
  }

  if onDef_LodMesh then onDef_LodMesh(LodMesh, mt) end
  LodMesh = setmetatable(LodMesh, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('LodMesh')
  local mt = {
    __index = {
      managed = function (self) return ffi.gc(self, libphx.LodMesh_Free) end,
      acquire = libphx.LodMesh_Acquire,
      free    = libphx.LodMesh_Free,
      add     = libphx.LodMesh_Add,
      draw    = libphx.LodMesh_Draw,
      get     = libphx.LodMesh_Get,
    },
  }

  if onDef_LodMesh_t then onDef_LodMesh_t(t, mt) end
  LodMesh_t = ffi.metatype(t, mt)
end

return LodMesh
