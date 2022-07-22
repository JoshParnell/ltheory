local Entity = require('Game.Entity')

local rng = RNG.Create(1231)

local function explode (self, source)
  if self:getOwner() then self:getOwner():removeAsset(self) end
  local root = self:getRoot()
  for i = 1, 8 do
    local p = self:getPos() + rng:getSphere():scale(8.0 * self:getScale() * rng:getExp() ^ (1.0 / 3.0))
    local v = self:getVelocity()
    local e = Entities.Explosion(p, v, min(0.0, 0.5 - rng:getExp()))
    root:addChild(e)
  end

  self:clearActions()
end

function Entity:addExplodable ()
  assert(not self.explodable)
  self.explodable = true
  self:register(Event.Destroyed, explode)
end

function Entity:hasExplodable ()
  return self.explodable ~= nil
end
