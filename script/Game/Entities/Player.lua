local Entity = require('Game.Entity')

local Player = subclass(Entity, function (self)
  self:addActions()
  self:addAssets()
  self:addDispositions()
  self:addInventory(0)
  self.controlling = nil
end)

function Player:getControlling ()
  return self.controlling
end

function Player:getRoot ()
  if not self.controlling then return nil end
  return self.controlling:getRoot()
end

function Player:setControlling (target)
  self.controlling = target
end

return Player
