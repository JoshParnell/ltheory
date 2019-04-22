-- WindowMode ------------------------------------------------------------------
local WindowMode

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    WindowMode WindowMode_AlwaysOnTop;
    WindowMode WindowMode_Borderless;
    WindowMode WindowMode_Fullscreen;
    WindowMode WindowMode_Hidden;
    WindowMode WindowMode_Maximized;
    WindowMode WindowMode_Minimized;
    WindowMode WindowMode_Resizable;
    WindowMode WindowMode_Shown;
  ]]
end

do -- Global Symbol Table
  WindowMode = {
    AlwaysOnTop = libphx.WindowMode_AlwaysOnTop,
    Borderless  = libphx.WindowMode_Borderless,
    Fullscreen  = libphx.WindowMode_Fullscreen,
    Hidden      = libphx.WindowMode_Hidden,
    Maximized   = libphx.WindowMode_Maximized,
    Minimized   = libphx.WindowMode_Minimized,
    Resizable   = libphx.WindowMode_Resizable,
    Shown       = libphx.WindowMode_Shown,
  }

  if onDef_WindowMode then onDef_WindowMode(WindowMode, mt) end
  WindowMode = setmetatable(WindowMode, mt)
end

return WindowMode
