local Entity = require('Game.Entity')

function Entity:addVisibleMesh (mesh, material)
  assert(not self.mesh)
  assert(mesh)
  assert(material)
  self.mesh = mesh
  self.material = material
  self:register(Event.Render, Entity.renderVisibleMesh)
end

function Entity:renderVisibleMesh (state)
  if state.mode == BlendMode.Disabled then
    self.material:start()
    self.material:setState(self)
    self.mesh:draw()
    self.material:stop()
  end
end
