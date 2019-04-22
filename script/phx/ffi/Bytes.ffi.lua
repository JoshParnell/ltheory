-- Bytes -----------------------------------------------------------------------
local Bytes

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Bytes* Bytes_Create     (uint32 len);
    Bytes* Bytes_FromData   (void const* data, uint32 len);
    Bytes* Bytes_Load       (cstr path);
    void   Bytes_Free       (Bytes*);
    void*  Bytes_GetData    (Bytes*);
    uint32 Bytes_GetSize    (Bytes*);
    Bytes* Bytes_Compress   (Bytes*);
    Bytes* Bytes_Decompress (Bytes*);
    uint32 Bytes_GetCursor  (Bytes*);
    void   Bytes_Rewind     (Bytes*);
    void   Bytes_SetCursor  (Bytes*, uint32);
    void   Bytes_Read       (Bytes*, void* data, uint32 len);
    uint8  Bytes_ReadU8     (Bytes*);
    uint16 Bytes_ReadU16    (Bytes*);
    uint32 Bytes_ReadU32    (Bytes*);
    uint64 Bytes_ReadU64    (Bytes*);
    int8   Bytes_ReadI8     (Bytes*);
    int16  Bytes_ReadI16    (Bytes*);
    int32  Bytes_ReadI32    (Bytes*);
    int64  Bytes_ReadI64    (Bytes*);
    float  Bytes_ReadF32    (Bytes*);
    double Bytes_ReadF64    (Bytes*);
    void   Bytes_Write      (Bytes*, void const* data, uint32 len);
    void   Bytes_WriteStr   (Bytes*, cstr data);
    void   Bytes_WriteU8    (Bytes*, uint8);
    void   Bytes_WriteU16   (Bytes*, uint16);
    void   Bytes_WriteU32   (Bytes*, uint32);
    void   Bytes_WriteU64   (Bytes*, uint64);
    void   Bytes_WriteI8    (Bytes*, int8);
    void   Bytes_WriteI16   (Bytes*, int16);
    void   Bytes_WriteI32   (Bytes*, int32);
    void   Bytes_WriteI64   (Bytes*, int64);
    void   Bytes_WriteF32   (Bytes*, float);
    void   Bytes_WriteF64   (Bytes*, double);
    void   Bytes_Print      (Bytes*);
    void   Bytes_Save       (Bytes*, cstr path);
  ]]
end

do -- Global Symbol Table
  Bytes = {
    Create     = libphx.Bytes_Create,
    FromData   = libphx.Bytes_FromData,
    Load       = libphx.Bytes_Load,
    Free       = libphx.Bytes_Free,
    GetData    = libphx.Bytes_GetData,
    GetSize    = libphx.Bytes_GetSize,
    Compress   = libphx.Bytes_Compress,
    Decompress = libphx.Bytes_Decompress,
    GetCursor  = libphx.Bytes_GetCursor,
    Rewind     = libphx.Bytes_Rewind,
    SetCursor  = libphx.Bytes_SetCursor,
    Read       = libphx.Bytes_Read,
    ReadU8     = libphx.Bytes_ReadU8,
    ReadU16    = libphx.Bytes_ReadU16,
    ReadU32    = libphx.Bytes_ReadU32,
    ReadU64    = libphx.Bytes_ReadU64,
    ReadI8     = libphx.Bytes_ReadI8,
    ReadI16    = libphx.Bytes_ReadI16,
    ReadI32    = libphx.Bytes_ReadI32,
    ReadI64    = libphx.Bytes_ReadI64,
    ReadF32    = libphx.Bytes_ReadF32,
    ReadF64    = libphx.Bytes_ReadF64,
    Write      = libphx.Bytes_Write,
    WriteStr   = libphx.Bytes_WriteStr,
    WriteU8    = libphx.Bytes_WriteU8,
    WriteU16   = libphx.Bytes_WriteU16,
    WriteU32   = libphx.Bytes_WriteU32,
    WriteU64   = libphx.Bytes_WriteU64,
    WriteI8    = libphx.Bytes_WriteI8,
    WriteI16   = libphx.Bytes_WriteI16,
    WriteI32   = libphx.Bytes_WriteI32,
    WriteI64   = libphx.Bytes_WriteI64,
    WriteF32   = libphx.Bytes_WriteF32,
    WriteF64   = libphx.Bytes_WriteF64,
    Print      = libphx.Bytes_Print,
    Save       = libphx.Bytes_Save,
  }

  if onDef_Bytes then onDef_Bytes(Bytes, mt) end
  Bytes = setmetatable(Bytes, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Bytes')
  local mt = {
    __index = {
      managed    = function (self) return ffi.gc(self, libphx.Bytes_Free) end,
      free       = libphx.Bytes_Free,
      getData    = libphx.Bytes_GetData,
      getSize    = libphx.Bytes_GetSize,
      compress   = libphx.Bytes_Compress,
      decompress = libphx.Bytes_Decompress,
      getCursor  = libphx.Bytes_GetCursor,
      rewind     = libphx.Bytes_Rewind,
      setCursor  = libphx.Bytes_SetCursor,
      read       = libphx.Bytes_Read,
      readU8     = libphx.Bytes_ReadU8,
      readU16    = libphx.Bytes_ReadU16,
      readU32    = libphx.Bytes_ReadU32,
      readU64    = libphx.Bytes_ReadU64,
      readI8     = libphx.Bytes_ReadI8,
      readI16    = libphx.Bytes_ReadI16,
      readI32    = libphx.Bytes_ReadI32,
      readI64    = libphx.Bytes_ReadI64,
      readF32    = libphx.Bytes_ReadF32,
      readF64    = libphx.Bytes_ReadF64,
      write      = libphx.Bytes_Write,
      writeStr   = libphx.Bytes_WriteStr,
      writeU8    = libphx.Bytes_WriteU8,
      writeU16   = libphx.Bytes_WriteU16,
      writeU32   = libphx.Bytes_WriteU32,
      writeU64   = libphx.Bytes_WriteU64,
      writeI8    = libphx.Bytes_WriteI8,
      writeI16   = libphx.Bytes_WriteI16,
      writeI32   = libphx.Bytes_WriteI32,
      writeI64   = libphx.Bytes_WriteI64,
      writeF32   = libphx.Bytes_WriteF32,
      writeF64   = libphx.Bytes_WriteF64,
      print      = libphx.Bytes_Print,
      save       = libphx.Bytes_Save,
    },
  }

  if onDef_Bytes_t then onDef_Bytes_t(t, mt) end
  Bytes_t = ffi.metatype(t, mt)
end

return Bytes
