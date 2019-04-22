-- TODO : Seems like there's a unification opportunity here as well. Certainly
--        integrity and capacitor should be unified: all the 'energies' of an
--        entity should be stored in a kind of 'energy inventory' -- to be used
--        by shields, armor, hull, capacitor, and anything else that uses a
--        similar 'virtual currency'

local Entity = require('Game.Entity')

function Entity:addCapacitor (max, rate)
  assert(not self.charge)
  assert(max)
  assert(rate)
  self.charge = max
  self.chargeMax = max
  self.chargeRate = rate
  self:register(Event.Update, Entity.updateCapacitor)
end

function Entity:discharge (value)
  if not self.charge then return false end
  if self.charge < value then return false end
  self.charge = self.charge - value
  return true
end

function Entity:getCharge ()
  assert(self.charge)
  return self.charge or 0
end

function Entity:getChargeMax ()
  assert(self.charge)
  return self.chargeMax or 0
end

function Entity:getChargeNormalized ()
  assert(self.charge)
  if not self.charge then return 0 end
  return self.charge / self.chargeMax
end

function Entity:hasCharge ()
  return self.charge ~= nil
end

function Entity:setCharge (value, max, rate)
  assert(self.charge)
  self.charge = value
  self.chargeMax = max
  self.chargeRate = rate
end

function Entity:updateCapacitor (state)
  if self:isDestroyed() then return end
  self.charge = min(self.chargeMax, self.charge + state.dt * self.chargeRate)
end
