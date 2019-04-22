local Sandbox  = {}
local sqrt     = sqrt

local function box ()
  return PolyMesh()
    :addVertex( 1, 1, 1)
    :addVertex(-1, 1, 1)
    :addVertex( 1,-1, 1)
    :addVertex(-1,-1, 1)
    :addVertex( 1, 1,-1)
    :addVertex(-1, 1,-1)
    :addVertex( 1,-1,-1)
    :addVertex(-1,-1,-1)
    :addQuad(0, 1, 3, 2)
    :addQuad(4, 6, 7, 5)
    :addQuad(0, 4, 5, 1)
    :addQuad(2, 3, 7, 6)
    :addQuad(0, 2, 6, 4)
    :addQuad(1, 5, 7, 3)
end

local function tet ()
  return PolyMesh()
    :addVertex( sqrt(8/9), -1/3,          0)
    :addVertex(-sqrt(2/9), -1/3,  sqrt(2/3))
    :addVertex(-sqrt(2/9), -1/3, -sqrt(2/3))
    :addVertex(         0,    1,          0)
    :addTri(0, 1, 2) :addTri(0, 2, 3) :addTri(1, 3, 2) :addTri(0, 3, 1)
end

local function ico ()
  local p = (1.0 + sqrt(5)) / 2.0
  return PolyMesh()
    :addVertex(0,  p,  1) :addVertex(0, p, -1) :addVertex( 0, -p, 1) :addVertex(0, -p, -1)
    :addVertex(-1, 0, -p) :addVertex(1, 0, -p) :addVertex(-1,  0, p) :addVertex(1,  0,  p)
    :addVertex(-p,  1, 0) :addVertex(p, 1,  0) :addVertex(-p, -1, 0) :addVertex(p, -1,  0)
    :addTri(1, 0, 9)  :addTri(1, 9, 5)  :addTri(1, 5, 4)  :addTri(1, 4, 8)  :addTri(1, 8, 0)
    :addTri(7, 6, 2)  :addTri(11, 7, 2) :addTri(3, 11, 2) :addTri(10, 3, 2) :addTri(6, 10, 2)
    :addTri(9, 0, 7)  :addTri(9, 7, 11) :addTri(5, 9, 11) :addTri(5, 11, 3) :addTri(5, 3, 4)
    :addTri(4, 3, 10) :addTri(4, 10, 8) :addTri(8, 10, 6) :addTri(0, 8, 6)  :addTri(0, 6, 7)
end

local function station1 (rng)
  local self = ico()
  self:selectAll()
  for i = 1, 8 do
    self:extrude(0.1, 0.5)
    self:extrude(0.5, 1.0)
    self:extrude(0.8, 1.0 + 1.1^i)
  end
  self:selectSubset(function (face) return abs(self:getFaceNormal(face).y) < 0.25 end)
  self:warp(function (v)
    local r = sqrt(v.x*v.x + v.z*v.z)
    v.y = v.y * (1.0 + 2.0 * exp(-r / 10.0))
  end)

  for i = 1, 2 do
    self:stellate(0.5)
    self:extrude(0.0, 0.1)
    self:extrude(4.0, 1.0)
    self:extrude(0.0, 10.0)
  end
  self:stellate(0.5)
  self:extrude(0.5)
  self:selectAll()
  self:stellate(0)
  self:scale(0.25, 0.25, 0.25)
  return self
end

function Sandbox.Station (seed)
  local rng = RNG.Create(seed + 0x58023)
  local self = box()
  self:selectAll()
  for i = 1, 0 do
    self:extrude( 0.0, 0.7)
    self:extrude(-0.2, 1.0)
    self:extrude( 0.0, 0.5)
    self:extrude( 0.3, 0.5)
    -- self:extrude( 1.0, 0.8)
    -- self:extrude( 0.0, 0.5)
    -- self:extrude(-0.5, 0.9)
    -- self:extrude( 0.0, 0.50)
    -- self:extrude( 1.0, 1.0)
  end
  -- self:extrude( 0.0, 0.75)
  -- self:extrude(-0.2, 0.10)

  -- self:triangulateCentroid()
  self = self:bevel(0.10)
  self = self:bevel(0.20)
  self = self:bevel(0.40)
  -- self = self:bevel(0.25)
  -- self = self:bevel(0.2)
  self:refine()
  return self:finalize(0.3)
end

return Sandbox
