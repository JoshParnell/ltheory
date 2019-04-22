-- PixelFormat -----------------------------------------------------------------
local PixelFormat

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    int         PixelFormat_Components      (PixelFormat);
    PixelFormat PixelFormat_Red;
    PixelFormat PixelFormat_RG;
    PixelFormat PixelFormat_RGB;
    PixelFormat PixelFormat_BGR;
    PixelFormat PixelFormat_RGBA;
    PixelFormat PixelFormat_BGRA;
    PixelFormat PixelFormat_Depth_Component;
  ]]
end

do -- Global Symbol Table
  PixelFormat = {
    Red  = libphx.PixelFormat_Red,
    RG   = libphx.PixelFormat_RG,
    RGB  = libphx.PixelFormat_RGB,
    BGR  = libphx.PixelFormat_BGR,
    RGBA = libphx.PixelFormat_RGBA,
    BGRA = libphx.PixelFormat_BGRA,
    Depth = {
      Component = libphx.PixelFormat_Depth_Component,
    },
    Components = libphx.PixelFormat_Components,
  }

  if onDef_PixelFormat then onDef_PixelFormat(PixelFormat, mt) end
  PixelFormat = setmetatable(PixelFormat, mt)
end

return PixelFormat
