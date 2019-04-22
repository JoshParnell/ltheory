-- DeviceType ------------------------------------------------------------------
local DeviceType

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    DeviceType DeviceType_FromButton (Button);
    cstr       DeviceType_ToString   (DeviceType);
    DeviceType DeviceType_Null;
    DeviceType DeviceType_Mouse;
    DeviceType DeviceType_Keyboard;
    DeviceType DeviceType_Gamepad;
  ]]
end

do -- Global Symbol Table
  DeviceType = {
    Null     = libphx.DeviceType_Null,
    Mouse    = libphx.DeviceType_Mouse,
    Keyboard = libphx.DeviceType_Keyboard,
    Gamepad  = libphx.DeviceType_Gamepad,
    COUNT    = 4,
    FromButton = libphx.DeviceType_FromButton,
    ToString   = libphx.DeviceType_ToString,
  }

  if onDef_DeviceType then onDef_DeviceType(DeviceType, mt) end
  DeviceType = setmetatable(DeviceType, mt)
end

return DeviceType
