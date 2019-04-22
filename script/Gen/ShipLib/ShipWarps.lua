-- objects
local Shape        = require('Gen.ShapeLib.Shape')
-- shapes
local BasicShapes  = require('Gen.ShapeLib.BasicShapes')
local RandomShapes = require('Gen.ShapeLib.RandomShapes')
require('Gen.ShapeLib.Warp')
-- util
local MathUtil     = require('Gen.MathUtil')

Settings.addFloat('genship.global.curveZ', 'Curve Z', 0.0, -3.0, 3.0)
Settings.addFloat('genship.global.curveY', 'Curve Y', 0.0, -3.0, 3.0)

local ShipWarps = {}

function ShipWarps.CurveWarps(rng, shape)
  -- center (makes curves better)
  shape:center()

  -- helper data
  local shapeAABB = shape:getAABB()
  local xMin = shapeAABB.lower.x
  local xMax = shapeAABB.upper.x

  local curveY = 0
  local curveZ = 0
  if Settings['genship.override'] then
    curveY = Settings['genship.global.curveY']
    curveZ = Settings['genship.global.curveZ']
  else
    if rng:chance(0.5) then curveY = rng:getUniformRange(-1.0, 1.0) end
    if rng:chance(0.5) then curveZ = rng:getUniformRange(-1.0, 1.0) end
  end

  --print("curveY: ", curveY)
  --print("curveZ: ", curveZ)

  -- Curve z along x
  shape:warp(function (v)
    -- min, max, amt
    local x = (v.x - xMin)/(xMax - xMin)
    x = Math.Lerp(0, math.pi, x)
    v.z = v.z + sin(x)*curveZ
  end)
  shape:center()

  -- Curve y along x
  shape:warp(function (v)
    -- min, max, amt
    local x = (v.x - xMin)/(xMax - xMin)
    x = Math.Lerp(0, math.pi, x)
    v.y = v.y + sin(x)*curveY
  end)

  shape:center()

  return shape
end

return ShipWarps
