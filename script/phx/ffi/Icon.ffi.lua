-- Icon ------------------------------------------------------------------------
local Icon

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Icon* Icon_Create    ();
    void  Icon_Free      (Icon*);
    void  Icon_AddBox    (Icon*, float x, float y, float sx, float sy);
    void  Icon_AddCircle (Icon*, float x, float y, float radius);
    void  Icon_AddPoint  (Icon*, float x, float y);
    void  Icon_AddLine   (Icon*, float x1, float y1, float x2, float y2);
    void  Icon_AddRing   (Icon*, float x, float y, float radius, float thickness);
    void  Icon_Draw      (Icon*, float x, float y, float size, float r, float g, float b, float a);
  ]]
end

do -- Global Symbol Table
  Icon = {
    Create    = libphx.Icon_Create,
    Free      = libphx.Icon_Free,
    AddBox    = libphx.Icon_AddBox,
    AddCircle = libphx.Icon_AddCircle,
    AddPoint  = libphx.Icon_AddPoint,
    AddLine   = libphx.Icon_AddLine,
    AddRing   = libphx.Icon_AddRing,
    Draw      = libphx.Icon_Draw,
  }

  if onDef_Icon then onDef_Icon(Icon, mt) end
  Icon = setmetatable(Icon, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Icon')
  local mt = {
    __index = {
      managed   = function (self) return ffi.gc(self, libphx.Icon_Free) end,
      free      = libphx.Icon_Free,
      addBox    = libphx.Icon_AddBox,
      addCircle = libphx.Icon_AddCircle,
      addPoint  = libphx.Icon_AddPoint,
      addLine   = libphx.Icon_AddLine,
      addRing   = libphx.Icon_AddRing,
      draw      = libphx.Icon_Draw,
    },
  }

  if onDef_Icon_t then onDef_Icon_t(t, mt) end
  Icon_t = ffi.metatype(t, mt)
end

return Icon
