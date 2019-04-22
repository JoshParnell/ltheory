local Boxes = {}

-- Box(position, scale, rotation, bevel)
function Boxes.Box (p, s, r, b)
  return { p = p, s = s, r = r or Vec3d(0, 0, 0), b = b }
end

-- RandomBox(rng)
function Boxes.RandomBox (rng)
  local p = Vec3d(rng:getExp(), rng:getExp(), rng:getExp())
  local s = Vec3d(rng:getExp(), rng:getExp(), rng:getExp())
  local r = Vec3d(0, 0, 0)
  local b = Vec3d(
    rng:getUniformRange(0.125, 0.75),
    rng:getUniformRange(0.125, 0.75),
    rng:getUniformRange(0.125, 0.75))
  return Boxes.Box(p, s, r, b)
end

-- BoxesToMesh(list of boxes, bevel, resolution, mirror)
function Boxes.BoxesToMesh (boxes, bevel, res, mirror)
  if mirror == nil then mirror = true end
  local boxMesh = BoxMesh.Create()
  for i = 1, #boxes do
    local box = boxes[i]
    local b = box.b or Vec3d(bevel, bevel, bevel)
    boxMesh:add(
      box.p.x, box.p.y, box.p.z,
      box.s.x, box.s.y, box.s.z,
      box.r.x, box.r.y, box.r.z,
      b.x, b.y, b.z)
    if mirror == true then
      boxMesh:add(
        -box.p.x, box.p.y, box.p.z,
        0.99 * box.s.x, 0.99 * box.s.y, 0.99 * box.s.z,
        box.r.x, box.r.y, box.r.z,
        b.x, b.y, b.z)
    end
  end

  local mesh = boxMesh:getMesh(res)
  boxMesh:free()
  return mesh
end

-- Polar(radius function, stacks, slices, capped)
-- Different from Shapes.Prism() bc of construction method;
-- may be better for texturing, not as good for warping.
function Boxes.Polar (radiusFn, stacks, slices, capped)
  local self = Mesh.Create()
  local fvi = self:getVertexCount() -- first vertex index
  -- always get one less "side" than #stacks given by fn paramater
  -- because first & last column of vertexes is duplicated
  slices = slices + 1

  for i = 1, stacks do
    local v = (i - 1) / (stacks - 1)
    local y = 2.0 * v - 1.0
    local r = radiusFn(y)
    for j = 1, slices do
      local t = 2.0 * math.pi * (j - 1) / (slices - 1)
      local x = cos(t)
      local z = sin(t)
      local u = (j - 1) / (slices - 1)
      if i > 1 and j > 1 then
        local vi = self:getVertexCount()
        self:addQuad(vi - slices - 1, vi - 1, vi, vi - slices)
      end
      self:addVertex(r * x, y, r * z, x, 0, z, u, v)
    end
  end

  if capped then
    -- top cap
    for i = 1, slices - 1 do
      self:addTri(fvi, fvi + i, fvi + i + 1)
    end
    -- bottom cap
    local lvi = self:getVertexCount() - 1 -- last vertex index
    for i = 1, slices - 1 do
      self:addTri(lvi, lvi - i, lvi - i - 1)
    end
  end

  return self
end

return Boxes
