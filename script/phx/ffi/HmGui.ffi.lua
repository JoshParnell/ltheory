-- HmGui -----------------------------------------------------------------------
local HmGui

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void  HmGui_Begin            (float sx, float sy);
    void  HmGui_End              ();
    void  HmGui_Draw             ();
    void  HmGui_BeginGroupX      ();
    void  HmGui_BeginGroupY      ();
    void  HmGui_BeginGroupStack  ();
    void  HmGui_EndGroup         ();
    void  HmGui_BeginScroll      (float maxSize);
    void  HmGui_EndScroll        ();
    void  HmGui_BeginWindow      (cstr title);
    void  HmGui_EndWindow        ();
    bool  HmGui_Button           (cstr);
    bool  HmGui_Checkbox         (cstr label, bool value);
    float HmGui_Slider           (float lower, float upper, float value);
    void  HmGui_Rect             (float sx, float sy, float r, float g, float b, float a);
    void  HmGui_Image            (Tex2D*);
    void  HmGui_Text             (cstr text);
    void  HmGui_TextColored      (cstr text, float r, float g, float b, float a);
    void  HmGui_TextEx           (Font* font, cstr text, float r, float g, float b, float a);
    void  HmGui_SetAlign         (float ax, float ay);
    void  HmGui_SetPadding       (float px, float py);
    void  HmGui_SetPaddingEx     (float left, float top, float right, float bottom);
    void  HmGui_SetPaddingLeft   (float);
    void  HmGui_SetPaddingTop    (float);
    void  HmGui_SetPaddingRight  (float);
    void  HmGui_SetPaddingBottom (float);
    void  HmGui_SetSpacing       (float);
    void  HmGui_SetStretch       (float x, float y);
    bool  HmGui_GroupHasFocus    (int type);
    void  HmGui_PushStyle        ();
    void  HmGui_PushFont         (Font*);
    void  HmGui_PushTextColor    (float r, float g, float b, float a);
    void  HmGui_PopStyle         (int depth);
  ]]
end

do -- Global Symbol Table
  HmGui = {
    Begin            = libphx.HmGui_Begin,
    End              = libphx.HmGui_End,
    Draw             = libphx.HmGui_Draw,
    BeginGroupX      = libphx.HmGui_BeginGroupX,
    BeginGroupY      = libphx.HmGui_BeginGroupY,
    BeginGroupStack  = libphx.HmGui_BeginGroupStack,
    EndGroup         = libphx.HmGui_EndGroup,
    BeginScroll      = libphx.HmGui_BeginScroll,
    EndScroll        = libphx.HmGui_EndScroll,
    BeginWindow      = libphx.HmGui_BeginWindow,
    EndWindow        = libphx.HmGui_EndWindow,
    Button           = libphx.HmGui_Button,
    Checkbox         = libphx.HmGui_Checkbox,
    Slider           = libphx.HmGui_Slider,
    Rect             = libphx.HmGui_Rect,
    Image            = libphx.HmGui_Image,
    Text             = libphx.HmGui_Text,
    TextColored      = libphx.HmGui_TextColored,
    TextEx           = libphx.HmGui_TextEx,
    SetAlign         = libphx.HmGui_SetAlign,
    SetPadding       = libphx.HmGui_SetPadding,
    SetPaddingEx     = libphx.HmGui_SetPaddingEx,
    SetPaddingLeft   = libphx.HmGui_SetPaddingLeft,
    SetPaddingTop    = libphx.HmGui_SetPaddingTop,
    SetPaddingRight  = libphx.HmGui_SetPaddingRight,
    SetPaddingBottom = libphx.HmGui_SetPaddingBottom,
    SetSpacing       = libphx.HmGui_SetSpacing,
    SetStretch       = libphx.HmGui_SetStretch,
    GroupHasFocus    = libphx.HmGui_GroupHasFocus,
    PushStyle        = libphx.HmGui_PushStyle,
    PushFont         = libphx.HmGui_PushFont,
    PushTextColor    = libphx.HmGui_PushTextColor,
    PopStyle         = libphx.HmGui_PopStyle,
  }

  if onDef_HmGui then onDef_HmGui(HmGui, mt) end
  HmGui = setmetatable(HmGui, mt)
end

return HmGui
