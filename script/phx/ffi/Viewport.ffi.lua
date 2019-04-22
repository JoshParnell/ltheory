-- Viewport --------------------------------------------------------------------
local Viewport

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void  Viewport_Pop       ();
    void  Viewport_Push      (int x, int y, int sx, int sy, bool isWindow);
    float Viewport_GetAspect ();
    void  Viewport_GetSize   (Vec2i* out);
  ]]
end

do -- Global Symbol Table
  Viewport = {
    Pop       = libphx.Viewport_Pop,
    Push      = libphx.Viewport_Push,
    GetAspect = libphx.Viewport_GetAspect,
    GetSize   = libphx.Viewport_GetSize,
  }

  if onDef_Viewport then onDef_Viewport(Viewport, mt) end
  Viewport = setmetatable(Viewport, mt)
end

return Viewport
