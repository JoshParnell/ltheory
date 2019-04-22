-- Memory ----------------------------------------------------------------------
local Memory

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void* Memory_Alloc   (size_t);
    void* Memory_Calloc  (size_t n, size_t size);
    void  Memory_Free    (void* ptr);
    void  Memory_MemCopy (void* dst, void const* src, size_t size);
    void  Memory_MemMove (void* dst, void const* src, size_t size);
    void* Memory_Realloc (void* ptr, size_t newSize);
  ]]
end

do -- Global Symbol Table
  Memory = {
    Alloc   = libphx.Memory_Alloc,
    Calloc  = libphx.Memory_Calloc,
    Free    = libphx.Memory_Free,
    MemCopy = libphx.Memory_MemCopy,
    MemMove = libphx.Memory_MemMove,
    Realloc = libphx.Memory_Realloc,
  }

  if onDef_Memory then onDef_Memory(Memory, mt) end
  Memory = setmetatable(Memory, mt)
end

return Memory
