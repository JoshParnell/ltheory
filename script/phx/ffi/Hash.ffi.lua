-- Hash ------------------------------------------------------------------------
local Hash

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    uint32 Hash_FNV32             (void const* buf, int len);
    uint64 Hash_FNV64             (void const* buf, int len);
    uint32 Hash_FNVStr32          (cstr);
    uint64 Hash_FNVStr64          (cstr);
    uint64 Hash_FNV64_Init        ();
    uint64 Hash_FNV64_Incremental (uint64, void const* buf, int len);
    uint32 Hash_Murmur3           (void const* buf, int len);
    uint64 Hash_XX64              (void const* buf, int len, uint64 seed);
  ]]
end

do -- Global Symbol Table
  Hash = {
    FNV32             = libphx.Hash_FNV32,
    FNV64             = libphx.Hash_FNV64,
    FNVStr32          = libphx.Hash_FNVStr32,
    FNVStr64          = libphx.Hash_FNVStr64,
    FNV64_Init        = libphx.Hash_FNV64_Init,
    FNV64_Incremental = libphx.Hash_FNV64_Incremental,
    Murmur3           = libphx.Hash_Murmur3,
    XX64              = libphx.Hash_XX64,
  }

  if onDef_Hash then onDef_Hash(Hash, mt) end
  Hash = setmetatable(Hash, mt)
end

return Hash
