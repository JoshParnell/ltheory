local Entity = require('Game.Entity')

local Zone = subclass(Entity, function (self, name)
  self.name = name
  self.children = {}
end)

function Zone:add (e)
  insert(self.children, e)
end

function Zone:getChildren ()
  return self.children
end

function Zone:getName ()
  return self.name
end

function Zone:getPos ()
  return self.pos
end

function Zone:sample (rng)
  return rng:choose(self.children)
end

return Zone
