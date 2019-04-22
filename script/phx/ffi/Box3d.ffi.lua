-- Box3d -----------------------------------------------------------------------
local Box3d

local ffi = require('ffi')

do -- Global Symbol Table
  Box3d = {
  }

  local mt = {
    __call  = function (t, ...) return Box3d_t(...) end,
  }

  if onDef_Box3d then onDef_Box3d(Box3d, mt) end
  Box3d = setmetatable(Box3d, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Box3d')
  local mt = {
    __index = {
      clone = function (x) return Box3d_t(x) end,
    },
  }

  if onDef_Box3d_t then onDef_Box3d_t(t, mt) end
  Box3d_t = ffi.metatype(t, mt)
end

return Box3d
