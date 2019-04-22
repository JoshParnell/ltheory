-- WindowPos -------------------------------------------------------------------
local WindowPos

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    WindowPos WindowPos_Centered;
    WindowPos WindowPos_Default;
  ]]
end

do -- Global Symbol Table
  WindowPos = {
    Centered = libphx.WindowPos_Centered,
    Default  = libphx.WindowPos_Default,
  }

  if onDef_WindowPos then onDef_WindowPos(WindowPos, mt) end
  WindowPos = setmetatable(WindowPos, mt)
end

return WindowPos
