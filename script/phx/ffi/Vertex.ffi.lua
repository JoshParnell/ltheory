-- Vertex ----------------------------------------------------------------------
local Vertex

local ffi = require('ffi')

do -- Global Symbol Table
  Vertex = {
  }

  local mt = {
    __call  = function (t, ...) return Vertex_t(...) end,
  }

  if onDef_Vertex then onDef_Vertex(Vertex, mt) end
  Vertex = setmetatable(Vertex, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Vertex')
  local mt = {
    __index = {
      clone = function (x) return Vertex_t(x) end,
    },
  }

  if onDef_Vertex_t then onDef_Vertex_t(t, mt) end
  Vertex_t = ffi.metatype(t, mt)
end

return Vertex
