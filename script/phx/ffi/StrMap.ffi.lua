-- StrMap ----------------------------------------------------------------------
local StrMap

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    StrMap*     StrMap_Create  (uint32 initCapacity);
    void        StrMap_Free    (StrMap*);
    void        StrMap_FreeEx  (StrMap*, void (*freeFn)(cstr key, void* value));
    void*       StrMap_Get     (StrMap*, cstr key);
    uint32      StrMap_GetSize (StrMap*);
    void        StrMap_Remove  (StrMap*, cstr key);
    void        StrMap_Set     (StrMap*, cstr key, void* val);
    void        StrMap_Dump    (StrMap*);
    StrMapIter* StrMap_Iterate (StrMap*);
  ]]
end

do -- Global Symbol Table
  StrMap = {
    Create  = libphx.StrMap_Create,
    Free    = libphx.StrMap_Free,
    FreeEx  = libphx.StrMap_FreeEx,
    Get     = libphx.StrMap_Get,
    GetSize = libphx.StrMap_GetSize,
    Remove  = libphx.StrMap_Remove,
    Set     = libphx.StrMap_Set,
    Dump    = libphx.StrMap_Dump,
    Iterate = libphx.StrMap_Iterate,
  }

  if onDef_StrMap then onDef_StrMap(StrMap, mt) end
  StrMap = setmetatable(StrMap, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('StrMap')
  local mt = {
    __index = {
      managed = function (self) return ffi.gc(self, libphx.StrMap_Free) end,
      free    = libphx.StrMap_Free,
      freeEx  = libphx.StrMap_FreeEx,
      get     = libphx.StrMap_Get,
      getSize = libphx.StrMap_GetSize,
      remove  = libphx.StrMap_Remove,
      set     = libphx.StrMap_Set,
      dump    = libphx.StrMap_Dump,
      iterate = libphx.StrMap_Iterate,
    },
  }

  if onDef_StrMap_t then onDef_StrMap_t(t, mt) end
  StrMap_t = ffi.metatype(t, mt)
end

return StrMap
