-- objects
local Shape        = require('Gen.ShapeLib.Shape')
-- shapes
local BasicShapes  = require('Gen.ShapeLib.BasicShapes')
local RandomShapes = require('Gen.ShapeLib.RandomShapes')
-- ships
local ShipWarps    = require('Gen.ShipLib.ShipWarps')
local ShipHull     = require('Gen.ShipLib.ShipCapitalHull')
local ShipDetail   = require('Gen.ShipLib.ShipDetail')
require('Gen.ShapeLib.Warp')
-- util
local MathUtil     = require('Gen.MathUtil')
local Parametric   = require('Gen.ShapeLib.Parametric')

local ShipCapitalCockpit = {}

function ShipCapitalCockpit.CockpitLarge (rng)
  local cockpitSizeMin = 0.2
  local cockpitSizeMax = 0.5

  -- cockpit
  local shape = ShipHull.Hull(rng)

  -- tower thing
  local aabb = shape:getAABB()
  local box = BasicShapes.Box()
  box:scale(abs(aabb.upper.x - aabb.lower.x)*0.25, 2, 0.25*abs(aabb.upper.z - aabb.lower.z))
  box:center(0, -1.8, 0)
  shape:addAtIntersection(Vec3d(0,-10,0), Vec3d(0,10,0), box)

  shape:scale(rng:getUniformRange(cockpitSizeMin, cockpitSizeMax))
  aabb = shape:getAABB()
  shape:center(0, 0.4*abs(aabb.upper.y-aabb.lower.y), 0)
  return shape
end

return ShipCapitalCockpit
