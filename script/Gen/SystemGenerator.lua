local System = require('Game.Entities.System')

local SystemGenerator = class(function (self, seed)
  self.rng = RNG.Create(seed)
  self.seed = seed
  self.system = System(seed)
end)

function SystemGenerator:add (child)
  self.system:addChild(child)
end

function SystemGenerator:addZone (zone)
  self.system:addZone(zone)
end

function SystemGenerator:finalize ()
  self.rng:free()
  return self.system
end

return SystemGenerator
