local MeshUtil   = require('Gen.MeshUtil')
local Shape      = require('Gen.ShapeLib.Shape')
require('Gen.ShapeLib.Warp')
local Parametric = require('Gen.ShapeLib.Parametric')
local MathUtil   = require('Gen.MathUtil')
local Warp       = require('Gen.ShapeLib.Warp')

local BasicShapes = {}

-- BAD INPUT PROTECTION POLICY
-- Because we use so much randomness,
--   sometimes the input to the shape functions may be bad,
--   even in release.
-- For example, we may call Prism() and ask for fewer than 3 verts.
-- If any input is invalid, the warp function MUST
--   1. ASSERT, so that devs can debug the bad input AND
--   2. Set the input to a valid default value,
--      so that we prevent junk shapes & crashes in release.

-- Box(float resolution)
function BasicShapes.Box(res)
  -- default values
  res = res or 1
  -- bad input protection
  if res < 0 then
    assert(res > 0)
    res = 0
  end

  local self = Shape()
  self:addVertex(-1,  1, -1) -- 0
  self:addVertex( 1,  1, -1) -- 1
  self:addVertex(-1,  1,  1) -- 2
  self:addVertex( 1,  1,  1) -- 3

  self:addVertex(-1, -1, -1) -- 4
  self:addVertex( 1, -1, -1) -- 5
  self:addVertex(-1, -1,  1) -- 6
  self:addVertex( 1, -1,  1) -- 7

  self:addQuad(0, 2, 3, 1) -- top
  self:addQuad(4, 5, 7, 6) -- bottom
  self:addQuad(3, 7, 5, 1)
  self:addQuad(0, 4, 6, 2)
  self:addQuad(2, 6, 7, 3)
  self:addQuad(0, 1, 5, 4)

  return self:tessellate(res)
end

-- Prism(int stacks, int slices)
function BasicShapes.Prism (stacks, slices)
  -- default values
  stacks = stacks or 2
  slices = slices or 3
  -- bad input protection
  if stacks < 2 then
    assert(stacks >= 2)
    stacks = 2
  end
  if slices < 3 then
    assert(slices >= 3)
    slices = 3
  end

  local self = Shape()

  -- Verts
  for i = 0, stacks - 1 do
    local y = i / (stacks - 1) - 0.5
    for j = 0, slices - 1 do
      local t = 2 * j * math.pi / slices
      self:addVertex(math.cos(t)*0.5, y, math.sin(t)*0.5)
    end
  end

  -- Polys
  do -- Top Cap
    local poly = {}
    for i = 0, slices - 1 do
      poly[#poly + 1] = i % slices
    end
    self:addPoly(poly)
  end

  do -- Bottom Cap
    local poly = {}
    local offset = (stacks - 1) * slices
    -- NOTE : Bottom winding must be opposite top
    for i = slices - 1, 0, -1 do
      poly[#poly + 1] = offset + i % slices
    end
    self:addPoly(poly)
  end

  -- Side Quads
  for stack = 0, stacks - 2 do
    for slice = 0, slices - 1 do
      self:addQuad(
        stack * slices + slice,
        (stack + 1) * slices + slice,
        (stack + 1) * slices + (slice + 1) % slices,
        stack * slices + (slice + 1) % slices)
    end
  end

  return self
end

-- Pyramid (5 faced, rectangle bottom)
function BasicShapes.Pyramid ()
  local self = Shape()

  self
    :addVertex(   0, 0,    0) -- center bottom
    :addVertex(-0.5, 0,  0.5) -- bottom 4 verticies
    :addVertex(-0.5, 0, -0.5)
    :addVertex( 0.5, 0, -0.5)
    :addVertex( 0.5, 0,  0.5)
    :addVertex( 0, 0.5,    0) -- top

  self
    :addQuad(1, 2, 3, 4) -- bottom
    :addTri(5, 2, 1) -- 4 sides
    :addTri(5, 1, 4)
    :addTri(5, 4, 3)
    :addTri(5, 3, 2)

  return self
end

-- Icosahedron (20 sides)
function BasicShapes.Icosahedron ()
  local phi = (1.0 + math.sqrt(5)) / 2.0
  local self = Shape()

  -- YZ
  self
    :addVertex(0,  phi,  1)
    :addVertex(0,  phi, -1)
    :addVertex(0, -phi,  1)
    :addVertex(0, -phi, -1)

  -- XZ
  self
    :addVertex(-1, 0, -phi)
    :addVertex( 1, 0, -phi)
    :addVertex(-1, 0,  phi)
    :addVertex( 1, 0,  phi)

  -- XY
  self
    :addVertex(-phi,  1, 0)
    :addVertex( phi,  1, 0)
    :addVertex(-phi, -1, 0)
    :addVertex( phi, -1, 0)

  -- Cap 1
  self
    :addTri(1, 0, 9)
    :addTri(1, 9, 5)
    :addTri(1, 5, 4)
    :addTri(1, 4, 8)
    :addTri(1, 8, 0)

  -- cap 2
  self
    :addTri(7, 6, 2)
    :addTri(11, 7, 2)
    :addTri(3, 11, 2)
    :addTri(10, 3, 2)
    :addTri(6, 10, 2)

  -- sides
  self
    :addTri(9, 0, 7)
    :addTri(9, 7, 11)
    :addTri(5, 9, 11)
    :addTri(5, 11, 3)
    :addTri(5, 3, 4)
    :addTri(4, 3, 10)
    :addTri(4, 10, 8)
    :addTri(8, 10, 6)
    :addTri(0, 8, 6)
    :addTri(0, 6, 7)

  self:sphereize()
  return self
end

-- Ellipsoid (int res)
function BasicShapes.Ellipsoid (res)
  -- default values
  res = res or 20
  -- bad input protection
  if res < 3 then
    assert(res >= 3)
    res = 3
  end

  local self = Shape()

  local thetastack = math.pi / res
  local thetaslice = (2 * math.pi) / res

  -- verts
  self:addVertex(0, 1, 0)
  for stack = 1, res - 1 do
    local rx = math.sin(thetastack * stack)
    local rz = math.sin(thetastack * stack)
    for slice = 0, res - 1 do
      local x = math.cos(thetaslice * slice) * rx
      local y = math.cos(thetastack * stack)
      local z = math.sin(thetaslice * slice) * rz
      self:addVertex(x, y, z)
    end
  end
  self:addVertex(0, -1, 0)

  -- top tris
  for slice = 0, res - 2 do
    self:addTri(0, slice + 2, slice + 1)
  end
  self:addTri(0, 1, res)

  -- side quads
  for stack = 0, res - 3 do
    for slice = 0, res - 2 do
      local i1 = 1 + slice + (res * stack)
      local i2 = i1 + 1
      local i3 = 1 + slice + (res * (stack+1))
      local i4 = i3 + 1
      self:addQuad(i1, i2, i4, i3)
    end
    local i1 = res * (stack + 1)
    local i2 = 1 + (res * stack)
    local i3 = res * (stack + 2)
    local i4 = 1 + (res * (stack+1))
    self:addQuad(i1, i2, i4, i3)
  end

  -- bottom tris
  local lvi = self:getVertexCount() - 1
  for slice = 0, res - 2 do
    local i1 = lvi
    local i2 = (res-2)*res + slice + 1
    local i3 = (res-2)*res + slice + 2
    self:addTri(i1, i2, i3)
  end
  self:addTri(lvi, (res-1)*res, (res-2)*res + 1)

  return self:center()
end

-- Torus (fn* outer shape function (torus shape),
--        fn* inner shape function (segment shape),
--        float rOuter (torus radius),
--        float rInner (segment radius),
--        int stacks,
--        int slices)
-- Unliked the rest of the shape fns, the Torus actually takes
-- size input because warps won't change the ratio
-- of the size of the segments to the whole torus radius
function BasicShapes.Torus (outerFn, innerFn, rOuter, rInner, stacks, slices)
  -- default values
  outerFn = outerFn or Parametric.Circle()
  innerFn = innerFn or Parametric.Circle()
  rOuter = rOuter or 1
  rInner = rInner or 0.2
  stacks = stacks or 20
  slices = slices or 20
  -- bad input protection
  assert(rInner > 1e-6 and rOuter > 1e-6 and stacks >= 3 and slices >= 3)
  if rInner < 1e-6 then rInner = 0.2 end
  if rOuter < 1e-6 then rOuter = 1 end
  if stacks < 3 then stacks = 3 end
  if slices < 3 then slices = 3 end

  local self = Shape()
  do -- Vertices
    for stack = 0, stacks - 1 do
      local theta = (2.0 * math.pi) * (stack / stacks) -- Outer angle (stacks)
      local pOuter = outerFn(theta)
      for slice = 0, slices - 1 do
        local phi = (2.0 * math.pi) * (slice / slices) -- Inner angle (slices)
        local pInner = innerFn(phi)
        local x = pOuter.x * (rOuter + rInner * pInner.x)
        local y = pOuter.y * (rOuter + rInner * pInner.x)
        local z = rInner * pInner.y
        self:addVertex(x, y, z)
      end
    end
  end

  do -- Polys
    for stack = 0, stacks - 1 do
      -- Index offsets for this stack (stack1) and next stack (stack2)
      local stack1 = stack * slices
      local stack2 = ((stack + 1) % stacks) * slices
      for slice = 0, slices - 1 do
        -- Index offsets for this slice (slice1) and next slice (slice2)
        local slice1 = slice
        local slice2 = (slice + 1) % slices
        self:addQuad(
          stack1 + slice1,
          stack2 + slice1,
          stack2 + slice2,
          stack1 + slice2)
      end
    end
  end

  return self
end

-- IrregularPrism (RNG rng, int res, int verts [optional])
function BasicShapes.IrregularPrism (rng, res, numV)
  -- default values
  res = res or 2
  numV = numV or rng:getInt(4, 6)
  -- bad input protection
  assert(rng)
  if res < 2 then
    assert(res >= 2)
    res = 2
  end
  if numV < 3 then
    assert(numV >= 3)
    numV = 4
  end

  local self = Shape()

  local maxRadius = 1
  local height = 0.2
  local halfV = numV / 2

  -- Generate TWO lists of angles between 0-180 and then add them together
  -- to guaruntee that no angle > 180, which creates ugly shapes
  local angles = MathUtil.GenerateNumsThatAddToSum(halfV, math.pi, rng)
  if numV % 2 ~= 0 then halfV = halfV + 1 end
  local angles2 = MathUtil.GenerateNumsThatAddToSum(halfV, math.pi, rng)

  local j = 1
  for i = #angles + 1, #angles + #angles2 do
    table.insert(angles, angles2[j])
    j = j + 1
  end
  local radii = {}
  for i = 1, #angles do
    radii[i] = rng:getUniformRange(maxRadius/2.0, maxRadius)
  end

  -- create vertex list for base face
  local lastAngle = 0
  local dh = height / (res - 1)
  for j = 1, numV do
    local r = radii[j]
    local theta = 0
    if j ~= 1 then
      theta = lastAngle + angles[j]
    end
    local x = math.cos(theta) * r
    local z = math.sin(theta) * r
    self:addVertex(x, 0, z)
    lastAngle = theta
  end

  -- create poly for base face
  local face = {}
  for i = 0, #self.verts - 1  do
    face[#face+1] = i
  end
  self.polys[1] = face

  -- extrude face along y 'res' times
  local heightPerStack = 1.0 / res
  for i = 1, res do
    local pi = self:getPolyWithNormal(Vec3d(0, -1, 0))
    self:extrudePoly(pi, heightPerStack, Vec3d(1,1,1), Vec3d(0, -1, 0), true)
  end

  return self:center()
end

return BasicShapes
