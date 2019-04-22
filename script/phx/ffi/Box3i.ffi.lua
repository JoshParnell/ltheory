-- Box3i -----------------------------------------------------------------------
local Box3i

local ffi = require('ffi')

do -- Global Symbol Table
  Box3i = {
  }

  local mt = {
    __call  = function (t, ...) return Box3i_t(...) end,
  }

  if onDef_Box3i then onDef_Box3i(Box3i, mt) end
  Box3i = setmetatable(Box3i, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Box3i')
  local mt = {
    __index = {
      clone = function (x) return Box3i_t(x) end,
    },
  }

  if onDef_Box3i_t then onDef_Box3i_t(t, mt) end
  Box3i_t = ffi.metatype(t, mt)
end

return Box3i
