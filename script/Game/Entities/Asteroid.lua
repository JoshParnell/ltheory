local Entity = require('Game.Entity')
local Material = require('Game.Material')

local cache = {}

local function getMesh (seed)
  local seed = tonumber(seed) % 1
  if not cache[seed] then
    cache[seed] = Gen.Asteroid(seed)
  end
  return cache[seed]
end

local Asteroid = subclass(Entity, function (self, seed, scale)
  local mesh = getMesh(seed)
  self:addRigidBody(true, mesh:get(0))
  self:addVisibleLodMesh(mesh, Material.Rock())

  self:setDrag(0.2, 0.2)
  self:setScale(scale)

  local mass = self:getRadius() ^ 3.0
  self:setMass(mass)
end)

return Asteroid
