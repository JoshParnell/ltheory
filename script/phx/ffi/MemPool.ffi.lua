-- MemPool ---------------------------------------------------------------------
local MemPool

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    MemPool* MemPool_Create      (uint32 cellSize, uint32 blockSize);
    MemPool* MemPool_CreateAuto  (uint32 elemSize);
    void     MemPool_Free        (MemPool*);
    void*    MemPool_Alloc       (MemPool*);
    void     MemPool_Clear       (MemPool*);
    void     MemPool_Dealloc     (MemPool*, void*);
    uint32   MemPool_GetCapacity (MemPool*);
    uint32   MemPool_GetSize     (MemPool*);
  ]]
end

do -- Global Symbol Table
  MemPool = {
    Create      = libphx.MemPool_Create,
    CreateAuto  = libphx.MemPool_CreateAuto,
    Free        = libphx.MemPool_Free,
    Alloc       = libphx.MemPool_Alloc,
    Clear       = libphx.MemPool_Clear,
    Dealloc     = libphx.MemPool_Dealloc,
    GetCapacity = libphx.MemPool_GetCapacity,
    GetSize     = libphx.MemPool_GetSize,
  }

  if onDef_MemPool then onDef_MemPool(MemPool, mt) end
  MemPool = setmetatable(MemPool, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('MemPool')
  local mt = {
    __index = {
      managed     = function (self) return ffi.gc(self, libphx.MemPool_Free) end,
      free        = libphx.MemPool_Free,
      alloc       = libphx.MemPool_Alloc,
      clear       = libphx.MemPool_Clear,
      dealloc     = libphx.MemPool_Dealloc,
      getCapacity = libphx.MemPool_GetCapacity,
      getSize     = libphx.MemPool_GetSize,
    },
  }

  if onDef_MemPool_t then onDef_MemPool_t(t, mt) end
  MemPool_t = ffi.metatype(t, mt)
end

return MemPool
