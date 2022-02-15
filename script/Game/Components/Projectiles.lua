local Entity = require('Game.Entity')
local Pulse = require('Game.Entities.Pulse')

function Entity:addProjectiles ()
  assert(not self.projectiles)
  self.projectiles = {}
  self.projectileRefs = Env.Util.RefTable()
end

function Entity:addProjectile (child, source)
  assert(self.projectiles)
  local e = Pulse:new()
  e.source = self.projectileRefs:acquire(source)
  insert(self.projectiles, e)
  return e
end

function Entity:renderProjectiles (state)
  Pulse.Render(self.projectiles, state)
end

function Entity:updateProjectiles (dt)
  Pulse.UpdatePrePhysics(self.projectiles, dt)
  -- Pulse.Update(self.projectiles)
end
