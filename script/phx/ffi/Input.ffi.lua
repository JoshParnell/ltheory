-- Input -----------------------------------------------------------------------
local Input

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void       Input_LoadGamepadDatabase     (cstr filepath);
    bool       Input_GetPressed              (Button);
    bool       Input_GetDown                 (Button);
    bool       Input_GetReleased             (Button);
    float      Input_GetValue                (Button);
    float      Input_GetIdleTime             ();
    void       Input_GetActiveDevice         (Device*);
    DeviceType Input_GetActiveDeviceType     ();
    uint32     Input_GetActiveDeviceID       ();
    float      Input_GetActiveDeviceIdleTime ();
    bool       Input_GetDevicePressed        (Device*, Button);
    bool       Input_GetDeviceDown           (Device*, Button);
    bool       Input_GetDeviceReleased       (Device*, Button);
    float      Input_GetDeviceValue          (Device*, Button);
    float      Input_GetDeviceIdleTime       (Device*);
    void       Input_GetMouseDelta           (Vec2i*);
    float      Input_GetMouseIdleTime        ();
    void       Input_GetMousePosition        (Vec2i*);
    void       Input_GetMouseScroll          (Vec2i*);
    void       Input_SetMousePosition        (Vec2i*);
    void       Input_SetMouseScroll          (Vec2i*);
    void       Input_SetMouseVisible         (bool);
    void       Input_SetMouseVisibleAuto     ();
    float      Input_GetKeyboardIdleTime     ();
    bool       Input_GetKeyboardMod          (Modifier);
    bool       Input_GetKeyboardAlt          ();
    bool       Input_GetKeyboardCtrl         ();
    bool       Input_GetKeyboardShift        ();
    float      Input_GetGamepadIdleTime      (uint32 id);
    bool       Input_GetGamepadPressed       (uint32 id, Button);
    bool       Input_GetGamepadDown          (uint32 id, Button);
    bool       Input_GetGamepadReleased      (uint32 id, Button);
    float      Input_GetGamepadValue         (uint32 id, Button);
    int32      Input_GetEventCount           ();
    bool       Input_GetNextEvent            (InputEvent*);
  ]]
end

do -- Global Symbol Table
  Input = {
    LoadGamepadDatabase     = libphx.Input_LoadGamepadDatabase,
    GetPressed              = libphx.Input_GetPressed,
    GetDown                 = libphx.Input_GetDown,
    GetReleased             = libphx.Input_GetReleased,
    GetValue                = libphx.Input_GetValue,
    GetIdleTime             = libphx.Input_GetIdleTime,
    GetActiveDevice         = libphx.Input_GetActiveDevice,
    GetActiveDeviceType     = libphx.Input_GetActiveDeviceType,
    GetActiveDeviceID       = libphx.Input_GetActiveDeviceID,
    GetActiveDeviceIdleTime = libphx.Input_GetActiveDeviceIdleTime,
    GetDevicePressed        = libphx.Input_GetDevicePressed,
    GetDeviceDown           = libphx.Input_GetDeviceDown,
    GetDeviceReleased       = libphx.Input_GetDeviceReleased,
    GetDeviceValue          = libphx.Input_GetDeviceValue,
    GetDeviceIdleTime       = libphx.Input_GetDeviceIdleTime,
    GetMouseDelta           = libphx.Input_GetMouseDelta,
    GetMouseIdleTime        = libphx.Input_GetMouseIdleTime,
    GetMousePosition        = libphx.Input_GetMousePosition,
    GetMouseScroll          = libphx.Input_GetMouseScroll,
    SetMousePosition        = libphx.Input_SetMousePosition,
    SetMouseScroll          = libphx.Input_SetMouseScroll,
    SetMouseVisible         = libphx.Input_SetMouseVisible,
    SetMouseVisibleAuto     = libphx.Input_SetMouseVisibleAuto,
    GetKeyboardIdleTime     = libphx.Input_GetKeyboardIdleTime,
    GetKeyboardMod          = libphx.Input_GetKeyboardMod,
    GetKeyboardAlt          = libphx.Input_GetKeyboardAlt,
    GetKeyboardCtrl         = libphx.Input_GetKeyboardCtrl,
    GetKeyboardShift        = libphx.Input_GetKeyboardShift,
    GetGamepadIdleTime      = libphx.Input_GetGamepadIdleTime,
    GetGamepadPressed       = libphx.Input_GetGamepadPressed,
    GetGamepadDown          = libphx.Input_GetGamepadDown,
    GetGamepadReleased      = libphx.Input_GetGamepadReleased,
    GetGamepadValue         = libphx.Input_GetGamepadValue,
    GetEventCount           = libphx.Input_GetEventCount,
    GetNextEvent            = libphx.Input_GetNextEvent,
  }

  if onDef_Input then onDef_Input(Input, mt) end
  Input = setmetatable(Input, mt)
end

return Input
