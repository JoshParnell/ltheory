-- MemStack --------------------------------------------------------------------
local MemStack

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    MemStack* MemStack_Create       (uint32 capacity);
    void      MemStack_Free         (MemStack*);
    void*     MemStack_Alloc        (MemStack*, uint32 size);
    void      MemStack_Clear        (MemStack*);
    void      MemStack_Dealloc      (MemStack*, uint32 size);
    bool      MemStack_CanAlloc     (MemStack*, uint32 size);
    uint32    MemStack_GetSize      (MemStack*);
    uint32    MemStack_GetCapacity  (MemStack*);
    uint32    MemStack_GetRemaining (MemStack*);
  ]]
end

do -- Global Symbol Table
  MemStack = {
    Create       = libphx.MemStack_Create,
    Free         = libphx.MemStack_Free,
    Alloc        = libphx.MemStack_Alloc,
    Clear        = libphx.MemStack_Clear,
    Dealloc      = libphx.MemStack_Dealloc,
    CanAlloc     = libphx.MemStack_CanAlloc,
    GetSize      = libphx.MemStack_GetSize,
    GetCapacity  = libphx.MemStack_GetCapacity,
    GetRemaining = libphx.MemStack_GetRemaining,
  }

  if onDef_MemStack then onDef_MemStack(MemStack, mt) end
  MemStack = setmetatable(MemStack, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('MemStack')
  local mt = {
    __index = {
      managed      = function (self) return ffi.gc(self, libphx.MemStack_Free) end,
      free         = libphx.MemStack_Free,
      alloc        = libphx.MemStack_Alloc,
      clear        = libphx.MemStack_Clear,
      dealloc      = libphx.MemStack_Dealloc,
      canAlloc     = libphx.MemStack_CanAlloc,
      getSize      = libphx.MemStack_GetSize,
      getCapacity  = libphx.MemStack_GetCapacity,
      getRemaining = libphx.MemStack_GetRemaining,
    },
  }

  if onDef_MemStack_t then onDef_MemStack_t(t, mt) end
  MemStack_t = ffi.metatype(t, mt)
end

return MemStack
