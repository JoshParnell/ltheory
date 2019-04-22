-- Window ----------------------------------------------------------------------
local Window

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Window* Window_Create           (cstr title, WindowPos x, WindowPos y, int sx, int sy, WindowMode mode);
    void    Window_Free             (Window*);
    void    Window_BeginDraw        (Window*);
    void    Window_EndDraw          (Window*);
    void    Window_GetPosition      (Window*, Vec2i* out);
    void    Window_GetSize          (Window*, Vec2i* out);
    cstr    Window_GetTitle         (Window*);
    void    Window_SetFullscreen    (Window*, bool);
    void    Window_SetPosition      (Window*, WindowPos, WindowPos);
    void    Window_SetSize          (Window*, int, int);
    void    Window_SetTitle         (Window*, cstr);
    void    Window_SetVsync         (Window*, bool);
    void    Window_ToggleFullscreen (Window*);
    void    Window_Hide             (Window*);
    void    Window_Show             (Window*);
  ]]
end

do -- Global Symbol Table
  Window = {
    Create           = libphx.Window_Create,
    Free             = libphx.Window_Free,
    BeginDraw        = libphx.Window_BeginDraw,
    EndDraw          = libphx.Window_EndDraw,
    GetPosition      = libphx.Window_GetPosition,
    GetSize          = libphx.Window_GetSize,
    GetTitle         = libphx.Window_GetTitle,
    SetFullscreen    = libphx.Window_SetFullscreen,
    SetPosition      = libphx.Window_SetPosition,
    SetSize          = libphx.Window_SetSize,
    SetTitle         = libphx.Window_SetTitle,
    SetVsync         = libphx.Window_SetVsync,
    ToggleFullscreen = libphx.Window_ToggleFullscreen,
    Hide             = libphx.Window_Hide,
    Show             = libphx.Window_Show,
  }

  if onDef_Window then onDef_Window(Window, mt) end
  Window = setmetatable(Window, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Window')
  local mt = {
    __index = {
      managed          = function (self) return ffi.gc(self, libphx.Window_Free) end,
      free             = libphx.Window_Free,
      beginDraw        = libphx.Window_BeginDraw,
      endDraw          = libphx.Window_EndDraw,
      getPosition      = libphx.Window_GetPosition,
      getSize          = libphx.Window_GetSize,
      getTitle         = libphx.Window_GetTitle,
      setFullscreen    = libphx.Window_SetFullscreen,
      setPosition      = libphx.Window_SetPosition,
      setSize          = libphx.Window_SetSize,
      setTitle         = libphx.Window_SetTitle,
      setVsync         = libphx.Window_SetVsync,
      toggleFullscreen = libphx.Window_ToggleFullscreen,
      hide             = libphx.Window_Hide,
      show             = libphx.Window_Show,
    },
  }

  if onDef_Window_t then onDef_Window_t(t, mt) end
  Window_t = ffi.metatype(t, mt)
end

return Window
