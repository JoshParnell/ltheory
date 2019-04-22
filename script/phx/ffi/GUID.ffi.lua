-- GUID ------------------------------------------------------------------------
local GUID

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    uint64 GUID_Create ();
    bool   GUID_Exists (uint64);
    void   GUID_Reset  ();
  ]]
end

do -- Global Symbol Table
  GUID = {
    Create = libphx.GUID_Create,
    Exists = libphx.GUID_Exists,
    Reset  = libphx.GUID_Reset,
  }

  if onDef_GUID then onDef_GUID(GUID, mt) end
  GUID = setmetatable(GUID, mt)
end

return GUID
