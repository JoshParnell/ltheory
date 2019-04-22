-- SDF -------------------------------------------------------------------------
local SDF

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    SDF*  SDF_Create         (int sx, int sy, int sz);
    SDF*  SDF_FromTex3D      (Tex3D*);
    void  SDF_Free           (SDF*);
    Mesh* SDF_ToMesh         (SDF*);
    void  SDF_Clear          (SDF*, float value);
    void  SDF_ComputeNormals (SDF*);
    void  SDF_Set            (SDF*, int x, int y, int z, float value);
    void  SDF_SetNormal      (SDF*, int x, int y, int z, Vec3f const* normal);
  ]]
end

do -- Global Symbol Table
  SDF = {
    Create         = libphx.SDF_Create,
    FromTex3D      = libphx.SDF_FromTex3D,
    Free           = libphx.SDF_Free,
    ToMesh         = libphx.SDF_ToMesh,
    Clear          = libphx.SDF_Clear,
    ComputeNormals = libphx.SDF_ComputeNormals,
    Set            = libphx.SDF_Set,
    SetNormal      = libphx.SDF_SetNormal,
  }

  if onDef_SDF then onDef_SDF(SDF, mt) end
  SDF = setmetatable(SDF, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('SDF')
  local mt = {
    __index = {
      managed        = function (self) return ffi.gc(self, libphx.SDF_Free) end,
      free           = libphx.SDF_Free,
      toMesh         = libphx.SDF_ToMesh,
      clear          = libphx.SDF_Clear,
      computeNormals = libphx.SDF_ComputeNormals,
      set            = libphx.SDF_Set,
      setNormal      = libphx.SDF_SetNormal,
    },
  }

  if onDef_SDF_t then onDef_SDF_t(t, mt) end
  SDF_t = ffi.metatype(t, mt)
end

return SDF
