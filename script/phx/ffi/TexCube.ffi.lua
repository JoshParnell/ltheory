-- TexCube ---------------------------------------------------------------------
local TexCube

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    TexCube*  TexCube_Create       (int size, TexFormat);
    TexCube*  TexCube_Load         (cstr path);
    void      TexCube_Acquire      (TexCube*);
    void      TexCube_Free         (TexCube*);
    void      TexCube_Clear        (TexCube*, float r, float g, float b, float a);
    void      TexCube_Generate     (TexCube*, ShaderState*);
    TexCube*  TexCube_GenIRMap     (TexCube*, int samples);
    void      TexCube_GenMipmap    (TexCube*);
    void      TexCube_GetData      (TexCube*, void*, CubeFace, int level, PixelFormat, DataFormat);
    Bytes*    TexCube_GetDataBytes (TexCube*, CubeFace, int level, PixelFormat, DataFormat);
    TexFormat TexCube_GetFormat    (TexCube*);
    uint      TexCube_GetHandle    (TexCube*);
    int       TexCube_GetSize      (TexCube*);
    void      TexCube_SetData      (TexCube*, void const*, CubeFace, int level, PixelFormat, DataFormat);
    void      TexCube_SetDataBytes (TexCube*, Bytes*, CubeFace, int level, PixelFormat, DataFormat);
    void      TexCube_SetMagFilter (TexCube*, TexFilter);
    void      TexCube_SetMinFilter (TexCube*, TexFilter);
    void      TexCube_Save         (TexCube*, cstr path);
    void      TexCube_SaveLevel    (TexCube*, cstr path, int level);
  ]]
end

do -- Global Symbol Table
  TexCube = {
    Create       = libphx.TexCube_Create,
    Load         = libphx.TexCube_Load,
    Acquire      = libphx.TexCube_Acquire,
    Free         = libphx.TexCube_Free,
    Clear        = libphx.TexCube_Clear,
    Generate     = libphx.TexCube_Generate,
    GenIRMap     = libphx.TexCube_GenIRMap,
    GenMipmap    = libphx.TexCube_GenMipmap,
    GetData      = libphx.TexCube_GetData,
    GetDataBytes = libphx.TexCube_GetDataBytes,
    GetFormat    = libphx.TexCube_GetFormat,
    GetHandle    = libphx.TexCube_GetHandle,
    GetSize      = libphx.TexCube_GetSize,
    SetData      = libphx.TexCube_SetData,
    SetDataBytes = libphx.TexCube_SetDataBytes,
    SetMagFilter = libphx.TexCube_SetMagFilter,
    SetMinFilter = libphx.TexCube_SetMinFilter,
    Save         = libphx.TexCube_Save,
    SaveLevel    = libphx.TexCube_SaveLevel,
  }

  if onDef_TexCube then onDef_TexCube(TexCube, mt) end
  TexCube = setmetatable(TexCube, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('TexCube')
  local mt = {
    __index = {
      managed      = function (self) return ffi.gc(self, libphx.TexCube_Free) end,
      acquire      = libphx.TexCube_Acquire,
      free         = libphx.TexCube_Free,
      clear        = libphx.TexCube_Clear,
      generate     = libphx.TexCube_Generate,
      genIRMap     = libphx.TexCube_GenIRMap,
      genMipmap    = libphx.TexCube_GenMipmap,
      getData      = libphx.TexCube_GetData,
      getDataBytes = libphx.TexCube_GetDataBytes,
      getFormat    = libphx.TexCube_GetFormat,
      getHandle    = libphx.TexCube_GetHandle,
      getSize      = libphx.TexCube_GetSize,
      setData      = libphx.TexCube_SetData,
      setDataBytes = libphx.TexCube_SetDataBytes,
      setMagFilter = libphx.TexCube_SetMagFilter,
      setMinFilter = libphx.TexCube_SetMinFilter,
      save         = libphx.TexCube_Save,
      saveLevel    = libphx.TexCube_SaveLevel,
    },
  }

  if onDef_TexCube_t then onDef_TexCube_t(t, mt) end
  TexCube_t = ffi.metatype(t, mt)
end

return TexCube
