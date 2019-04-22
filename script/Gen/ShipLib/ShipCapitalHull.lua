-- objects
local Shape        = require('Gen.ShapeLib.Shape')
-- shapes
local BasicShapes  = require('Gen.ShapeLib.BasicShapes')
local RandomShapes = require('Gen.ShapeLib.RandomShapes')
-- ships
local ShipWarps    = require('Gen.ShipLib.ShipWarps')
local ShipDetail   = require('Gen.ShipLib.ShipDetail')
require('Gen.ShapeLib.Warp')
-- util
local MathUtil     = require('Gen.MathUtil')
local Parametric   = require('Gen.ShapeLib.Parametric')

local ShipCapitalHull = {}

function ShipCapitalHull.Hull (rng)
  local shape

  -- settings
  -- extrusion settings
  local minX = 0.2
  local maxX = 1.5
  local minY = 1.0
  local maxY = 1.5
  local maxT = math.pi - 0.2
  local minT = math.pi + 0.2
  -- extra polys
  local minP = 0
  local maxP = 4
  -- base shape types
  local baseShape
  local baseDist = Distribution()
  baseDist:add(1, 0.5)
  baseDist:add(2, 0.5)
  baseShape = baseDist:sample(rng)

  if baseShape == 1 then
    shape = BasicShapes.Box(0)
  elseif baseShape == 2 then
    local sides = rng:choose({3, 5, 6, 8, 20, 30})
    shape = BasicShapes.Prism(2, sides)
    shape:scale(2,2,2)
    shape:rotate(0, math.pi/2.0, 0)
    if sides % 2 ~= 0 then
      shape:rotate(0, 0, math.pi/2.0)
    end
  end

  local segments = rng:getInt(1, 3)
  for i = 0, segments do
    local dir = rng:choose({1, -1})
    local pi = shape:getPolyWithNormal(Vec3d(0, 0, dir))
    local extrusionLength = rng:getUniformRange(0.2, 3.0)
    local extrusionSize = Vec3d(
      rng:getUniformRange(minX, maxX),
      rng:getUniformRange(minY, maxY),
      1.0
    )
    local extrusionAngle = rng:getUniformRange(minT, maxT)
    shape:extrudePoly(pi, extrusionLength, extrusionSize, Vec3d(0, sin(extrusionAngle), -dir*cos(extrusionAngle)))
  end

  if baseShape ~= 2 then
    local np = rng:getInt(minP, maxP)
    for i = 1, np do
      local poly = shape:getRandomPolyWithNormalList({Vec3d(0, 1, 0),Vec3d(0, -1, 0)}, rng, 1.0)
      shape:extrudePoly(poly, rng:getUniformRange(0.2, 1.0))
    end
  end

  if rng:chance(0.5) then
    shape = ShipDetail.AddDetail(shape, rng)
  end

  return shape
end

return ShipCapitalHull
