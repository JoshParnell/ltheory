-- objects
local Shape        = require('Gen.ShapeLib.Shape')
-- shapes
local BasicShapes  = require('Gen.ShapeLib.BasicShapes')
local RandomShapes = require('Gen.ShapeLib.RandomShapes')
-- ships
local ShipWarps    = require('Gen.ShipLib.ShipWarps')
local ShipDetail   = require('Gen.ShipLib.ShipDetail')
local ShipHull     = require('Gen.ShipLib.ShipCapitalHull')
local ShipCockpit  = require('Gen.ShipLib.ShipCapitalCockpit')
require('Gen.ShapeLib.Warp')
-- util
local MathUtil     = require('Gen.MathUtil')
local Parametric   = require('Gen.ShapeLib.Parametric')

local ShipCapital = {}

function ShipCapital.EngineSingle (rng)
  local res = rng:choose({5, 6, 8, 10, 20})
  local engine = BasicShapes.Prism(2, res)

  local r = rng:getUniformRange(1, 3)

  engine:scale(r, r, r)
  engine:rotate(0, math.pi/2, 0)

  -- center on z-axis
  local aabb = engine:getAABB()
  local z = math.abs(aabb.upper.z - aabb.lower.z)
  engine:center(0, 0, -z/2.0)

  -- extrude forward-facing face so that it looks more 'attached' to the ship
  local pi = engine:getPolyWithNormal(Vec3d(0, 0, 1))
  local t = math.pi*1.05
  local l = 0.1
  r = 0.25
  engine:extrudePoly(pi, l,
            Vec3d(r, r, r),
            Vec3d(0, math.sin(t), -math.cos(t)))

  return engine:finalize()
end

function ShipCapital.Sausage (rng)
  local shape = Shape()

  -- settings
  -- segments
  local minSegments = 1
  local maxSegments = 3
  -- overall size settings
  local minS = 0.5
  local maxS = 1.5
  -- overlap
  local overlapChance = 0.5
  -- extra segments
  local cockpitChance = 0.5

  -- base segments
  local segments = rng:getInt(minSegments, maxSegments)
  shape:add(ShipHull.Hull(rng))
  for i = 1, segments - 1 do
    local seg = ShipHull.Hull (rng)

    local overlap = rng:chance(0.5)
    if overlap then
      shape:add(seg)
    else
      local aabb = shape:getAABB()
      seg:translate(0, 0, aabb.upper.z)
      shape:add(seg)
    end
  end

  -- cockpit area
  if rng:chance(cockpitChance) then
    local aabb = shape:getAABB()
    local cp = ShipCockpit.CockpitLarge(rng)

    local cz = math.abs(aabb.upper.z - aabb.lower.z) * 0.2 + aabb.lower.z
    shape:addAtIntersection(Vec3d(0, 10, cz), Vec3d(0, -10, cz), cp)
  end

  -- plates
  if rng:chance(0.5) then
    local plate = ShipDetail.Plate(rng)
    local aabb = shape:getAABB()
    plate:scale(0.5*math.abs(aabb.upper.x-aabb.lower.x), 1, 0.3*math.abs(aabb.upper.z-aabb.lower.z))
    plate:center()
    shape:center()
    shape:add(plate)
  end

  -- random scale
  shape:scale(rng:getUniformRange(minS, maxS), rng:getUniformRange(minS, maxS), 1)

  return shape:finalize()
end

function ShipCapital.Top (rng)
  local shape = BasicShapes.Box(0)

  -- base
  shape:scale(1.2, 0.25, 1.5)
  local pi = shape:getPolyWithNormal(Vec3d(0,1,0))
  shape:roofQuad(pi, 0.2)

  local roof2 = shape:clone()
  roof2:scale(0.8)
  shape:addAtIntersection(Vec3d(0, 10, -0.1), Vec3d(0, -10, -0.1), roof2)

  -- build tower
  local tower = BasicShapes.Box()
  tower:scale(0.3, 0.8, 0.3)

  local tower2 = BasicShapes.Prism(2, 6)
  tower2:rotate(0, math.pi/2, math.pi/2)
  tower2:scale(2, 0.5, 1)
  tower:addAtIntersection(Vec3d(0, 10, 0), Vec3d(0, -10, 0), tower2)

  shape:addAtIntersection(Vec3d(0, 10, -0.5), Vec3d(0, -10, -0.5), tower)

  return shape
end

function ShipCapital.Triangle (rng)
  local shape = BasicShapes.Prism(2, 3)
  shape:rotate(-math.pi/2, 0, 0)
  shape:scale(5, 0.2, 6)

  -- top
  local topTri = shape:getPolyWithNormal(Vec3d(0,1,0))
  local t = math.pi*1.2
  shape:triangulatePolyCentroid(topTri, 0.5, Vec3d(0, -math.sin(t), math.cos(t)))

  -- back
  local backTri = shape:getPolyWithNormal(Vec3d(0, 0, -1))
  shape:triangulatePolyCentroid(backTri, 1)

  -- attachment thingy on top
  local aabb = shape:getAABB()
  local length = math.abs(aabb.upper.z - aabb.lower.z)
  local top = ShipCapital.Top(rng)
  top:scale(0.75)
  shape:addAtIntersection(Vec3d(0, 10, -0.5), Vec3d(0, -10, -0.5), top)

  return shape:finalize()
end

function ShipCapital.Burger(rng)
  local shape = Shape()
  shape:add(ShipCapital.Plate(rng))

  return shape:finalize()
end

return ShipCapital
