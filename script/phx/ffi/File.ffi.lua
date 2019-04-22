-- File ------------------------------------------------------------------------
local File

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    File*  File_Create    (cstr path);
    File*  File_Open      (cstr path);
    void   File_Close     (File*);
    bool   File_Exists    (cstr path);
    bool   File_IsDir     (cstr path);
    Bytes* File_ReadBytes (cstr path);
    cstr   File_ReadCstr  (cstr path);
    int64  File_Size      (cstr path);
    void   File_Read      (File*, void* data, uint32 len);
    uint8  File_ReadU8    (File*);
    uint16 File_ReadU16   (File*);
    uint32 File_ReadU32   (File*);
    uint64 File_ReadU64   (File*);
    int8   File_ReadI8    (File*);
    int16  File_ReadI16   (File*);
    int32  File_ReadI32   (File*);
    int64  File_ReadI64   (File*);
    float  File_ReadF32   (File*);
    double File_ReadF64   (File*);
    void   File_Write     (File*, void const* data, uint32 len);
    void   File_WriteStr  (File*, cstr);
    void   File_WriteU8   (File*, uint8);
    void   File_WriteU16  (File*, uint16);
    void   File_WriteU32  (File*, uint32);
    void   File_WriteU64  (File*, uint64);
    void   File_WriteI8   (File*, int8);
    void   File_WriteI16  (File*, int16);
    void   File_WriteI32  (File*, int32);
    void   File_WriteI64  (File*, int64);
    void   File_WriteF32  (File*, float);
    void   File_WriteF64  (File*, double);
  ]]
end

do -- Global Symbol Table
  File = {
    Create    = libphx.File_Create,
    Open      = libphx.File_Open,
    Close     = libphx.File_Close,
    Exists    = libphx.File_Exists,
    IsDir     = libphx.File_IsDir,
    ReadBytes = libphx.File_ReadBytes,
    ReadCstr  = libphx.File_ReadCstr,
    Size      = libphx.File_Size,
    Read      = libphx.File_Read,
    ReadU8    = libphx.File_ReadU8,
    ReadU16   = libphx.File_ReadU16,
    ReadU32   = libphx.File_ReadU32,
    ReadU64   = libphx.File_ReadU64,
    ReadI8    = libphx.File_ReadI8,
    ReadI16   = libphx.File_ReadI16,
    ReadI32   = libphx.File_ReadI32,
    ReadI64   = libphx.File_ReadI64,
    ReadF32   = libphx.File_ReadF32,
    ReadF64   = libphx.File_ReadF64,
    Write     = libphx.File_Write,
    WriteStr  = libphx.File_WriteStr,
    WriteU8   = libphx.File_WriteU8,
    WriteU16  = libphx.File_WriteU16,
    WriteU32  = libphx.File_WriteU32,
    WriteU64  = libphx.File_WriteU64,
    WriteI8   = libphx.File_WriteI8,
    WriteI16  = libphx.File_WriteI16,
    WriteI32  = libphx.File_WriteI32,
    WriteI64  = libphx.File_WriteI64,
    WriteF32  = libphx.File_WriteF32,
    WriteF64  = libphx.File_WriteF64,
  }

  if onDef_File then onDef_File(File, mt) end
  File = setmetatable(File, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('File')
  local mt = {
    __index = {
      close     = libphx.File_Close,
      read      = libphx.File_Read,
      readU8    = libphx.File_ReadU8,
      readU16   = libphx.File_ReadU16,
      readU32   = libphx.File_ReadU32,
      readU64   = libphx.File_ReadU64,
      readI8    = libphx.File_ReadI8,
      readI16   = libphx.File_ReadI16,
      readI32   = libphx.File_ReadI32,
      readI64   = libphx.File_ReadI64,
      readF32   = libphx.File_ReadF32,
      readF64   = libphx.File_ReadF64,
      write     = libphx.File_Write,
      writeStr  = libphx.File_WriteStr,
      writeU8   = libphx.File_WriteU8,
      writeU16  = libphx.File_WriteU16,
      writeU32  = libphx.File_WriteU32,
      writeU64  = libphx.File_WriteU64,
      writeI8   = libphx.File_WriteI8,
      writeI16  = libphx.File_WriteI16,
      writeI32  = libphx.File_WriteI32,
      writeI64  = libphx.File_WriteI64,
      writeF32  = libphx.File_WriteF32,
      writeF64  = libphx.File_WriteF64,
    },
  }

  if onDef_File_t then onDef_File_t(t, mt) end
  File_t = ffi.metatype(t, mt)
end

return File
