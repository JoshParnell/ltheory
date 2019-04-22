local Entity = require('Game.Entity')

local Trigger = subclass(Entity, function (self, halfExtents)
  self:addTrigger(halfExtents)
end)

return Trigger
