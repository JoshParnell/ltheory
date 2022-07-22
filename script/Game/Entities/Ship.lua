local Entity = require('Game.Entity')
local Material = require('Game.Material')

local Ship = subclass(Entity, function (self, proto)
  self:addActions()
  self:addCapacitor(100, 10)
  self:addChildren()
  self:addExplodable()
  self:addHealth(100, 10)
  self:addInventory(100)
  -- TODO : This will create a duplicate BSP because proto & RigidBody do not
  --        share the same BSP cache. Need unified cache.
  self:addRigidBody(true, proto.mesh)
  self:addSockets()
  self:addVisibleMesh(proto.mesh, Material.Metal())
  self:addThrustController()

  -- TODO : Suggestive that JS-style prototype objects + 'clone' would work
  --        better for ShipType et al
  for type, elems in pairs(proto.sockets) do
    for i, pos in ipairs(elems) do
      self:addSocket(type, pos, true)
    end
  end

  self:setDrag(0.75, 4.0)
  self:setScale(proto.scale)

  local mass = 50.0 * (self:getRadius() ^ 3.0)
  self:setMass(mass)
end)

-- TODO : Calculate true top speed based on max thrust & drag factor
function Ship:getTopSpeed ()
  return 100
end

return Ship
