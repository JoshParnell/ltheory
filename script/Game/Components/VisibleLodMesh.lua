local Entity = require('Game.Entity')

function Entity:addVisibleLodMesh (mesh, material)
  assert(not self.mesh)
  assert(mesh)
  assert(material)
  self.mesh = mesh
  self.material = material
  self:register(Event.Render, Entity.renderVisibleLodMesh)
end

function Entity:renderVisibleLodMesh (state)
  if state.mode == BlendMode.Disabled then
    self.material:start()
    self.material:setState(self)
    self.mesh:draw(state.eye:distanceSquared(self:getPos()) / (self:getScale() ^ 2.0))
    self.material:stop()
  end
end
