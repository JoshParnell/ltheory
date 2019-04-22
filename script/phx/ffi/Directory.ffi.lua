-- Directory -------------------------------------------------------------------
local Directory

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Directory* Directory_Open       (cstr path);
    void       Directory_Close      (Directory*);
    cstr       Directory_GetNext    (Directory*);
    bool       Directory_Change     (cstr cwd);
    bool       Directory_Create     (cstr path);
    cstr       Directory_GetCurrent ();
    bool       Directory_Remove     (cstr path);
  ]]
end

do -- Global Symbol Table
  Directory = {
    Open       = libphx.Directory_Open,
    Close      = libphx.Directory_Close,
    GetNext    = libphx.Directory_GetNext,
    Change     = libphx.Directory_Change,
    Create     = libphx.Directory_Create,
    GetCurrent = libphx.Directory_GetCurrent,
    Remove     = libphx.Directory_Remove,
  }

  if onDef_Directory then onDef_Directory(Directory, mt) end
  Directory = setmetatable(Directory, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Directory')
  local mt = {
    __index = {
      close      = libphx.Directory_Close,
      getNext    = libphx.Directory_GetNext,
    },
  }

  if onDef_Directory_t then onDef_Directory_t(t, mt) end
  Directory_t = ffi.metatype(t, mt)
end

return Directory
