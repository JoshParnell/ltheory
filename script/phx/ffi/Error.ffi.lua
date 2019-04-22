-- Error -----------------------------------------------------------------------
local Error

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void Error_Print (Error);
  ]]
end

do -- Global Symbol Table
  Error = {
    None         = 0x00000000,
    Null         = 0x00000001,
    Invalid      = 0x00000002,
    Overflow     = 0x00000004,
    Underflow    = 0x00000008,
    Empty        = 0x00000010,
    NaN          = 0x00000020,
    Degenerate   = 0x00000040,
    BadCount     = 0x00000080,
    Input        = 0x00000100,
    Intermediate = 0x00000200,
    Output       = 0x00000400,
    Stack        = 0x00010000,
    Heap         = 0x00020000,
    Buffer       = 0x00040000,
    Path         = 0x00080000,
    Index        = 0x00100000,
    Vertex       = 0x00200000,
    VertPos      = 0x00400000,
    VertNorm     = 0x00800000,
    VertUV       = 0x01000000,
    Print = libphx.Error_Print,
  }

  if onDef_Error then onDef_Error(Error, mt) end
  Error = setmetatable(Error, mt)
end

return Error
