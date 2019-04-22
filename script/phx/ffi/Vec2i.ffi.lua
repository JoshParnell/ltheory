-- Vec2i -----------------------------------------------------------------------
local Vec2i

local ffi = require('ffi')

do -- Global Symbol Table
  Vec2i = {
  }

  local mt = {
    __call  = function (t, ...) return Vec2i_t(...) end,
  }

  if onDef_Vec2i then onDef_Vec2i(Vec2i, mt) end
  Vec2i = setmetatable(Vec2i, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Vec2i')
  local mt = {
    __index = {
      clone = function (x) return Vec2i_t(x) end,
    },
  }

  if onDef_Vec2i_t then onDef_Vec2i_t(t, mt) end
  Vec2i_t = ffi.metatype(t, mt)
end

return Vec2i
