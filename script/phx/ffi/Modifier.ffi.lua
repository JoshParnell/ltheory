-- Modifier --------------------------------------------------------------------
local Modifier

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    cstr     Modifier_ToString (Modifier);
    Modifier Modifier_Null;
    Modifier Modifier_Alt;
    Modifier Modifier_Ctrl;
    Modifier Modifier_Shift;
  ]]
end

do -- Global Symbol Table
  Modifier = {
    Null  = libphx.Modifier_Null,
    Alt   = libphx.Modifier_Alt,
    Ctrl  = libphx.Modifier_Ctrl,
    Shift = libphx.Modifier_Shift,
    ToString = libphx.Modifier_ToString,
  }

  if onDef_Modifier then onDef_Modifier(Modifier, mt) end
  Modifier = setmetatable(Modifier, mt)
end

return Modifier
