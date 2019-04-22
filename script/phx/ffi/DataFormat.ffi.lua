-- DataFormat ------------------------------------------------------------------
local DataFormat

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    int        DataFormat_GetSize (DataFormat);
    DataFormat DataFormat_U8;
    DataFormat DataFormat_I8;
    DataFormat DataFormat_U16;
    DataFormat DataFormat_I16;
    DataFormat DataFormat_U32;
    DataFormat DataFormat_I32;
    DataFormat DataFormat_Float;
  ]]
end

do -- Global Symbol Table
  DataFormat = {
    U8    = libphx.DataFormat_U8,
    I8    = libphx.DataFormat_I8,
    U16   = libphx.DataFormat_U16,
    I16   = libphx.DataFormat_I16,
    U32   = libphx.DataFormat_U32,
    I32   = libphx.DataFormat_I32,
    Float = libphx.DataFormat_Float,
    GetSize = libphx.DataFormat_GetSize,
  }

  if onDef_DataFormat then onDef_DataFormat(DataFormat, mt) end
  DataFormat = setmetatable(DataFormat, mt)
end

return DataFormat
