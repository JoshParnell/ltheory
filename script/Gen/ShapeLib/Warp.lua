local Shape = require('Gen.ShapeLib.Shape')
local wrap  = Math.Wrap

-- BAD INPUT PROTECTION POLICY
-- Because we use so much randomness,
--   sometimes the input to the warp functions may be bad,
--   even in release.
-- For example, we may call scale() with 0 or negative values.
-- If any input is invalid, the warp function MUST
--   1. ASSERT, so that devs can debug the bad input AND
--   2. Return the original shape, unaffected,
--      so that we prevent junk shapes & crashes in release.

-- Warp (function* fn)
-- It is assumed that the warp function takes a vertex
--   and operates on it in-place.
function Shape:warp (fn)
  -- bad input protection
  if fn == nil then
    assert(fn ~= nil)
    return self
  end

  for i = 1, #self.verts do
    fn(self.verts[i])
  end
  return self
end

-- Scale (float sx, float sy [optional], float sz [optional])
function Shape:scale (sx, sy, sz)
  -- default values
  local sy = sy or sx
  local sz = sz or sx
  -- bad input protection
  if not sx or sx < 1e-6 or sy < 1e-6 or sz < 1e-6 then
    return self
  end

  for i = 1, #self.verts do
    local v = self.verts[i]
    v.x = v.x * sx
    v.y = v.y * sy
    v.z = v.z * sz
  end
  return self
end

-- Center (float x [optional], float y [optional], float z [optional])
function Shape:center (x, y, z)
  local x, y, z = x or 0, y or 0, z or 0
  local c = self:getCenter()
  return self:translate(x - c.x, y - c.y, z - c.z)
end

-- Translate (float dx, float dy, float dz)
function Shape:translate (dx, dy, dz)
  local dx, dy, dz = dx or 0, dy or 0, dz or 0
  if dx == 0 and dy == 0 and dz == 0 then return self end

  for i = 1, #self.verts do
    local v = self.verts[i]
    v.x = v.x + dx
    v.y = v.y + dy
    v.z = v.z + dz
  end
  return self
end

-- Mirrors the shape across the specified axes
function Shape:mirror(x, y, z)
  -- invert pos of all verts
  for i = 1, #self.verts do
    local v = self.verts[i]
    if x then v.x = v.x * -1 end
    if y then v.y = v.y * -1 end
    if z then v.z = v.z * -1 end
  end

  -- invert winding order if odd number of mirrors applied
  if not ((x and y and not z)
       or (x and z and not y)
       or (y and z and not x)) then
    for i = 1, #self.polys do
      self:invertPoly(i)
    end
  end

  return self
end

-- Rotate (float dx, float dy, float dz)
-- dx, dy, dz are taken as yaw, pitch, roll in radians
function Shape:rotate(dx, dy, dz)
  local dx, dy, dz = dx or 0, dy or 0, dz or 0
  if dx == 0 and dy == 0 and dz == 0 then return self end

  local rotMatrix = Matrix.YawPitchRoll(dx, dy, dz)
  for i = 1, #self.verts do
    local v = self.verts[i]
    self.verts[i] = rotMatrix:mulPoint(v):toVec3d()
  end
  return self
end

-- AxialPush (RNG rng)
function Shape:axialPush (rng)
  assert(rng)
  local a = 0.2 * rng:getExp()
  local b = 0.8 * rng:getErlang(2)
  local c = 0.2 * rng:getExp()
  self:warp(function (p)
    p.x = p.x + a * Math.Sign(p.x)
    p.y = p.y + b * Math.Sign(p.y)
    p.z = p.z + c * Math.Sign(p.z)
  end)
  return self
end

-- Sphereize (float p)
-- Normalize all vertex positions,
--   thereby projecting the piece onto the unit sphere.
-- Optional p parameter allows specifying a p-norm
--   other than the standard p=2 norm.
function Shape:sphereize (p)
  local p = p or 2
  self:warp(function (v)
    local vp = v:pNormalize(p)
    v.x, v.y, v.z = vp.x, vp.y, vp.z
  end)
  return self
end

-- ExpStretch (RNG rng)
function Shape:expStretch(rng)
  assert(rng)
  local a = 1.0 + rng:getExp()
  local b = abs(rng:getGaussian())
  local c = rng:getExp()
  self:warp(function (p)
    local r = sqrt(p.x * p.x + p.z * p.z)
    p.y = p.y * (1.0 + c * exp(-a * r ^ b))
  end)
  return self
end

-- Bevel (float t [0.0-1.0] [optional])
function Shape:bevel (t)
  t = t or 0.2
  if t < 0.0 or t > 1.0 then
    assert(t >= 0.0 and t <= 1.0)
    return self
  end

  local top = self:getTopology()
  if top == nil then -- non-manifold shape; can't bevel
    return self
  end

  local result = Shape()
  local edgeMap = {}
  local e2v = {} -- Directed Edge to Bevel Corner { ref, subindex }
  local vc = self:getVertexCount()

  -- Create bevel corner faces
  for i = 1, #self.verts do
    local v = self.verts[i]
    local faces = top.v2f[i - 1]
    local newFace = {}
    for j = 1, #faces do
      local face = faces[j]
      newFace[j] = result:getVertexCount()
      local nextVert = face.ref[wrap(face.index + 1, 1, #face.ref)]
      e2v[vc * (i - 1) + nextVert] = { newFace, j }
      local p = v:lerp(self:getFaceCenter(face.ref), t)
      result:addVertex(p.x, p.y, p.z)
    end
    result:addPoly(newFace)
  end

  -- Connect bevelled corners with quads
  for i = 1, #self.verts do
    local faces = top.v2f[i - 1]
    local verts = top.v2v[i - 1]
    for j = 1, #verts do
      if (i - 1) < verts[j] then
        local corner1 = e2v[vc * (i - 1) + verts[j]]  -- Incoming
        local corner2 = e2v[vc * verts[j] + (i - 1)]  -- Outgoing
        local f1, i1 = corner1[1], corner1[2]
        local f2, i2 = corner2[1], corner2[2]
        result:addQuad(
          f1[i1],
          f1[wrap(i1 - 1, 1, #f1)],
          f2[i2],
          f2[wrap(i2 - 1, 1, #f2)])
      end
    end
  end

  -- Re-connect original faces
  for i = 1, #self.polys do
    local face = self.polys[i]
    local newFace = {}
    for j = 1, #face do
      local v1 = face[j]
      local v2 = face[wrap(j + 1, 1, #face)]
      local corner = e2v[vc * v1 + v2]
      local cf, ci = corner[1], corner[2]
      newFace[j] = cf[ci]
    end
    result:addPoly(newFace)
  end

  return result
end

-- Extrude (float length, float scale)
-- Even extrusion of all polys
function Shape:extrude (length, scale)
  -- default vals
  local length = length or 0.5
  local scale = scale or Vec3d(1,1,1)
  -- bad input protection
  if scale:length() < 1e-6 then
    assert(scale:length() > 1e-6)
    return self
  end

  local ps = #self.polys
  for i = 1, ps do
    -- extrudePoly protects against bad polys
    self:extrudePoly(i, length, scale)
  end
  return self
end

-- Stellate (float length)
function Shape:stellate (length)
  length = length or 1

  local newPolys = {}
  for i = 1, #self.polys do
    -- triangulate protects against bad polys
    self:triangulatePolyCentroid(i, length)
  end

  return self
end

-- Tessellate (int n)
-- Adds verticies to add detail to any mesh
function Shape:tessellate (n)
  if n == 0 then return self end

  n = n or 1
  if n < 1 then
    assert(n >= 0)
    return self
  end

  for j = 1, n do -- # of tessellations
    -- triangulates any polys of degree > 4
    -- (leaves tris & quads alone till next step)
    for i = 1, #self.polys do
      if #self.polys[i] > 4 then
        self:triangulatePolyCentroid(i)
      end
    end
    -- splits quads & tris into 4
    -- without adding any duplicate verticies
    local edgeMap = {}
    local vc = self:getVertexCount()
    for i = 1, #self.polys do
      if #self.polys[i] == 3 then
        self:triangulateTriEven(i, edgeMap, vc)
      elseif #self.polys[i] == 4 then
        self:tessellateQuad(i, edgeMap, vc)
      end
    end
  end
  return self
end

-- Greeble (RNG rng, int n, float low, float high)
-- Tessellates shape n times
--  then extrudes all polys with random length between low, high
function Shape:greeble (rng, n, low, high, greebleChance, scaleChance)
  n = n or rng:getInt(1, 4)
  low = low or 0.05
  high = high or 0.2
  greebleChance = greebleChance or 0.33
  scaleChance = scaleChance or 0
  if low > high then
    assert(low < high)
    return self
  end

  self:tessellate(n)

  local ps = #self.polys
  for i = 1, ps do
    if greebleChance == 1.0 or rng:chance(greebleChance) then
      local length = rng:getUniformRange(low, high)
      -- extrudePoly protects against bad polys
      if scaleChance == 1.0 or (scaleChance ~= 0 and rng:chance(scaleChance)) then
        local scale = Vec3d(
          rng:getUniformRange(0.2, 1.0),
          rng:getUniformRange(0.2, 1.0),
          rng:getUniformRange(0.2, 1.0)
        )
        self:extrudePoly(i, length, scale)
      else
        self:extrudePoly(i, length)
      end
    end
  end
  return self
end
