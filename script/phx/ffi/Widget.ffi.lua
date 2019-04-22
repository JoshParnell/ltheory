-- Widget ----------------------------------------------------------------------
local Widget

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void    Widget_Free        (Widget*);
    void    Widget_Draw        (Widget*);
    void    Widget_Layout      (Widget*);
    void    Widget_Update      (Widget*, float dt);
    void    Widget_Add         (Widget* parent, Widget* child);
    void    Widget_SetMinSize  (Widget*, float sx, float sy);
    void    Widget_SetPos      (Widget*, float x, float y);
    void    Widget_SetSize     (Widget*, float sx, float sy);
    void    Widget_SetStretch  (Widget*, float stretchX, float stretchY);
    Widget* Widget_GetHead     (Widget*);
    Widget* Widget_GetTail     (Widget*);
    Widget* Widget_GetParent   (Widget*);
    Widget* Widget_GetNext     (Widget*);
    Widget* Widget_GetPrev     (Widget*);
    Widget* Widget_CreateBox   (float r, float g, float b, float a);
    Widget* Widget_CreateListH (float spacing);
    Widget* Widget_CreateListV (float spacing);
  ]]
end

do -- Global Symbol Table
  Widget = {
    Free        = libphx.Widget_Free,
    Draw        = libphx.Widget_Draw,
    Layout      = libphx.Widget_Layout,
    Update      = libphx.Widget_Update,
    Add         = libphx.Widget_Add,
    SetMinSize  = libphx.Widget_SetMinSize,
    SetPos      = libphx.Widget_SetPos,
    SetSize     = libphx.Widget_SetSize,
    SetStretch  = libphx.Widget_SetStretch,
    GetHead     = libphx.Widget_GetHead,
    GetTail     = libphx.Widget_GetTail,
    GetParent   = libphx.Widget_GetParent,
    GetNext     = libphx.Widget_GetNext,
    GetPrev     = libphx.Widget_GetPrev,
    CreateBox   = libphx.Widget_CreateBox,
    CreateListH = libphx.Widget_CreateListH,
    CreateListV = libphx.Widget_CreateListV,
  }

  if onDef_Widget then onDef_Widget(Widget, mt) end
  Widget = setmetatable(Widget, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Widget')
  local mt = {
    __index = {
      managed     = function (self) return ffi.gc(self, libphx.Widget_Free) end,
      free        = libphx.Widget_Free,
      draw        = libphx.Widget_Draw,
      layout      = libphx.Widget_Layout,
      update      = libphx.Widget_Update,
      add         = libphx.Widget_Add,
      setMinSize  = libphx.Widget_SetMinSize,
      setPos      = libphx.Widget_SetPos,
      setSize     = libphx.Widget_SetSize,
      setStretch  = libphx.Widget_SetStretch,
      getHead     = libphx.Widget_GetHead,
      getTail     = libphx.Widget_GetTail,
      getParent   = libphx.Widget_GetParent,
      getNext     = libphx.Widget_GetNext,
      getPrev     = libphx.Widget_GetPrev,
    },
  }

  if onDef_Widget_t then onDef_Widget_t(t, mt) end
  Widget_t = ffi.metatype(t, mt)
end

return Widget
