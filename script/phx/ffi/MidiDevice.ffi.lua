-- MidiDevice ------------------------------------------------------------------
local MidiDevice

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    int         MidiDevice_GetCount       ();
    MidiDevice* MidiDevice_Open           (int index);
    void        MidiDevice_Close          (MidiDevice*);
    cstr        MidiDevice_GetNameByIndex (int index);
    bool        MidiDevice_HasMessage     (MidiDevice*);
    Vec2i       MidiDevice_PopMessage     (MidiDevice*);
  ]]
end

do -- Global Symbol Table
  MidiDevice = {
    GetCount       = libphx.MidiDevice_GetCount,
    Open           = libphx.MidiDevice_Open,
    Close          = libphx.MidiDevice_Close,
    GetNameByIndex = libphx.MidiDevice_GetNameByIndex,
    HasMessage     = libphx.MidiDevice_HasMessage,
    PopMessage     = libphx.MidiDevice_PopMessage,
  }

  if onDef_MidiDevice then onDef_MidiDevice(MidiDevice, mt) end
  MidiDevice = setmetatable(MidiDevice, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('MidiDevice')
  local mt = {
    __index = {
      close          = libphx.MidiDevice_Close,
      hasMessage     = libphx.MidiDevice_HasMessage,
      popMessage     = libphx.MidiDevice_PopMessage,
    },
  }

  if onDef_MidiDevice_t then onDef_MidiDevice_t(t, mt) end
  MidiDevice_t = ffi.metatype(t, mt)
end

return MidiDevice
