-- Tex3D -----------------------------------------------------------------------
local Tex3D

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Tex3D*    Tex3D_Create       (int sx, int sy, int sz, TexFormat);
    void      Tex3D_Acquire      (Tex3D*);
    void      Tex3D_Free         (Tex3D*);
    void      Tex3D_Pop          (Tex3D*);
    void      Tex3D_Push         (Tex3D*, int layer);
    void      Tex3D_PushLevel    (Tex3D*, int layer, int level);
    void      Tex3D_Draw         (Tex3D* self, int layer, float x, float y, float xs, float ys);
    void      Tex3D_GenMipmap    (Tex3D*);
    void      Tex3D_GetData      (Tex3D*, void*, PixelFormat, DataFormat);
    Bytes*    Tex3D_GetDataBytes (Tex3D*, PixelFormat, DataFormat);
    TexFormat Tex3D_GetFormat    (Tex3D*);
    uint      Tex3D_GetHandle    (Tex3D*);
    void      Tex3D_GetSize      (Tex3D*, Vec3i* out);
    void      Tex3D_GetSizeLevel (Tex3D*, Vec3i* out, int level);
    void      Tex3D_SetData      (Tex3D*, void const*, PixelFormat, DataFormat);
    void      Tex3D_SetDataBytes (Tex3D*, Bytes*, PixelFormat, DataFormat);
    void      Tex3D_SetMagFilter (Tex3D*, TexFilter);
    void      Tex3D_SetMinFilter (Tex3D*, TexFilter);
    void      Tex3D_SetWrapMode  (Tex3D*, TexWrapMode);
  ]]
end

do -- Global Symbol Table
  Tex3D = {
    Create       = libphx.Tex3D_Create,
    Acquire      = libphx.Tex3D_Acquire,
    Free         = libphx.Tex3D_Free,
    Pop          = libphx.Tex3D_Pop,
    Push         = libphx.Tex3D_Push,
    PushLevel    = libphx.Tex3D_PushLevel,
    Draw         = libphx.Tex3D_Draw,
    GenMipmap    = libphx.Tex3D_GenMipmap,
    GetData      = libphx.Tex3D_GetData,
    GetDataBytes = libphx.Tex3D_GetDataBytes,
    GetFormat    = libphx.Tex3D_GetFormat,
    GetHandle    = libphx.Tex3D_GetHandle,
    GetSize      = libphx.Tex3D_GetSize,
    GetSizeLevel = libphx.Tex3D_GetSizeLevel,
    SetData      = libphx.Tex3D_SetData,
    SetDataBytes = libphx.Tex3D_SetDataBytes,
    SetMagFilter = libphx.Tex3D_SetMagFilter,
    SetMinFilter = libphx.Tex3D_SetMinFilter,
    SetWrapMode  = libphx.Tex3D_SetWrapMode,
  }

  if onDef_Tex3D then onDef_Tex3D(Tex3D, mt) end
  Tex3D = setmetatable(Tex3D, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Tex3D')
  local mt = {
    __index = {
      managed      = function (self) return ffi.gc(self, libphx.Tex3D_Free) end,
      acquire      = libphx.Tex3D_Acquire,
      free         = libphx.Tex3D_Free,
      pop          = libphx.Tex3D_Pop,
      push         = libphx.Tex3D_Push,
      pushLevel    = libphx.Tex3D_PushLevel,
      draw         = libphx.Tex3D_Draw,
      genMipmap    = libphx.Tex3D_GenMipmap,
      getData      = libphx.Tex3D_GetData,
      getDataBytes = libphx.Tex3D_GetDataBytes,
      getFormat    = libphx.Tex3D_GetFormat,
      getHandle    = libphx.Tex3D_GetHandle,
      getSize      = libphx.Tex3D_GetSize,
      getSizeLevel = libphx.Tex3D_GetSizeLevel,
      setData      = libphx.Tex3D_SetData,
      setDataBytes = libphx.Tex3D_SetDataBytes,
      setMagFilter = libphx.Tex3D_SetMagFilter,
      setMinFilter = libphx.Tex3D_SetMinFilter,
      setWrapMode  = libphx.Tex3D_SetWrapMode,
    },
  }

  if onDef_Tex3D_t then onDef_Tex3D_t(t, mt) end
  Tex3D_t = ffi.metatype(t, mt)
end

return Tex3D
