local Generator       = require('Gen.Generator')
local SystemGenerator = require('Gen.SystemGenerator')
local Asteroid        = require('Game.Entities.Asteroid')
local Planet          = require('Game.Entities.Planet')
local Station         = require('Game.Entities.Station')
local System          = require('Game.Entities.System')

local kSystemScale = 5000.0

local function generateSystemBasic (seed)
  local self = SystemGenerator(seed)
  local rng = self.rng

  do -- Asteroid fields
    for i = 1, Config.gen.nFields do
      local center = rng:getDir3():scale(kSystemScale * (rng:getExp() ^ (1.0 / 3.0)))
      center = center + Config.gen.origin
      self:addAsteroidField(center, Config.gen.nFieldSize(rng))
    end
  end

  do -- Stations
    for i = 1, Config.gen.nStations do
      local e = Station(rng:get31())
      local dir = rng:getDir2()
      e:setScale(100.0)
      e:setPos(Vec3f(dir.x, 0, dir.y):scale(kSystemScale))
      e:modPos(Config.gen.origin)
      self:add(e)
    end
  end

  do -- Planets
    for i = 1, Config.gen.nPlanets do
      local e = Planet(rng:get31())
      local dir = rng:getDir2()
      e:setScale(Config.gen.scalePlanet)
      e:setPos(Vec3f(dir.x, 0, dir.y):scale(e:getScale() + kSystemScale * (0.25 + 0.75 * sqrt(rng:getUniform()))))
      e:modPos(Config.gen.origin)
      local center = e:getPos()
      local rc = 2.00 * e:getRadius()
      local rw = 0.20 * e:getRadius()

      do -- Planetary belts
        for j = 1, Config.gen.nBeltSize(rng) do
          local r = rc + rng:getUniformRange(-rw, rw) * (0.5 + 0.5 * rng:getExp())
          local h = 0.1 * rw * rng:getGaussian()
          local dir = rng:getDir2()
          local scale = 5.0 * (1.0 + rng:getExp() ^ 2.0)
          local e2 = Asteroid(rng:get31(), scale)
          e2:setPos(center + Vec3f(r * dir.x, h, r * dir.y))
          e2:setRot(rng:getQuat())
          self:add(e2)
        end
        self:add(e)
      end
    end
  end

  return self:finalize()
end

Generator.Add('System', 1.0, generateSystemBasic)
