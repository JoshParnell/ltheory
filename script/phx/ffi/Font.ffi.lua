-- Font ------------------------------------------------------------------------
local Font

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Font* Font_Load          (cstr name, int size);
    void  Font_Acquire       (Font*);
    void  Font_Free          (Font*);
    void  Font_Draw          (Font*, cstr text, float x, float y, float r, float g, float b, float a);
    void  Font_DrawShaded    (Font*, cstr text, float x, float y);
    int   Font_GetLineHeight (Font*);
    void  Font_GetSize       (Font*, Vec4i* out, cstr text);
    void  Font_GetSize2      (Font*, Vec2i* out, cstr text);
  ]]
end

do -- Global Symbol Table
  Font = {
    Load          = libphx.Font_Load,
    Acquire       = libphx.Font_Acquire,
    Free          = libphx.Font_Free,
    Draw          = libphx.Font_Draw,
    DrawShaded    = libphx.Font_DrawShaded,
    GetLineHeight = libphx.Font_GetLineHeight,
    GetSize       = libphx.Font_GetSize,
    GetSize2      = libphx.Font_GetSize2,
  }

  if onDef_Font then onDef_Font(Font, mt) end
  Font = setmetatable(Font, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Font')
  local mt = {
    __index = {
      managed       = function (self) return ffi.gc(self, libphx.Font_Free) end,
      acquire       = libphx.Font_Acquire,
      free          = libphx.Font_Free,
      draw          = libphx.Font_Draw,
      drawShaded    = libphx.Font_DrawShaded,
      getLineHeight = libphx.Font_GetLineHeight,
      getSize       = libphx.Font_GetSize,
      getSize2      = libphx.Font_GetSize2,
    },
  }

  if onDef_Font_t then onDef_Font_t(t, mt) end
  Font_t = ffi.metatype(t, mt)
end

return Font
