-- Vec2d -----------------------------------------------------------------------
local Vec2d

local ffi = require('ffi')

do -- Global Symbol Table
  Vec2d = {
  }

  local mt = {
    __call  = function (t, ...) return Vec2d_t(...) end,
  }

  if onDef_Vec2d then onDef_Vec2d(Vec2d, mt) end
  Vec2d = setmetatable(Vec2d, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Vec2d')
  local mt = {
    __index = {
      clone = function (x) return Vec2d_t(x) end,
    },
  }

  if onDef_Vec2d_t then onDef_Vec2d_t(t, mt) end
  Vec2d_t = ffi.metatype(t, mt)
end

return Vec2d
