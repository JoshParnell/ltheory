-- Tex1D -----------------------------------------------------------------------
local Tex1D

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Tex1D*    Tex1D_Create       (int size, TexFormat);
    void      Tex1D_Acquire      (Tex1D*);
    void      Tex1D_Free         (Tex1D*);
    void      Tex1D_Draw         (Tex1D*, float x, float y, float xs, float ys);
    void      Tex1D_GenMipmap    (Tex1D*);
    void      Tex1D_GetData      (Tex1D*, void*, PixelFormat, DataFormat);
    Bytes*    Tex1D_GetDataBytes (Tex1D*, PixelFormat, DataFormat);
    TexFormat Tex1D_GetFormat    (Tex1D*);
    uint      Tex1D_GetHandle    (Tex1D*);
    uint      Tex1D_GetSize      (Tex1D*);
    void      Tex1D_SetData      (Tex1D*, void const*, PixelFormat, DataFormat);
    void      Tex1D_SetDataBytes (Tex1D*, Bytes*, PixelFormat, DataFormat);
    void      Tex1D_SetMagFilter (Tex1D*, TexFilter);
    void      Tex1D_SetMinFilter (Tex1D*, TexFilter);
    void      Tex1D_SetTexel     (Tex1D*, int x, float r, float g, float b, float a);
    void      Tex1D_SetWrapMode  (Tex1D*, TexWrapMode);
  ]]
end

do -- Global Symbol Table
  Tex1D = {
    Create       = libphx.Tex1D_Create,
    Acquire      = libphx.Tex1D_Acquire,
    Free         = libphx.Tex1D_Free,
    Draw         = libphx.Tex1D_Draw,
    GenMipmap    = libphx.Tex1D_GenMipmap,
    GetData      = libphx.Tex1D_GetData,
    GetDataBytes = libphx.Tex1D_GetDataBytes,
    GetFormat    = libphx.Tex1D_GetFormat,
    GetHandle    = libphx.Tex1D_GetHandle,
    GetSize      = libphx.Tex1D_GetSize,
    SetData      = libphx.Tex1D_SetData,
    SetDataBytes = libphx.Tex1D_SetDataBytes,
    SetMagFilter = libphx.Tex1D_SetMagFilter,
    SetMinFilter = libphx.Tex1D_SetMinFilter,
    SetTexel     = libphx.Tex1D_SetTexel,
    SetWrapMode  = libphx.Tex1D_SetWrapMode,
  }

  if onDef_Tex1D then onDef_Tex1D(Tex1D, mt) end
  Tex1D = setmetatable(Tex1D, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Tex1D')
  local mt = {
    __index = {
      managed      = function (self) return ffi.gc(self, libphx.Tex1D_Free) end,
      acquire      = libphx.Tex1D_Acquire,
      free         = libphx.Tex1D_Free,
      draw         = libphx.Tex1D_Draw,
      genMipmap    = libphx.Tex1D_GenMipmap,
      getData      = libphx.Tex1D_GetData,
      getDataBytes = libphx.Tex1D_GetDataBytes,
      getFormat    = libphx.Tex1D_GetFormat,
      getHandle    = libphx.Tex1D_GetHandle,
      getSize      = libphx.Tex1D_GetSize,
      setData      = libphx.Tex1D_SetData,
      setDataBytes = libphx.Tex1D_SetDataBytes,
      setMagFilter = libphx.Tex1D_SetMagFilter,
      setMinFilter = libphx.Tex1D_SetMinFilter,
      setTexel     = libphx.Tex1D_SetTexel,
      setWrapMode  = libphx.Tex1D_SetWrapMode,
    },
  }

  if onDef_Tex1D_t then onDef_Tex1D_t(t, mt) end
  Tex1D_t = ffi.metatype(t, mt)
end

return Tex1D
