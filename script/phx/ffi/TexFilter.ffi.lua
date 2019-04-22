-- TexFilter -------------------------------------------------------------------
local TexFilter

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    TexFilter TexFilter_Point;
    TexFilter TexFilter_PointMipPoint;
    TexFilter TexFilter_PointMipLinear;
    TexFilter TexFilter_Linear;
    TexFilter TexFilter_LinearMipPoint;
    TexFilter TexFilter_LinearMipLinear;
  ]]
end

do -- Global Symbol Table
  TexFilter = {
    Point           = libphx.TexFilter_Point,
    PointMipPoint   = libphx.TexFilter_PointMipPoint,
    PointMipLinear  = libphx.TexFilter_PointMipLinear,
    Linear          = libphx.TexFilter_Linear,
    LinearMipPoint  = libphx.TexFilter_LinearMipPoint,
    LinearMipLinear = libphx.TexFilter_LinearMipLinear,
  }

  if onDef_TexFilter then onDef_TexFilter(TexFilter, mt) end
  TexFilter = setmetatable(TexFilter, mt)
end

return TexFilter
