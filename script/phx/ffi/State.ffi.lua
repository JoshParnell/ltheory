-- State -----------------------------------------------------------------------
local State

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    cstr  State_ToString (State);
    State State_Null;
    State State_Changed;
    State State_Pressed;
    State State_Down;
    State State_Released;
  ]]
end

do -- Global Symbol Table
  State = {
    Null     = libphx.State_Null,
    Changed  = libphx.State_Changed,
    Pressed  = libphx.State_Pressed,
    Down     = libphx.State_Down,
    Released = libphx.State_Released,
    ToString = libphx.State_ToString,
  }

  if onDef_State then onDef_State(State, mt) end
  State = setmetatable(State, mt)
end

return State
