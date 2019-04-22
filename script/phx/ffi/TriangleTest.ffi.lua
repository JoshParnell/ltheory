-- TriangleTest ----------------------------------------------------------------
local TriangleTest

local ffi = require('ffi')

do -- Global Symbol Table
  TriangleTest = {
  }

  local mt = {
    __call  = function (t, ...) return TriangleTest_t(...) end,
  }

  if onDef_TriangleTest then onDef_TriangleTest(TriangleTest, mt) end
  TriangleTest = setmetatable(TriangleTest, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('TriangleTest')
  local mt = {
    __index = {
      clone = function (x) return TriangleTest_t(x) end,
    },
  }

  if onDef_TriangleTest_t then onDef_TriangleTest_t(t, mt) end
  TriangleTest_t = ffi.metatype(t, mt)
end

return TriangleTest
