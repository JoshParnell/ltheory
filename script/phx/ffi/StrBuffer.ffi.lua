-- StrBuffer -------------------------------------------------------------------
local StrBuffer

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    StrBuffer* StrBuffer_Create    (uint32 capacity);
    StrBuffer* StrBuffer_FromStr   (cstr);
    void       StrBuffer_Free      (StrBuffer*);
    void       StrBuffer_Append    (StrBuffer*, StrBuffer*);
    void       StrBuffer_AppendStr (StrBuffer*, cstr);
    void       StrBuffer_Set       (StrBuffer*, cstr format, ...);
    StrBuffer* StrBuffer_Clone     (StrBuffer*);
    cstr       StrBuffer_GetData   (StrBuffer*);
  ]]
end

do -- Global Symbol Table
  StrBuffer = {
    Create    = libphx.StrBuffer_Create,
    FromStr   = libphx.StrBuffer_FromStr,
    Free      = libphx.StrBuffer_Free,
    Append    = libphx.StrBuffer_Append,
    AppendStr = libphx.StrBuffer_AppendStr,
    Set       = libphx.StrBuffer_Set,
    Clone     = libphx.StrBuffer_Clone,
    GetData   = libphx.StrBuffer_GetData,
  }

  if onDef_StrBuffer then onDef_StrBuffer(StrBuffer, mt) end
  StrBuffer = setmetatable(StrBuffer, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('StrBuffer')
  local mt = {
    __index = {
      managed   = function (self) return ffi.gc(self, libphx.StrBuffer_Free) end,
      free      = libphx.StrBuffer_Free,
      append    = libphx.StrBuffer_Append,
      appendStr = libphx.StrBuffer_AppendStr,
      set       = libphx.StrBuffer_Set,
      clone     = libphx.StrBuffer_Clone,
      getData   = libphx.StrBuffer_GetData,
    },
  }

  if onDef_StrBuffer_t then onDef_StrBuffer_t(t, mt) end
  StrBuffer_t = ffi.metatype(t, mt)
end

return StrBuffer
