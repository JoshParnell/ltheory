-- Button ----------------------------------------------------------------------
local Button

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    DeviceType Button_ToDeviceType         (Button);
    cstr       Button_ToString             (Button);
    Button     Button_Null;
    Button     Button_First;
    Button     Button_Keyboard_First;
    Button     Button_Keyboard_A;
    Button     Button_Keyboard_B;
    Button     Button_Keyboard_C;
    Button     Button_Keyboard_D;
    Button     Button_Keyboard_E;
    Button     Button_Keyboard_F;
    Button     Button_Keyboard_G;
    Button     Button_Keyboard_H;
    Button     Button_Keyboard_I;
    Button     Button_Keyboard_J;
    Button     Button_Keyboard_K;
    Button     Button_Keyboard_L;
    Button     Button_Keyboard_M;
    Button     Button_Keyboard_N;
    Button     Button_Keyboard_O;
    Button     Button_Keyboard_P;
    Button     Button_Keyboard_Q;
    Button     Button_Keyboard_R;
    Button     Button_Keyboard_S;
    Button     Button_Keyboard_T;
    Button     Button_Keyboard_U;
    Button     Button_Keyboard_V;
    Button     Button_Keyboard_W;
    Button     Button_Keyboard_X;
    Button     Button_Keyboard_Y;
    Button     Button_Keyboard_Z;
    Button     Button_Keyboard_N0;
    Button     Button_Keyboard_N1;
    Button     Button_Keyboard_N2;
    Button     Button_Keyboard_N3;
    Button     Button_Keyboard_N4;
    Button     Button_Keyboard_N5;
    Button     Button_Keyboard_N6;
    Button     Button_Keyboard_N7;
    Button     Button_Keyboard_N8;
    Button     Button_Keyboard_N9;
    Button     Button_Keyboard_F1;
    Button     Button_Keyboard_F2;
    Button     Button_Keyboard_F3;
    Button     Button_Keyboard_F4;
    Button     Button_Keyboard_F5;
    Button     Button_Keyboard_F6;
    Button     Button_Keyboard_F7;
    Button     Button_Keyboard_F8;
    Button     Button_Keyboard_F9;
    Button     Button_Keyboard_F10;
    Button     Button_Keyboard_F11;
    Button     Button_Keyboard_F12;
    Button     Button_Keyboard_F13;
    Button     Button_Keyboard_F14;
    Button     Button_Keyboard_F15;
    Button     Button_Keyboard_F16;
    Button     Button_Keyboard_F17;
    Button     Button_Keyboard_F18;
    Button     Button_Keyboard_F19;
    Button     Button_Keyboard_F20;
    Button     Button_Keyboard_F21;
    Button     Button_Keyboard_F22;
    Button     Button_Keyboard_F23;
    Button     Button_Keyboard_F24;
    Button     Button_Keyboard_KP0;
    Button     Button_Keyboard_KP1;
    Button     Button_Keyboard_KP2;
    Button     Button_Keyboard_KP3;
    Button     Button_Keyboard_KP4;
    Button     Button_Keyboard_KP5;
    Button     Button_Keyboard_KP6;
    Button     Button_Keyboard_KP7;
    Button     Button_Keyboard_KP8;
    Button     Button_Keyboard_KP9;
    Button     Button_Keyboard_KPNumLock;
    Button     Button_Keyboard_KPDivide;
    Button     Button_Keyboard_KPMultiply;
    Button     Button_Keyboard_KPSubtract;
    Button     Button_Keyboard_KPAdd;
    Button     Button_Keyboard_KPEnter;
    Button     Button_Keyboard_KPDecimal;
    Button     Button_Keyboard_Backspace;
    Button     Button_Keyboard_Escape;
    Button     Button_Keyboard_Return;
    Button     Button_Keyboard_Space;
    Button     Button_Keyboard_Tab;
    Button     Button_Keyboard_Backtick;
    Button     Button_Keyboard_CapsLock;
    Button     Button_Keyboard_Minus;
    Button     Button_Keyboard_Equals;
    Button     Button_Keyboard_LBracket;
    Button     Button_Keyboard_RBracket;
    Button     Button_Keyboard_Backslash;
    Button     Button_Keyboard_Semicolon;
    Button     Button_Keyboard_Apostrophe;
    Button     Button_Keyboard_Comma;
    Button     Button_Keyboard_Period;
    Button     Button_Keyboard_Slash;
    Button     Button_Keyboard_PrintScreen;
    Button     Button_Keyboard_ScrollLock;
    Button     Button_Keyboard_Pause;
    Button     Button_Keyboard_Insert;
    Button     Button_Keyboard_Delete;
    Button     Button_Keyboard_Home;
    Button     Button_Keyboard_End;
    Button     Button_Keyboard_PageUp;
    Button     Button_Keyboard_PageDown;
    Button     Button_Keyboard_Right;
    Button     Button_Keyboard_Left;
    Button     Button_Keyboard_Down;
    Button     Button_Keyboard_Up;
    Button     Button_Keyboard_LCtrl;
    Button     Button_Keyboard_LShift;
    Button     Button_Keyboard_LAlt;
    Button     Button_Keyboard_LMeta;
    Button     Button_Keyboard_RCtrl;
    Button     Button_Keyboard_RShift;
    Button     Button_Keyboard_RAlt;
    Button     Button_Keyboard_RMeta;
    Button     Button_Keyboard_Last;
    Button     Button_Mouse_First;
    Button     Button_Mouse_Left;
    Button     Button_Mouse_Middle;
    Button     Button_Mouse_Right;
    Button     Button_Mouse_X1;
    Button     Button_Mouse_X2;
    Button     Button_Mouse_X;
    Button     Button_Mouse_Y;
    Button     Button_Mouse_ScrollX;
    Button     Button_Mouse_ScrollY;
    Button     Button_Mouse_Last;
    Button     Button_Gamepad_First;
    Button     Button_Gamepad_Button_First;
    Button     Button_Gamepad_A;
    Button     Button_Gamepad_B;
    Button     Button_Gamepad_X;
    Button     Button_Gamepad_Y;
    Button     Button_Gamepad_Back;
    Button     Button_Gamepad_Guide;
    Button     Button_Gamepad_Start;
    Button     Button_Gamepad_LStick;
    Button     Button_Gamepad_RStick;
    Button     Button_Gamepad_LBumper;
    Button     Button_Gamepad_RBumper;
    Button     Button_Gamepad_Up;
    Button     Button_Gamepad_Down;
    Button     Button_Gamepad_Left;
    Button     Button_Gamepad_Right;
    Button     Button_Gamepad_Button_Last;
    Button     Button_Gamepad_Axis_First;
    Button     Button_Gamepad_LTrigger;
    Button     Button_Gamepad_RTrigger;
    Button     Button_Gamepad_LStickX;
    Button     Button_Gamepad_LStickY;
    Button     Button_Gamepad_RStickX;
    Button     Button_Gamepad_RStickY;
    Button     Button_Gamepad_Axis_Last;
    Button     Button_Gamepad_Last;
    Button     Button_System_First;
    Button     Button_System_Exit;
    Button     Button_System_Last;
    Button     Button_Last;
  ]]
end

do -- Global Symbol Table
  Button = {
    Null  = libphx.Button_Null,
    First = libphx.Button_First,
    Last  = libphx.Button_Last,
    Keyboard = {
      First       = libphx.Button_Keyboard_First,
      A           = libphx.Button_Keyboard_A,
      B           = libphx.Button_Keyboard_B,
      C           = libphx.Button_Keyboard_C,
      D           = libphx.Button_Keyboard_D,
      E           = libphx.Button_Keyboard_E,
      F           = libphx.Button_Keyboard_F,
      G           = libphx.Button_Keyboard_G,
      H           = libphx.Button_Keyboard_H,
      I           = libphx.Button_Keyboard_I,
      J           = libphx.Button_Keyboard_J,
      K           = libphx.Button_Keyboard_K,
      L           = libphx.Button_Keyboard_L,
      M           = libphx.Button_Keyboard_M,
      N           = libphx.Button_Keyboard_N,
      O           = libphx.Button_Keyboard_O,
      P           = libphx.Button_Keyboard_P,
      Q           = libphx.Button_Keyboard_Q,
      R           = libphx.Button_Keyboard_R,
      S           = libphx.Button_Keyboard_S,
      T           = libphx.Button_Keyboard_T,
      U           = libphx.Button_Keyboard_U,
      V           = libphx.Button_Keyboard_V,
      W           = libphx.Button_Keyboard_W,
      X           = libphx.Button_Keyboard_X,
      Y           = libphx.Button_Keyboard_Y,
      Z           = libphx.Button_Keyboard_Z,
      N0          = libphx.Button_Keyboard_N0,
      N1          = libphx.Button_Keyboard_N1,
      N2          = libphx.Button_Keyboard_N2,
      N3          = libphx.Button_Keyboard_N3,
      N4          = libphx.Button_Keyboard_N4,
      N5          = libphx.Button_Keyboard_N5,
      N6          = libphx.Button_Keyboard_N6,
      N7          = libphx.Button_Keyboard_N7,
      N8          = libphx.Button_Keyboard_N8,
      N9          = libphx.Button_Keyboard_N9,
      F1          = libphx.Button_Keyboard_F1,
      F2          = libphx.Button_Keyboard_F2,
      F3          = libphx.Button_Keyboard_F3,
      F4          = libphx.Button_Keyboard_F4,
      F5          = libphx.Button_Keyboard_F5,
      F6          = libphx.Button_Keyboard_F6,
      F7          = libphx.Button_Keyboard_F7,
      F8          = libphx.Button_Keyboard_F8,
      F9          = libphx.Button_Keyboard_F9,
      F10         = libphx.Button_Keyboard_F10,
      F11         = libphx.Button_Keyboard_F11,
      F12         = libphx.Button_Keyboard_F12,
      F13         = libphx.Button_Keyboard_F13,
      F14         = libphx.Button_Keyboard_F14,
      F15         = libphx.Button_Keyboard_F15,
      F16         = libphx.Button_Keyboard_F16,
      F17         = libphx.Button_Keyboard_F17,
      F18         = libphx.Button_Keyboard_F18,
      F19         = libphx.Button_Keyboard_F19,
      F20         = libphx.Button_Keyboard_F20,
      F21         = libphx.Button_Keyboard_F21,
      F22         = libphx.Button_Keyboard_F22,
      F23         = libphx.Button_Keyboard_F23,
      F24         = libphx.Button_Keyboard_F24,
      KP0         = libphx.Button_Keyboard_KP0,
      KP1         = libphx.Button_Keyboard_KP1,
      KP2         = libphx.Button_Keyboard_KP2,
      KP3         = libphx.Button_Keyboard_KP3,
      KP4         = libphx.Button_Keyboard_KP4,
      KP5         = libphx.Button_Keyboard_KP5,
      KP6         = libphx.Button_Keyboard_KP6,
      KP7         = libphx.Button_Keyboard_KP7,
      KP8         = libphx.Button_Keyboard_KP8,
      KP9         = libphx.Button_Keyboard_KP9,
      KPNumLock   = libphx.Button_Keyboard_KPNumLock,
      KPDivide    = libphx.Button_Keyboard_KPDivide,
      KPMultiply  = libphx.Button_Keyboard_KPMultiply,
      KPSubtract  = libphx.Button_Keyboard_KPSubtract,
      KPAdd       = libphx.Button_Keyboard_KPAdd,
      KPEnter     = libphx.Button_Keyboard_KPEnter,
      KPDecimal   = libphx.Button_Keyboard_KPDecimal,
      Backspace   = libphx.Button_Keyboard_Backspace,
      Escape      = libphx.Button_Keyboard_Escape,
      Return      = libphx.Button_Keyboard_Return,
      Space       = libphx.Button_Keyboard_Space,
      Tab         = libphx.Button_Keyboard_Tab,
      Backtick    = libphx.Button_Keyboard_Backtick,
      CapsLock    = libphx.Button_Keyboard_CapsLock,
      Minus       = libphx.Button_Keyboard_Minus,
      Equals      = libphx.Button_Keyboard_Equals,
      LBracket    = libphx.Button_Keyboard_LBracket,
      RBracket    = libphx.Button_Keyboard_RBracket,
      Backslash   = libphx.Button_Keyboard_Backslash,
      Semicolon   = libphx.Button_Keyboard_Semicolon,
      Apostrophe  = libphx.Button_Keyboard_Apostrophe,
      Comma       = libphx.Button_Keyboard_Comma,
      Period      = libphx.Button_Keyboard_Period,
      Slash       = libphx.Button_Keyboard_Slash,
      PrintScreen = libphx.Button_Keyboard_PrintScreen,
      ScrollLock  = libphx.Button_Keyboard_ScrollLock,
      Pause       = libphx.Button_Keyboard_Pause,
      Insert      = libphx.Button_Keyboard_Insert,
      Delete      = libphx.Button_Keyboard_Delete,
      Home        = libphx.Button_Keyboard_Home,
      End         = libphx.Button_Keyboard_End,
      PageUp      = libphx.Button_Keyboard_PageUp,
      PageDown    = libphx.Button_Keyboard_PageDown,
      Right       = libphx.Button_Keyboard_Right,
      Left        = libphx.Button_Keyboard_Left,
      Down        = libphx.Button_Keyboard_Down,
      Up          = libphx.Button_Keyboard_Up,
      LCtrl       = libphx.Button_Keyboard_LCtrl,
      LShift      = libphx.Button_Keyboard_LShift,
      LAlt        = libphx.Button_Keyboard_LAlt,
      LMeta       = libphx.Button_Keyboard_LMeta,
      RCtrl       = libphx.Button_Keyboard_RCtrl,
      RShift      = libphx.Button_Keyboard_RShift,
      RAlt        = libphx.Button_Keyboard_RAlt,
      RMeta       = libphx.Button_Keyboard_RMeta,
      Last        = libphx.Button_Keyboard_Last,
    },
    Mouse = {
      First   = libphx.Button_Mouse_First,
      Left    = libphx.Button_Mouse_Left,
      Middle  = libphx.Button_Mouse_Middle,
      Right   = libphx.Button_Mouse_Right,
      X1      = libphx.Button_Mouse_X1,
      X2      = libphx.Button_Mouse_X2,
      X       = libphx.Button_Mouse_X,
      Y       = libphx.Button_Mouse_Y,
      ScrollX = libphx.Button_Mouse_ScrollX,
      ScrollY = libphx.Button_Mouse_ScrollY,
      Last    = libphx.Button_Mouse_Last,
    },
    Gamepad = {
      First        = libphx.Button_Gamepad_First,
      Button_First = libphx.Button_Gamepad_Button_First,
      A            = libphx.Button_Gamepad_A,
      B            = libphx.Button_Gamepad_B,
      X            = libphx.Button_Gamepad_X,
      Y            = libphx.Button_Gamepad_Y,
      Back         = libphx.Button_Gamepad_Back,
      Guide        = libphx.Button_Gamepad_Guide,
      Start        = libphx.Button_Gamepad_Start,
      LStick       = libphx.Button_Gamepad_LStick,
      RStick       = libphx.Button_Gamepad_RStick,
      LBumper      = libphx.Button_Gamepad_LBumper,
      RBumper      = libphx.Button_Gamepad_RBumper,
      Up           = libphx.Button_Gamepad_Up,
      Down         = libphx.Button_Gamepad_Down,
      Left         = libphx.Button_Gamepad_Left,
      Right        = libphx.Button_Gamepad_Right,
      Button_Last  = libphx.Button_Gamepad_Button_Last,
      Axis_First   = libphx.Button_Gamepad_Axis_First,
      LTrigger     = libphx.Button_Gamepad_LTrigger,
      RTrigger     = libphx.Button_Gamepad_RTrigger,
      LStickX      = libphx.Button_Gamepad_LStickX,
      LStickY      = libphx.Button_Gamepad_LStickY,
      RStickX      = libphx.Button_Gamepad_RStickX,
      RStickY      = libphx.Button_Gamepad_RStickY,
      Axis_Last    = libphx.Button_Gamepad_Axis_Last,
      Last         = libphx.Button_Gamepad_Last,
    },
    System = {
      First = libphx.Button_System_First,
      Exit  = libphx.Button_System_Exit,
      Last  = libphx.Button_System_Last,
    },
    ToDeviceType = libphx.Button_ToDeviceType,
    ToString     = libphx.Button_ToString,
  }

  if onDef_Button then onDef_Button(Button, mt) end
  Button = setmetatable(Button, mt)
end

return Button
