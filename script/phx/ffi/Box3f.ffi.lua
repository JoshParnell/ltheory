-- Box3f -----------------------------------------------------------------------
local Box3f

local ffi = require('ffi')

do -- Global Symbol Table
  Box3f = {
  }

  local mt = {
    __call  = function (t, ...) return Box3f_t(...) end,
  }

  if onDef_Box3f then onDef_Box3f(Box3f, mt) end
  Box3f = setmetatable(Box3f, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Box3f')
  local mt = {
    __index = {
      clone = function (x) return Box3f_t(x) end,
    },
  }

  if onDef_Box3f_t then onDef_Box3f_t(t, mt) end
  Box3f_t = ffi.metatype(t, mt)
end

return Box3f
