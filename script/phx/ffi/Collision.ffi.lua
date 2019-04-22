-- Collision -------------------------------------------------------------------
local Collision

local ffi = require('ffi')

do -- Global Symbol Table
  Collision = {
  }

  local mt = {
    __call  = function (t, ...) return Collision_t(...) end,
  }

  if onDef_Collision then onDef_Collision(Collision, mt) end
  Collision = setmetatable(Collision, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Collision')
  local mt = {
    __index = {
      clone = function (x) return Collision_t(x) end,
    },
  }

  if onDef_Collision_t then onDef_Collision_t(t, mt) end
  Collision_t = ffi.metatype(t, mt)
end

return Collision
