local SystemGenerator = require('Gen.SystemGenerator')
local Asteroid = require('Game.Entities.Asteroid')
local Zone = require('Game.Entities.Zone')

local kExpFactor  = 0.75
local kFieldScale = 750

function SystemGenerator:addAsteroidField (center, count)
  local rng = self.rng
  local zone = Zone('Asteroid Field')
  for i = 1, count do
    local scale = 7.0 * (1.0 + rng:getExp() ^ 2.0)
    local e = Asteroid(rng:get31(), scale)
    if i == 1 then
      e:setPos(center)
    else
      e:setPos(zone:sample(rng):getPos())
    end
    e:modPos(rng:getDir3():scale(kFieldScale * rng:getExp() ^ kExpFactor))
    e:setRot(rng:getQuat())
    self:add(e)
    zone:add(e)
  end
  self:addZone(zone)
end
