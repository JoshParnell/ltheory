-- HashMap ---------------------------------------------------------------------
local HashMap

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    HashMap* HashMap_Create  (uint32 keySize, uint32 capacity);
    void     HashMap_Free    (HashMap*);
    void     HashMap_Foreach (HashMap*, ValueForeach, void* userData);
    void*    HashMap_Get     (HashMap*, void const* key);
    void*    HashMap_GetRaw  (HashMap*, uint64 keyHash);
    void     HashMap_Resize  (HashMap*, uint32 capacity);
    void     HashMap_Set     (HashMap*, void const* key, void* value);
    void     HashMap_SetRaw  (HashMap*, uint64 keyHash, void* value);
  ]]
end

do -- Global Symbol Table
  HashMap = {
    Create  = libphx.HashMap_Create,
    Free    = libphx.HashMap_Free,
    Foreach = libphx.HashMap_Foreach,
    Get     = libphx.HashMap_Get,
    GetRaw  = libphx.HashMap_GetRaw,
    Resize  = libphx.HashMap_Resize,
    Set     = libphx.HashMap_Set,
    SetRaw  = libphx.HashMap_SetRaw,
  }

  if onDef_HashMap then onDef_HashMap(HashMap, mt) end
  HashMap = setmetatable(HashMap, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('HashMap')
  local mt = {
    __index = {
      managed = function (self) return ffi.gc(self, libphx.HashMap_Free) end,
      free    = libphx.HashMap_Free,
      foreach = libphx.HashMap_Foreach,
      get     = libphx.HashMap_Get,
      getRaw  = libphx.HashMap_GetRaw,
      resize  = libphx.HashMap_Resize,
      set     = libphx.HashMap_Set,
      setRaw  = libphx.HashMap_SetRaw,
    },
  }

  if onDef_HashMap_t then onDef_HashMap_t(t, mt) end
  HashMap_t = ffi.metatype(t, mt)
end

return HashMap
