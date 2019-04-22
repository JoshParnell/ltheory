-- Resource --------------------------------------------------------------------
local Resource

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void   Resource_AddPath   (ResourceType, cstr format);
    bool   Resource_Exists    (ResourceType, cstr name);
    cstr   Resource_GetPath   (ResourceType, cstr name);
    Bytes* Resource_LoadBytes (ResourceType, cstr name);
    cstr   Resource_LoadCstr  (ResourceType, cstr name);
  ]]
end

do -- Global Symbol Table
  Resource = {
    AddPath   = libphx.Resource_AddPath,
    Exists    = libphx.Resource_Exists,
    GetPath   = libphx.Resource_GetPath,
    LoadBytes = libphx.Resource_LoadBytes,
    LoadCstr  = libphx.Resource_LoadCstr,
  }

  if onDef_Resource then onDef_Resource(Resource, mt) end
  Resource = setmetatable(Resource, mt)
end

return Resource
