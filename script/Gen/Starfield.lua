local function generateStarfield (rng, count)
  local self = Mesh.Create()
  local brightness = 0.015
  local distance = 1e6
  local radius = 1.0 / 30.0

  local stars = {}
  insert(stars, rng:getDir3():scale(rng:getExp()))
  local sum = stars[1]
  for i = 1, count do
    local p = rng:choose(stars)
    p = p + rng:getDir3():scale(rng:getExp())
    -- p.y = p.y * 0.5 * rng:getExp()
    insert(stars, p)
    sum = sum + p
  end

  local source = sum:scale(1.0 / #stars)

  for i = 1, #stars do
    local K = rng:getUniform()
    local c = Color.FromTemperature(Math.Lerp(1600, 15000, K), 2.0):toVec3()
    c = c:scale(brightness * rng:getExp() ^ 2.5)

    local N = (stars[i] - source):normalize()
    local T, B = Math.OrthoBasis(N)

    N = N:scale(distance)
    T = T:scale(radius * distance)
    B = B:scale(radius * distance)

    local index = self:getVertexCount()
    local p1, p2, p3, p4 = N - T, N + B, N + T, N - B
    self:addVertex(p1.x, p1.y, p1.z, c.x, c.y, c.z, -1,  0)
    self:addVertex(p2.x, p2.y, p2.z, c.x, c.y, c.z,  0,  1)
    self:addVertex(p3.x, p3.y, p3.z, c.x, c.y, c.z,  1,  0)
    self:addVertex(p4.x, p4.y, p4.z, c.x, c.y, c.z,  0, -1)
    self:addQuad(index, index + 1, index + 2, index + 3)
  end

  return self
end

return generateStarfield
