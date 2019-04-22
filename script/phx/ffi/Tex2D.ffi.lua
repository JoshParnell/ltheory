-- Tex2D -----------------------------------------------------------------------
local Tex2D

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Tex2D*    Tex2D_Create        (int sx, int sy, TexFormat);
    Tex2D*    Tex2D_Load          (cstr name);
    Tex2D*    Tex2D_ScreenCapture ();
    void      Tex2D_Acquire       (Tex2D*);
    void      Tex2D_Free          (Tex2D*);
    void      Tex2D_Pop           (Tex2D*);
    void      Tex2D_Push          (Tex2D*);
    void      Tex2D_PushLevel     (Tex2D*, int level);
    void      Tex2D_Clear         (Tex2D*, float r, float g, float b, float a);
    Tex2D*    Tex2D_Clone         (Tex2D*);
    void      Tex2D_Draw          (Tex2D*, float x, float y, float sx, float sy);
    void      Tex2D_DrawEx        (Tex2D*, float x0, float y0, float x1, float y1, float u0, float v0, float u1, float v1);
    void      Tex2D_GenMipmap     (Tex2D*);
    void      Tex2D_GetData       (Tex2D*, void*, PixelFormat, DataFormat);
    Bytes*    Tex2D_GetDataBytes  (Tex2D*, PixelFormat, DataFormat);
    TexFormat Tex2D_GetFormat     (Tex2D*);
    uint      Tex2D_GetHandle     (Tex2D*);
    void      Tex2D_GetSize       (Tex2D*, Vec2i* out);
    void      Tex2D_GetSizeLevel  (Tex2D*, Vec2i* out, int level);
    void      Tex2D_SetAnisotropy (Tex2D*, float);
    void      Tex2D_SetData       (Tex2D*, void const*, PixelFormat, DataFormat);
    void      Tex2D_SetDataBytes  (Tex2D*, Bytes*, PixelFormat, DataFormat);
    void      Tex2D_SetMagFilter  (Tex2D*, TexFilter);
    void      Tex2D_SetMinFilter  (Tex2D*, TexFilter);
    void      Tex2D_SetMipRange   (Tex2D*, int minLevel, int maxLevel);
    void      Tex2D_SetTexel      (Tex2D*, int x, int y, float r, float g, float b, float a);
    void      Tex2D_SetWrapMode   (Tex2D*, TexWrapMode);
    void      Tex2D_Save          (Tex2D*, cstr path);
  ]]
end

do -- Global Symbol Table
  Tex2D = {
    Create        = libphx.Tex2D_Create,
    Load          = libphx.Tex2D_Load,
    ScreenCapture = libphx.Tex2D_ScreenCapture,
    Acquire       = libphx.Tex2D_Acquire,
    Free          = libphx.Tex2D_Free,
    Pop           = libphx.Tex2D_Pop,
    Push          = libphx.Tex2D_Push,
    PushLevel     = libphx.Tex2D_PushLevel,
    Clear         = libphx.Tex2D_Clear,
    Clone         = libphx.Tex2D_Clone,
    Draw          = libphx.Tex2D_Draw,
    DrawEx        = libphx.Tex2D_DrawEx,
    GenMipmap     = libphx.Tex2D_GenMipmap,
    GetData       = libphx.Tex2D_GetData,
    GetDataBytes  = libphx.Tex2D_GetDataBytes,
    GetFormat     = libphx.Tex2D_GetFormat,
    GetHandle     = libphx.Tex2D_GetHandle,
    GetSize       = libphx.Tex2D_GetSize,
    GetSizeLevel  = libphx.Tex2D_GetSizeLevel,
    SetAnisotropy = libphx.Tex2D_SetAnisotropy,
    SetData       = libphx.Tex2D_SetData,
    SetDataBytes  = libphx.Tex2D_SetDataBytes,
    SetMagFilter  = libphx.Tex2D_SetMagFilter,
    SetMinFilter  = libphx.Tex2D_SetMinFilter,
    SetMipRange   = libphx.Tex2D_SetMipRange,
    SetTexel      = libphx.Tex2D_SetTexel,
    SetWrapMode   = libphx.Tex2D_SetWrapMode,
    Save          = libphx.Tex2D_Save,
  }

  if onDef_Tex2D then onDef_Tex2D(Tex2D, mt) end
  Tex2D = setmetatable(Tex2D, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Tex2D')
  local mt = {
    __index = {
      managed       = function (self) return ffi.gc(self, libphx.Tex2D_Free) end,
      acquire       = libphx.Tex2D_Acquire,
      free          = libphx.Tex2D_Free,
      pop           = libphx.Tex2D_Pop,
      push          = libphx.Tex2D_Push,
      pushLevel     = libphx.Tex2D_PushLevel,
      clear         = libphx.Tex2D_Clear,
      clone         = libphx.Tex2D_Clone,
      draw          = libphx.Tex2D_Draw,
      drawEx        = libphx.Tex2D_DrawEx,
      genMipmap     = libphx.Tex2D_GenMipmap,
      getData       = libphx.Tex2D_GetData,
      getDataBytes  = libphx.Tex2D_GetDataBytes,
      getFormat     = libphx.Tex2D_GetFormat,
      getHandle     = libphx.Tex2D_GetHandle,
      getSize       = libphx.Tex2D_GetSize,
      getSizeLevel  = libphx.Tex2D_GetSizeLevel,
      setAnisotropy = libphx.Tex2D_SetAnisotropy,
      setData       = libphx.Tex2D_SetData,
      setDataBytes  = libphx.Tex2D_SetDataBytes,
      setMagFilter  = libphx.Tex2D_SetMagFilter,
      setMinFilter  = libphx.Tex2D_SetMinFilter,
      setMipRange   = libphx.Tex2D_SetMipRange,
      setTexel      = libphx.Tex2D_SetTexel,
      setWrapMode   = libphx.Tex2D_SetWrapMode,
      save          = libphx.Tex2D_Save,
    },
  }

  if onDef_Tex2D_t then onDef_Tex2D_t(t, mt) end
  Tex2D_t = ffi.metatype(t, mt)
end

return Tex2D
