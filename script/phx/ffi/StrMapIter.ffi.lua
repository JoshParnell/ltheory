-- StrMapIter ------------------------------------------------------------------
local StrMapIter

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void  StrMapIter_Advance  (StrMapIter*);
    void  StrMapIter_Free     (StrMapIter*);
    bool  StrMapIter_HasMore  (StrMapIter*);
    cstr  StrMapIter_GetKey   (StrMapIter*);
    void* StrMapIter_GetValue (StrMapIter*);
  ]]
end

do -- Global Symbol Table
  StrMapIter = {
    Advance  = libphx.StrMapIter_Advance,
    Free     = libphx.StrMapIter_Free,
    HasMore  = libphx.StrMapIter_HasMore,
    GetKey   = libphx.StrMapIter_GetKey,
    GetValue = libphx.StrMapIter_GetValue,
  }

  if onDef_StrMapIter then onDef_StrMapIter(StrMapIter, mt) end
  StrMapIter = setmetatable(StrMapIter, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('StrMapIter')
  local mt = {
    __index = {
      managed  = function (self) return ffi.gc(self, libphx.StrMapIter_Free) end,
      advance  = libphx.StrMapIter_Advance,
      free     = libphx.StrMapIter_Free,
      hasMore  = libphx.StrMapIter_HasMore,
      getKey   = libphx.StrMapIter_GetKey,
      getValue = libphx.StrMapIter_GetValue,
    },
  }

  if onDef_StrMapIter_t then onDef_StrMapIter_t(t, mt) end
  StrMapIter_t = ffi.metatype(t, mt)
end

return StrMapIter
