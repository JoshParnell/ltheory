-- objects
local Joint       = require('Gen.ShapeLib.Joint')
local Shape       = require('Gen.ShapeLib.Shape')
local Style       = require('Gen.ShapeLib.Style')
-- shapes
local BasicShapes = require('Gen.ShapeLib.BasicShapes')
local Cluster     = require('Gen.ShapeLib.Cluster')
-- warps
require('Gen.ShapeLib.Warp')
-- util
local Parametric  = require('Gen.ShapeLib.Parametric')

local Module = {}

function Module.ConstructionYard(style)
  local shape = Shape()
  local rng = style.rng

  -- ring cluster
  -- (joint @ center of shape,
  -- instead of on a poly,
  -- to guaruntee the shape is perfectly vertical)
  local radius = 2
  local ring = Cluster.GenerateRingSafe(style, radius)
  local joint = Joint()
  joint.pos = Vec3d(0,0,0)
  joint.dir = Vec3d(0,0,1)
  joint.up = Vec3d(0,1,0)
  joint.scale = Vec3d(1,1,1)
  local n = rng:getInt(3, 5)
  local spacing = rng:getUniformRange(2, 4)
  shape = Cluster.GenerateLinear(style, n, spacing, ring, joint)

  -- side attachments
  local aabb = shape:getAABB()
  local sc = style:getScaffolding()
  local length = abs(aabb.upper.z - aabb.lower.z)
  local width = abs(aabb.upper.x - aabb.lower.x)
  local height = abs(aabb.upper.y - aabb.lower.y)

  local plane = Cluster.GeneratePlane(style, floor(length), 1, floor(width), 1, sc, joint)
  local plane1 = plane:clone():rotate(math.pi/2.0, 0, math.pi/2.0):translate(0, aabb[1].y - 0.5, 0)
  local plane2 = plane:clone():rotate(math.pi/2.0, 0, math.pi/2.0):translate(0, aabb[2].y + 0.5, 0)

  local col = Cluster.GeneratePlane(style, n, spacing, floor(height)+2, 1, sc, joint)
  local col1 = col:clone():rotate(math.pi/2.0, 0, 0):translate(aabb[1].x, 0, 0)
  local col2 = col:clone():rotate(math.pi/2.0, 0, 0):translate(aabb[2].x, 0, 0)

  shape:add(plane1, plane2, col1, col2)

  return shape
end

function Module.Core (style)
  local shape = Shape()

  local numRings = style.rng:getInt(1, 7)
  local ringRadius = style.rng:getExp()*10.0 + 3.0
  local ring = Cluster.GenerateRing(style, ringRadius, true)
  for i = 0, numRings do
    shape:add(
      ring:clone()
      :rotate(style.rng:getAngle(), style.rng:getAngle(), style.rng:getAngle())
    )
  end

  local core = style:getShape():sphereize()
  shape:add(core)

  return shape
end

return Module
