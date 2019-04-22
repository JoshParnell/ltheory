local Entity = require('Game.Entity')
local Material = require('Game.Material')

local Sphere = subclass(Entity, function (self)
  local mesh = Gen.ShapeLib.BasicShapes.Ellipsoid():finalize()
  self:addRigidBody(true, mesh)
  self:addVisibleMesh(mesh, Material.Debug())
end)

return Sphere
