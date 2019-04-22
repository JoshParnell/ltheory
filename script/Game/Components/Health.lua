local Entity = require('Game.Entity')

function Entity:addHealth (max, rate)
  assert(not self.health)
  assert(max)
  assert(rate)
  self.health = max
  self.healthMax = max
  self.healthRate = rate
  self:register(Event.Update, Entity.updateHealth)
end

function Entity:damage (amount, source)
  assert(self.health)
  if self.health <= 0 then return end
  self.health = max(0, self.health - amount)
  self:sendEvent(Event.Damaged, amount, source)
  if self.health <= 0 then
    self:sendEvent(Event.Destroyed, source)
  end
end

function Entity:getHealth ()
  assert(self.health)
  return self.health
end

function Entity:getHealthNormalized ()
  assert(self.health)
  return self.health / self.healthMax
end

function Entity:getHealthPercent ()
  assert(self.health)
  return 100.0 * self.health / self.healthMax
end

function Entity:hasHealth ()
  return self.health ~= nil
end

-- WARNING : Note the subtlety that isAlive and isDestroyed are NOT
--           complementary! An asteroid is not alive, but neither has it been
--           destroyed. Both 'alive' and 'destroyed' require health to be true.

function Entity:isAlive ()
  return self.health and self.health > 0
end

function Entity:isDestroyed ()
  return self.health and self.health <= 0
end

function Entity:setHealth (value, max, rate)
  assert(self.health)
  self.health = value
  self.healthMax = max
  self.healthRate = rate
end

function Entity:updateHealth (state)
  if self:isDestroyed() then return end
  self.health = min(self.healthMax, self.health + state.dt * self.healthRate)
end
