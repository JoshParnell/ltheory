-- Vec2f -----------------------------------------------------------------------
local Vec2f

local ffi = require('ffi')

do -- Global Symbol Table
  Vec2f = {
  }

  local mt = {
    __call  = function (t, ...) return Vec2f_t(...) end,
  }

  if onDef_Vec2f then onDef_Vec2f(Vec2f, mt) end
  Vec2f = setmetatable(Vec2f, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Vec2f')
  local mt = {
    __index = {
      clone = function (x) return Vec2f_t(x) end,
    },
  }

  if onDef_Vec2f_t then onDef_Vec2f_t(t, mt) end
  Vec2f_t = ffi.metatype(t, mt)
end

return Vec2f
