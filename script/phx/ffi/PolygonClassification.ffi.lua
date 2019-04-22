-- PolygonClassification -------------------------------------------------------
local PolygonClassification

local ffi = require('ffi')

do -- Global Symbol Table
  PolygonClassification = {
    InFront    = 1,
    Behind     = 2,
    Coplanar   = 3,
    Straddling = 4,
  }

  if onDef_PolygonClassification then onDef_PolygonClassification(PolygonClassification, mt) end
  PolygonClassification = setmetatable(PolygonClassification, mt)
end

return PolygonClassification
