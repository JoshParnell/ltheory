-- objects
local Shape        = require('Gen.ShapeLib.Shape')
-- shapes
local BasicShapes  = require('Gen.ShapeLib.BasicShapes')
local RandomShapes = require('Gen.ShapeLib.RandomShapes')
require('Gen.ShapeLib.Warp')
-- ships
local ShipWarps    = require('Gen.ShipLib.ShipWarps')
-- util
local MathUtil     = require('Gen.MathUtil')
local Parametric   = require('Gen.ShapeLib.Parametric')

local ShipDetail = {}

function ShipDetail.Box (rng)
  return BasicShapes.Box(0):scale(0.2, 0.6, 0.2)
end

function ShipDetail.Fin (rng)

end

function ShipDetail.Plate (rng)
  local shape = BasicShapes.Box(0)
  shape:scale(1, 0.2, 1)

  local n = rng:getInt(1, 4)
  for i = 1, n do
    local pi = shape:getPolyWithNormal(Vec3d(0, 0, rng:choose({1,-1})))
    local scale = Vec3d(rng:getUniformRange(0.2, 1.4), 1, 1)
    local length = rng:getUniformRange(0.2, 2)
    shape:extrudePoly(pi, length, scale)
  end

  return shape
end

function ShipDetail.AddDetail (shape, rng, symmetrical)
  if symmetrical == nil then symmetrical = true end
  shape:center()

  local aabb = shape:getAABB()

  local z1 = 0 -- aabb.lower.z
  local ray = {Vec3d(10, 0, z1), Vec3d(-10, 0, z1)}
  local detail = ShipDetail.Box()
  local center = Vec3d(0, 0, 0)
  detail:center(center.x, center.y, center.z)
  local n = 10
  local dist = 0.5

  -- first side
  for i = 0, n - 1 do
    detail:center(center.x, center.y, center.z)
    shape:addAtIntersection(ray[1], ray[2], detail)
    local z = z1 + i*dist
    ray[1].z = z
    ray[2].z = z
  end

  if symmetrical == false then
    return shape
  end

  -- second side
  ray[1].x = -ray[1].x
  ray[2].x = -ray[2].x
  ray[1].z = z1
  ray[2].z = z1

  for i = 0, n - 1 do
    detail:center(center.x, center.y, center.z)
    shape:addAtIntersection(ray[1], ray[2], detail)
    local z = z1 + i*dist
    ray[1].z = z
    ray[2].z = z
  end

  return shape
end

return ShipDetail
