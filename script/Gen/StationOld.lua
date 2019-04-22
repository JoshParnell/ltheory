local Gen      = require('Gen.GenUtil')
local Boxes    = require('Gen.Boxes')
local MeshUtil = require('Gen.MeshUtil')

local GenMesh = {}
GenMesh.__index = GenMesh

local function ClampExp (k, t)
  return exp(k * max(0.0, t))
end

function GenMesh:add (p, s, r, b)
  self.boxMesh:add(p.x, p.y, p.z, s.x, s.y, s.z, r.x, r.y, r.z, b, b, b)
end

function GenMesh:addWarp (fn)
  self.warps[#self.warps + 1] = fn
end

function GenMesh:column (rng, h, pieces, r)
  local dh = h / pieces
  for i = 0, pieces - 1 do
    local y = i / pieces
    y = 2.0 * y - 1.5
    local radius = 0.1 + 0.4 * r * rng:getExp() ^ 0.5 * ClampExp(-0.5, 1.0 - y)
    self:add(Vec3f(0, h * y, 0), Vec3f(radius, 1.5 * dh, radius), Vec3f(0, 0, 0), 0.25)
  end
end

function GenMesh:ring (rng, h, r, spokes, th)
  local o = Vec3f(0, h, 0)
  for i = 0, spokes - 1 do
    local t = i / spokes
    local angle = 2.0 * math.pi * t
    local dir = Vec3f(cos(angle), 0, sin(angle))
    local rot = Vec3f(math.pi / 2.0 - angle, 0, 0)
    self:add(o + dir:scale(0.5 * r), Vec3f(0.2, 0.1, 0.5 * r), rot, 0.15)
    self:add(o + dir:scale(r + th), Vec3f(0.5, 0.5, th), rot, 0.25)
    self:add(o + dir:scale(0.5 * r), Vec3f(0.5, 0.2, 1.0), rot, 0.5)
  end
end

function GenMesh:finalize (res)
  local mesh   = self.boxMesh:getMesh(res)
  local vCount = mesh:getVertexCount()
  local vData  = mesh:getVertexData()

  for i = 0, vCount - 1 do
    local p = Vec3f(vData[i].px, vData[i].py, vData[i].pz)
    local dp = Vec3f(0, 0, 0)
    for j = 1, #self.warps do
      dp:iadd(self.warps[j](p))
    end
    vData[i].px = p.x + dp.x
    vData[i].py = p.y + dp.y
    vData[i].pz = p.z + dp.z
  end

  mesh:splitNormals(0.99)
  mesh:computeAO(0.3 * mesh:getRadius())
  return mesh
end

local function pointAttractor (center, radius)
  return function (p)
    local dp = center - p
    return dp:scale(exp(-dp:length() / radius))
  end
end

local function generateStationOld (seed)
  local rng = RNG.Create(seed)
  local self = setmetatable({
    boxMesh = BoxMesh.Create(),
    warps = {},
  }, GenMesh)

  self:ring(rng, -1, 4.0, 8, 0.05)
  self:ring(rng,  0, 8.0, 2 * rng:getInt(2, 8), 0.1)
  self:ring(rng,  1, 3.0, 4, 0.05)
  self:ring(rng, -4, 2.0, 6, 0.05)
  self:column(rng, 8, 2 * rng:getInt(8, 16), 2)

  self:addWarp(pointAttractor(Vec3f(0,  10, 0), 8.0 * rng:getUniform()))
  self:addWarp(pointAttractor(Vec3f(0, -10, 0), 8.0 * rng:getUniform()))

  local mesh = self:finalize(6)
  self.boxMesh:free()
  rng:free()
  return mesh
end

return generateStationOld
