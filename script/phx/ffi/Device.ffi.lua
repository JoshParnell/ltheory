-- Device ----------------------------------------------------------------------
local Device

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    bool Device_Equal    (Device*, Device*);
    cstr Device_ToString (Device*);
  ]]
end

do -- Global Symbol Table
  Device = {
    Equal    = libphx.Device_Equal,
    ToString = libphx.Device_ToString,
  }

  local mt = {
    __call  = function (t, ...) return Device_t(...) end,
  }

  if onDef_Device then onDef_Device(Device, mt) end
  Device = setmetatable(Device, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Device')
  local mt = {
    __tostring = function (self) return ffi.string(libphx.Device_ToString(self)) end,
    __index = {
      clone    = function (x) return Device_t(x) end,
      equal    = libphx.Device_Equal,
      toString = libphx.Device_ToString,
    },
  }

  if onDef_Device_t then onDef_Device_t(t, mt) end
  Device_t = ffi.metatype(t, mt)
end

return Device
