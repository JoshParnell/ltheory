local RandomShapes  = require('Gen.ShapeLib.RandomShapes')
local BasicShapes   = require('Gen.ShapeLib.BasicShapes')
local MathUtil      = require('Gen.MathUtil')
local Joint         = require('Gen.ShapeLib.Joint')
local JointField    = require('Gen.ShapeLib.JointField')
local Shape         = require('Gen.ShapeLib.Shape')
local Parametric    = require('Gen.ShapeLib.Parametric')
local Style         = require('Gen.ShapeLib.Style')
require('Gen.ShapeLib.Warp')

local Cluster = {}

-- GenerateLinear (
--   Style style,
--   int numShapes [optional],
--   float spacing [optional],
--   Shape shape [optional],
--   Joint joint [optional]
-- )
-- Generates on z axis
function Cluster.GenerateLinear (style, numShapes, spacing, shape, joint)
  numShapes = numShapes or style.rng:getInt(10, 30)
  spacing = spacing or style.rng:getUniformRange(0.0, 3.0)

  local field = JointField()
  field:generateFromFunction(
    function(i) return Vec3d(0, 0, i*spacing) end, -- pos
    function(i) return Vec3d(0, 0, 1) end,         -- dir
    function(i) return Vec3d(0, 1, 0) end,         -- up
    function(i) return Vec3d(1, 1, 1) end,         -- scale
    numShapes, 1
  )

  shape = shape or style:getShape()
  if joint == nil then
    joint = Joint()
    joint:generateFromPoly(shape, shape:getRandomPoly(style.rng))
  end

  return field:createShape(shape, joint)
end

function Cluster.GenerateParametricSafe (style, r)
  return Cluster.GenerateParametric(style, r, style:getParametricSafe())
end

-- GenerateParametric (
--  Style style, float r,
--  Shape shape [optional],
--  function* fn [optional],
--  Joint joint [optional]
--)
-- Generates on x,y plane
function Cluster.GenerateParametric (style, r, fn, shape, joint)
  local fn = fn or style:getParametric()
  local numShapes = style.rng:getExp() * 150 + 10
  local scale = (2*math.pi*r) / numShapes

  local step = (2*math.pi)/numShapes
  local field = JointField()
  field:generateFromFunction(
    function(t) return Vec3d(fn(t).x * r, fn(t).y * r, 0) end, -- pos
    function(t) return Vec3d(fn(t).x * r, fn(t).y * r, 0) end, -- dir
    function(t) return Vec3d(0, 0, 1) end,                     -- up
    function(t) return Vec3d(scale, scale, scale) end,         -- scale
    numShapes, step
  )

  shape = shape or style:getShape()
  if joint == nil then
    joint = Joint()
    joint:generateFromPoly(shape, shape:getRandomPoly(style.rng))
  end

  local final = field:createShape(shape, joint)
  return final
end

-- GenerateCurve (
--   Style style, float length,
--   Shape shape [optional]
-- )
-- Generates on x,z plane
function Cluster.GenerateCurve (style, length, shape)
  -- p0, p3 = endpoints
  local p0 = Vec2d(0, 0)
  local p3 = Vec2d(length, 0)
  -- p1, p2 = points between p0, p4
  local p1 = Vec2d(style.rng:getUniformRange(0, length/2.0),
                       style.rng:getUniformRange(0, length))
  local p2 = Vec2d(style.rng:getUniformRange(length/2.0, length),
                       style.rng:getUniformRange(0, length))
  local numShapes = style.rng:getInt(7, 30)
  local scale = length / numShapes

  -- bezier function
  local fnbez = function(t) return Vec3d(
    ((1-t)^3)*p0.x + 3*(1-t)*(1-t)*t*p1.x + 3*(1-t)*t*t*p2.x + (t^3)*p3.x,
    0,
    ((1-t)^3)*p0.y + 3*(1-t)*(1-t)*t*p1.y + 3*(1-t)*t*t*p2.y + (t^3)*p3.y)
  end

  -- create joint field
  local step = 1.0/numShapes
  local field = JointField()
  field:generateFromFunction(
    fnbez,                                            -- pos
    fnbez,                                            -- dir
    function(i) return Vec3d(0, 1, 0) end,             -- up
    function(i) return Vec3d(scale, scale, scale) end, -- scale
    numShapes, step
  )

  -- create shape
  local shape = shape or style:getShape()
  if joint == nil then
    joint = Joint()
    joint:generateFromPoly(shape, shape:getRandomPoly(style.rng))
  end

  return field:createShape(shape, joint)
end

-- GeneratePlane (Style style,
--   int numShapes - x,
--   float spacing - x,
--   int numShapes - y,
--   float spacing - y,
--   Shape shape, Joint joint
-- )
-- Generates on the x,y plane
function Cluster.GeneratePlane (style, nX, sX, nY, sY, shape, joint)
  local linearX = Cluster.GenerateLinear(style, nX, sX, shape, joint)
  linearX:rotate(math.pi/2.0, 0, 0)

  local joint2 = Joint()
  joint2.pos = Vec3d(0,0,0)
  joint2.dir = Vec3d(0,0,1)
  joint2.up = Vec3d(0,1,0)
  joint2.scale = Vec3d(1,1,1)

  local shape = Cluster.GenerateLinear(style, nY, sY, linearX, joint2)
  shape:rotate(0, math.pi/2.0, 0)

  return shape
end

-- RandomRing (Style style, float r [optional])
-- Generates on x,y plane
-- Guaruntees safe parametric fn
function Cluster.GenerateRingSafe (style, r)
  r = r or 1
  local ring
  local ringType = style.rng:getInt(1, 2)
  if ringType == 1 then
    ring = style:getTorusSafe()
  else
    ring = Cluster.GenerateParametricSafe(style, r)
  end
  return ring
end

function Cluster.GenerateRing (style, r, addConnector)
  r = r or 1
  local ring
  local ringType = style.rng:getInt(1, 2)
  if ringType == 1 then
    ring = style:getTorus()
  else
    local p = style:getParametric()
    ring = Cluster.GenerateParametric(style, r, p)
    if addConnector then
      ring:add(
        BasicShapes.Torus(p, style:getParametricSafe(), r, 0.1)
      )
    end
  end
  return ring
end

-- RandomColumn (Style style, float l)
-- Generates on z axis
function Cluster.GenerateColumn (style, l)
  l = l or 1
  local col

  local colType = style.rng:getInt(1, 4)
  if colType == 1 then
    col = BasicShapes.Box(10)
    col:scale(1, 1, l)
  elseif colType == 2 then
    col = BasicShapes.IrregularPrism(style.rng, 10)
    col:scale(1, l, 1)
    col:rotate(0, math.pi/2.0, 0)
  elseif colType == 3 then
    col = BasicShapes.Prism(10, style.rng:choose({3, 4, 5, 6, 8, 20, 25, 30}))
    col:scale(1, l, 1)
    col:rotate(0, math.pi/2.0, 0)
  else
    col = Cluster.GenerateLinear(style, l, 1)
  end

  return col
end

-- GenerateSpherical
function Cluster.GenerateSpherical (style, r, shape, joint)
  r = r or 0.5

  -- create field
  -- can't use JointField:generateFromFunction()
  --   because of the random pos on spehere, which determines
  --   both position and direction
  local numShapes = style.rng:getInt(5, 30)
  local field = JointField()
  local ind = #field.joints + 1
  for i = 1, numShapes do
    local v = style.rng:getSphere() -- needed for both fnd and fnp
    local p = Vec3d(v.x*r, v.y*r, v.z*r)
    local dir = Vec3d(p.x, p.y, p.z)
    local up = Vec3d(1, 0, 0)
    local valid = dir:length() > 1e-6 and up:length() > 1e-6
    assert(valid)
    if valid then
      dir:inormalize()
      up:inormalize()
      field.joints[ind] = Joint()
      field.joints[ind].pos = p
      field.joints[ind].dir = dir
      field.joints[ind].up = up
      field.joints[ind].scale = Vec3d(1, 1, 1)
      ind = ind + 1
    end
  end
  assert(field:valid())

  -- create shape
  local shape = shape or style:getShape()
  if joint == nil then
    joint = Joint()
    joint:generateFromPoly(shape, shape:getRandomPoly(style.rng))
  end
  local cluster = field:createShape(shape, joint)

  return cluster
end

return Cluster
