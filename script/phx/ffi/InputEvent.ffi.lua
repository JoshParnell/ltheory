-- InputEvent ------------------------------------------------------------------
local InputEvent

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    cstr InputEvent_ToString (InputEvent*);
  ]]
end

do -- Global Symbol Table
  InputEvent = {
    ToString = libphx.InputEvent_ToString,
  }

  local mt = {
    __call  = function (t, ...) return InputEvent_t(...) end,
  }

  if onDef_InputEvent then onDef_InputEvent(InputEvent, mt) end
  InputEvent = setmetatable(InputEvent, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('InputEvent')
  local mt = {
    __tostring = function (self) return ffi.string(libphx.InputEvent_ToString(self)) end,
    __index = {
      clone    = function (x) return InputEvent_t(x) end,
      toString = libphx.InputEvent_ToString,
    },
  }

  if onDef_InputEvent_t then onDef_InputEvent_t(t, mt) end
  InputEvent_t = ffi.metatype(t, mt)
end

return InputEvent
