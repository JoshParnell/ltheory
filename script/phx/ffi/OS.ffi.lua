-- OS --------------------------------------------------------------------------
local OS

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    cstr OS_GetClipboard   ();
    int  OS_GetCPUCount    ();
    cstr OS_GetVideoDriver ();
    void OS_SetClipboard   (cstr text);
  ]]
end

do -- Global Symbol Table
  OS = {
    GetClipboard   = libphx.OS_GetClipboard,
    GetCPUCount    = libphx.OS_GetCPUCount,
    GetVideoDriver = libphx.OS_GetVideoDriver,
    SetClipboard   = libphx.OS_SetClipboard,
  }

  if onDef_OS then onDef_OS(OS, mt) end
  OS = setmetatable(OS, mt)
end

return OS
