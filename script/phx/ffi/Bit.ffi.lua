-- Bit -------------------------------------------------------------------------
local Bit

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    uint32 Bit_And32 (uint32 x, uint32 y);
    uint32 Bit_Or32  (uint32 x, uint32 y);
    uint32 Bit_Xor32 (uint32 x, uint32 y);
    bool   Bit_Has32 (uint32 x, uint32 y);
    uint64 Bit_And64 (uint64 x, uint64 y);
    uint64 Bit_Or64  (uint64 x, uint64 y);
    uint64 Bit_Xor64 (uint64 x, uint64 y);
    bool   Bit_Has64 (uint64 x, uint64 y);
  ]]
end

do -- Global Symbol Table
  Bit = {
    And32 = libphx.Bit_And32,
    Or32  = libphx.Bit_Or32,
    Xor32 = libphx.Bit_Xor32,
    Has32 = libphx.Bit_Has32,
    And64 = libphx.Bit_And64,
    Or64  = libphx.Bit_Or64,
    Xor64 = libphx.Bit_Xor64,
    Has64 = libphx.Bit_Has64,
  }

  if onDef_Bit then onDef_Bit(Bit, mt) end
  Bit = setmetatable(Bit, mt)
end

return Bit
