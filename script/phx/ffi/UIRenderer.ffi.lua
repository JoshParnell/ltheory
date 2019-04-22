-- UIRenderer ------------------------------------------------------------------
local UIRenderer

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void UIRenderer_Begin      ();
    void UIRenderer_End        ();
    void UIRenderer_Draw       ();
    void UIRenderer_BeginLayer (float x, float y, float sx, float sy, bool clip);
    void UIRenderer_EndLayer   ();
    void UIRenderer_Image      (Tex2D*, float x, float y, float sx, float sy);
    void UIRenderer_Panel      (float x, float y, float sx, float sy, float r, float g, float b, float a, float bevel, float innerAlpha);
    void UIRenderer_Rect       (float x, float y, float sx, float sy, float r, float g, float b, float a, bool outline);
    void UIRenderer_Text       (Font* font, cstr text, float x, float y, float r, float g, float b, float a);
  ]]
end

do -- Global Symbol Table
  UIRenderer = {
    Begin      = libphx.UIRenderer_Begin,
    End        = libphx.UIRenderer_End,
    Draw       = libphx.UIRenderer_Draw,
    BeginLayer = libphx.UIRenderer_BeginLayer,
    EndLayer   = libphx.UIRenderer_EndLayer,
    Image      = libphx.UIRenderer_Image,
    Panel      = libphx.UIRenderer_Panel,
    Rect       = libphx.UIRenderer_Rect,
    Text       = libphx.UIRenderer_Text,
  }

  if onDef_UIRenderer then onDef_UIRenderer(UIRenderer, mt) end
  UIRenderer = setmetatable(UIRenderer, mt)
end

return UIRenderer
