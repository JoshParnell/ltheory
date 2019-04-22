-- Renderer --------------------------------------------------------------------
local Renderer

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void Renderer_Init                ();
    void Renderer_Free                ();
    void Renderer_SetDownsampleFactor (int);
    void Renderer_SetShader           (Shader*);
    void Renderer_SetTransform        (Matrix* toWorld, Matrix* toLocal);
  ]]
end

do -- Global Symbol Table
  Renderer = {
    Init                = libphx.Renderer_Init,
    Free                = libphx.Renderer_Free,
    SetDownsampleFactor = libphx.Renderer_SetDownsampleFactor,
    SetShader           = libphx.Renderer_SetShader,
    SetTransform        = libphx.Renderer_SetTransform,
  }

  if onDef_Renderer then onDef_Renderer(Renderer, mt) end
  Renderer = setmetatable(Renderer, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Renderer')
  local mt = {
    __index = {
      managed             = function (self) return ffi.gc(self, libphx.Renderer_Free) end,
    },
  }

  if onDef_Renderer_t then onDef_Renderer_t(t, mt) end
  Renderer_t = ffi.metatype(t, mt)
end

return Renderer
