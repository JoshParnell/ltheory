local Entity = require('Game.Entity')

-- TODO : Warn if self.credits >= Math.Float64MaxInt (credits will no
--        longer work correctly as integers)
-- TODO : Probably unify with inventory, just store credits as special item
--        in player inventory as we do in econ sandbox?

function Entity:addCredits (count)
  assert(count >= 0)
  if not self.credits then self.credits = 0 end
  self.credits = self.credits + count
end

function Entity:getCredits ()
  return self.credits or 0
end

function Entity:hasCredits (count)
  return self:getCredits() >= count
end

function Entity:removeCredits (count)
  assert(self:hasCredits(count))
  self.credits = self.credits - count
end
