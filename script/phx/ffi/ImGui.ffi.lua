-- ImGui -----------------------------------------------------------------------
local ImGui

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void  ImGui_Begin              (float sx, float sy);
    void  ImGui_End                ();
    void  ImGui_Draw               ();
    void  ImGui_AlignCursor        (float sx, float sy, float alignX, float alignY);
    float ImGui_GetCursorX         ();
    float ImGui_GetCursorY         ();
    void  ImGui_PushCursor         ();
    void  ImGui_PopCursor          ();
    void  ImGui_SetCursor          (float x, float y);
    void  ImGui_SetCursorX         (float x);
    void  ImGui_SetCursorY         (float y);
    void  ImGui_Indent             ();
    void  ImGui_Undent             ();
    bool  ImGui_Button             (cstr label);
    bool  ImGui_ButtonEx           (cstr label, float sx, float sy);
    bool  ImGui_Checkbox           (bool value);
    void  ImGui_Divider            ();
    bool  ImGui_Selectable         (cstr label);
    void  ImGui_Tex2D              (Tex2D*);
    void  ImGui_Text               (cstr text);
    void  ImGui_TextColored        (cstr text, float r, float g, float b, float a);
    void  ImGui_TextEx             (Font* font, cstr text, float r, float g, float b, float a);
    void  ImGui_BeginGroupX        (float sy);
    void  ImGui_BeginGroupY        (float sx);
    void  ImGui_EndGroup           ();
    void  ImGui_BeginPanel         (float sx, float sy);
    void  ImGui_EndPanel           ();
    void  ImGui_BeginWindow        (cstr title, float sx, float sy);
    void  ImGui_EndWindow          ();
    void  ImGui_BeginScrollFrame   (float sx, float sy);
    void  ImGui_EndScrollFrame     ();
    void  ImGui_PushStyle          ();
    void  ImGui_PushStyleFont      (Font*);
    void  ImGui_PushStylePadding   (float px, float py);
    void  ImGui_PushStyleSpacing   (float sx, float sy);
    void  ImGui_PushStyleTextColor (float r, float g, float b, float a);
    void  ImGui_PopStyle           ();
    void  ImGui_SetFont            (Font*);
    void  ImGui_SetSpacing         (float sx, float sy);
    void  ImGui_SetNextWidth       (float sx);
    void  ImGui_SetNextHeight      (float sy);
  ]]
end

do -- Global Symbol Table
  ImGui = {
    Begin              = libphx.ImGui_Begin,
    End                = libphx.ImGui_End,
    Draw               = libphx.ImGui_Draw,
    AlignCursor        = libphx.ImGui_AlignCursor,
    GetCursorX         = libphx.ImGui_GetCursorX,
    GetCursorY         = libphx.ImGui_GetCursorY,
    PushCursor         = libphx.ImGui_PushCursor,
    PopCursor          = libphx.ImGui_PopCursor,
    SetCursor          = libphx.ImGui_SetCursor,
    SetCursorX         = libphx.ImGui_SetCursorX,
    SetCursorY         = libphx.ImGui_SetCursorY,
    Indent             = libphx.ImGui_Indent,
    Undent             = libphx.ImGui_Undent,
    Button             = libphx.ImGui_Button,
    ButtonEx           = libphx.ImGui_ButtonEx,
    Checkbox           = libphx.ImGui_Checkbox,
    Divider            = libphx.ImGui_Divider,
    Selectable         = libphx.ImGui_Selectable,
    Tex2D              = libphx.ImGui_Tex2D,
    Text               = libphx.ImGui_Text,
    TextColored        = libphx.ImGui_TextColored,
    TextEx             = libphx.ImGui_TextEx,
    BeginGroupX        = libphx.ImGui_BeginGroupX,
    BeginGroupY        = libphx.ImGui_BeginGroupY,
    EndGroup           = libphx.ImGui_EndGroup,
    BeginPanel         = libphx.ImGui_BeginPanel,
    EndPanel           = libphx.ImGui_EndPanel,
    BeginWindow        = libphx.ImGui_BeginWindow,
    EndWindow          = libphx.ImGui_EndWindow,
    BeginScrollFrame   = libphx.ImGui_BeginScrollFrame,
    EndScrollFrame     = libphx.ImGui_EndScrollFrame,
    PushStyle          = libphx.ImGui_PushStyle,
    PushStyleFont      = libphx.ImGui_PushStyleFont,
    PushStylePadding   = libphx.ImGui_PushStylePadding,
    PushStyleSpacing   = libphx.ImGui_PushStyleSpacing,
    PushStyleTextColor = libphx.ImGui_PushStyleTextColor,
    PopStyle           = libphx.ImGui_PopStyle,
    SetFont            = libphx.ImGui_SetFont,
    SetSpacing         = libphx.ImGui_SetSpacing,
    SetNextWidth       = libphx.ImGui_SetNextWidth,
    SetNextHeight      = libphx.ImGui_SetNextHeight,
  }

  if onDef_ImGui then onDef_ImGui(ImGui, mt) end
  ImGui = setmetatable(ImGui, mt)
end

return ImGui
