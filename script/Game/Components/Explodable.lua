local Entity = require('Game.Entity')

--[[

  self:register(Event.Destroyed, explode)

  function explode (self, source)
    if self:getOwner() then self:getOwner():removeAsset(self) end
    local root = self:getRoot()
    for i = 1, 8 do
      local e = Entities.Explosion()
      e:setPos(self:getPos())
      e:modPos(rng:getSphere():scale(8.0 * self:getScale() * rng:getExp() ^ (1.0 / 3.0)))
      e.age = min(0.0, 0.5 - rng:getExp())
      root:addChild(e)
    end

    self:clearActions()
  end

--]]
