-- objects
local Joint        = require('Gen.ShapeLib.Joint')
local JointField   = require('Gen.ShapeLib.JointField')
local Shape        = require('Gen.ShapeLib.Shape')
local Style        = require('Gen.ShapeLib.Style')
-- shapes
local BasicShapes  = require('Gen.ShapeLib.BasicShapes')
local Cluster      = require('Gen.ShapeLib.Cluster')
local Scaffolding  = require('Gen.ShapeLib.Scaffolding')
local Module       = require('Gen.ShapeLib.Module')
local RandomShapes = require('Gen.ShapeLib.RandomShapes')
-- warps
require('Gen.ShapeLib.Warp')
-- util
local MathUtil     = require('Gen.MathUtil')
local Parametric   = require('Gen.ShapeLib.Parametric')

local Station = {}

function Station.GenerateStation (seed)
  local rng = RNG.Create(seed)

  if false then
    local style = Style()
    style:generateRandom(rng)
  end

  local shape
  if true then
    shape = BasicShapes.Box()
    shape:greeble(rng, 2, 0.01, 0.05, 1.0, 1.0)
  else
    local res = rng:choose({4, 6, 8, 10, 20})
    shape = BasicShapes.Prism(2, res)
    shape:rotate(0, math.pi/2, 0)

    local pi = shape:getPolyWithNormal(Vec3d(0, 0, 1))
    local t = math.pi*1.05
    local l = rng:getUniformRange(0.5, 3)
    shape:extrudePoly(pi, l,
              Vec3d(rng:getUniformRange(0.1, 0.5), rng:getUniformRange(0.1, 0.5), rng:getUniformRange(0.1, 0.5)),
              Vec3d(0, sin(t), -cos(t)))

    local back = shape:getPolyWithNormal(Vec3d(0, 0, -1))
    shape:extrudePoly(back, 0.3, Vec3d(0.5, 0.5, 0.5), Vec3d(0, sin(t), cos(t)))

    local engine = BasicShapes.Prism(2, res)
    local es = Vec3d(0.3, rng:getUniformRange(0.3, 1), rng:getUniformRange(0.3, 1))
    engine:scale(es.x, es.y, es.z)

    local bodyAABB = shape:getAABB()
    engine:rotate(0, math.pi/2, 0)
    engine:translate(-es.x/2.0, 0, bodyAABB.lower.z)
    shape:add(engine)
    local engine2 = engine:clone()
    engine2:translate(es.x, 0, 0)
    shape:add(engine2)

    for i = 1, rng:getInt(1, 3) do
      local wing1 = BasicShapes.Box(0)
      wing1:scale(0.1, 0.2, 0.5)
      wing1:translate(0.5, 0, 0)
      local pi1 = wing1:getPolyWithNormal(Vec3d(1, 0, 0))
      l = rng:getUniformRange(0.5, 3)
      wing1:extrudePoly(pi1, l, Vec3d(1, 0.25, 1))
      t = rng:getUniformRange(math.pi* -0.5, math.pi * 0.5)
      wing1:rotate(0, 0, t)
      wing1:tessellate(rng:getInt(0,2))
      wing1:extrudePoly(rng:getInt(1, #wing1.polys), rng:getUniformRange(0.2, 1.0))

      local wing2 = wing1:clone()
      wing2:mirror(true, false, false)

      shape:add(wing1)
      shape:add(wing2)
    end

    local gun1 = BasicShapes.Prism(2, res)
    gun1:rotate(0, math.pi/2, 0)
    local r = rng:getUniformRange(0.1, 0.8)
    local gunScale = Vec3d(r, r, 1.2)
    gun1:scale(gunScale.x, gunScale.y, gunScale.z)
    gun1:translate(bodyAABB[1].x, 0, 0)

    local gun2 = BasicShapes.Prism(2, res)
    gun2:rotate(0, math.pi/2, 0)
    gun2:scale(gunScale.x, gunScale.y, gunScale.z)
    gun2:translate(bodyAABB[2].x, 0, 0)

    shape:add(gun1)
    shape:add(gun2)

    shape = shape:bevel(rng:getUniformRange(0.1, 0.8))
  end

  if false then
    Station.WarpTest(shape, rng)
  end

  if false then
    Station.GenerateJointVisuals(shape)
  end

  if false then
    --shape:tessellate()
    --shape:stellate()
    --shape:extrude()
    --shape = shape:bevel()
    --shape:extrude()
    shape:axialPush(rng)
    shape:greeble(rng, 1, 0.01, 0.05)
    --local top = shape:getTopology() -- determine if manifold
    --local valid = shape:valid()
  end

  -- finalize mesh
  rng:free()
  return shape:finalize()
end

function Station.WarpTest(shape, rng)
  if true then
    shape:axialPush(rng)
  end

  if false then
    shape:sphereize()
  end

  if true then
    for j = 1, 2 do
      if rng:chance(0.7) then
        shape:extrude(0.5 * rng:getExp())
      else
        shape:stellate(0.5 * rng:getUniformRange(-1, 1) * rng:getExp())
      end

      if true then
        shape:expStretch(rng)
      end
    end
  end

  -- Stellate + Extrude (by small amount each) yields a 'plated shell' look
  if true then
    shape:stellate(0.1)
    shape:extrude(1)
    --shape:tessellate(1)
  end
end

-- GenerateJointVisuals (Shape shape)
function Station.GenerateJointVisuals (shape)
  local field = JointField()
  -- size func function(x,y,z) return Vec3d(1,abs(0.8*y),1) end
  field:generateFromShape(shape)

  local box = BasicShapes.Box()
  box:scale(0.2, 0.2, 0.5)

  local joint = Joint()
  joint:generateFromPoly(box, box.polys[1])
  shape:add(field:createShape(box, joint))
  return shape
end

return Station
