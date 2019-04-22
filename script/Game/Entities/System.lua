local Entity = require('Game.Entity')
local Dust = require('Game.Entities.Dust')
local Nebula = require('Game.Entities.Nebula')
require('Game.Content')

local System = subclass(Entity, function (self, seed)
  self:addChildren()
  self:addEconomy()

  -- NOTE : For now, we will use a flow component on the system to represent
  --        the summed net flow of all entities in the system. Seems natural,
  --        but should keep an eye on gameplay code to ensure this does not
  --        result in unexpected behavior
  self:addFlows()

  self.rng = RNG.Create(seed):managed()
  -- TODO : Will physics be freed correctly?
  self.physics = Physics.Create():managed()
  local starAngle = self.rng:getDir2()
  self.starDir = Vec3f(starAngle.x, 0, starAngle.y)
  self.nebula = Nebula(self.rng:get64(), self.starDir)
  self.dust = Dust()

  self.players = {}
  self.zones = {}
end)

function System:addZone (zone)
  insert(self.zones, zone)
end

function System:getZones ()
  return self.zones
end

function System:beginRender ()
  self.nebula:forceLoad()
  ShaderVar.PushFloat3('starDir', self.starDir.x, self.starDir.y, self.starDir.z)
  ShaderVar.PushTexCube('envMap', self.nebula.envMap)
  ShaderVar.PushTexCube('irMap', self.nebula.irMap)
end

function System:render (state)
  self:send(Event.Broadcast(state))
  self.dust:render(state)
  self.nebula:render(state)
end

function System:endRender ()
  ShaderVar.Pop('starDir')
  ShaderVar.Pop('envMap')
  ShaderVar.Pop('irMap')
end

function System:update (dt)
  local event = Event.Update(dt)
  Profiler.Begin('AI Update')
  for _, player in ipairs(self.players) do player:send(event) end
  Profiler.End()

  -- TODO : Pre / Post physics update? Nail down order-dependence in update
  Profiler.Begin('Broadcast Update')
  self:send(Event.Broadcast(event))
  Profiler.End()

  Profiler.Begin('Physics Update')
  self.physics:update(dt)
  Profiler.End()
end

-- Helpers For Testing ---------------------------------------------------------

local Item = require('Game.Item')

local kInventory = 100
local kStartCredits = 1000000
local kSystemScale = 10000

local cons = Distribution()
cons:add('b', 1.5)
cons:add('c', 2.8)
cons:add('d', 4.3)
cons:add('f', 2.2)
cons:add('g', 2.0)
cons:add('h', 6.1)
cons:add('j', 0.2)
cons:add('k', 0.8)
cons:add('l', 4.0)
cons:add('m', 2.4)
cons:add('n', 6.7)
cons:add('p', 1.9)
cons:add('q', 0.1)
cons:add('r', 6.0)
cons:add('s', 6.3)
cons:add('t', 9.1)
cons:add('v', 1.0)
cons:add('w', 2.4)
cons:add('x', 0.2)
cons:add('z', 0.1)

cons:add('ll', 0.4)
cons:add('ss', 0.6)
cons:add('tt', 0.9)
cons:add('ff', 0.2)
cons:add('rr', 0.6)
cons:add('nn', 0.6)
cons:add('pp', 0.2)
cons:add('cc', 0.3)

local vowels = Distribution()
vowels:add('a',  8.2)
vowels:add('e', 12.7)
vowels:add('i',  7.0)
vowels:add('o',  7.5)
vowels:add('u',  2.8)
vowels:add('y',  2.0)

vowels:add('ee',  1.2)
vowels:add('oo',  0.7)

local function genName (rng)
  local name = {}
  for i = 1, rng:getInt(2, 5) do
    insert(name, cons:sample(rng))
    insert(name, vowels:sample(rng))
  end
  name[1] = name[1]:upper()
  name = join(name)
  return name
end

function System:spawnAI (shipCount)
  local player = Entities.Player()
  for i = 1, shipCount do
    local ship = self:spawnShip()
    ship:setOwner(player)
  end
  player:addItem(Item.Credit, kStartCredits)
  player:pushAction(Actions.Think())
  insert(self.players, player)
  return player
end

function System:spawnAsteroidField (count, oreCount)
  local rng = self.rng
  local zone = Entities.Zone(format('%s Field', genName(rng)))
  zone.pos = rng:getDir3():scale(0.0 * kSystemScale * (1 + rng:getExp()))

  for i = 1, count do
    local pos
    if i == 1 then
      pos = zone.pos
    else
      pos = rng:choose(zone.children):getPos()
      pos = pos + rng:getDir3():scale((0.1 * kSystemScale) * rng:getExp() ^ rng:getExp())
    end

    local scale = 7 * (1 + rng:getExp() ^ 2)
    local asteroid = Entities.Asteroid(rng:get31(), scale)
    asteroid:setPos(pos)
    asteroid:setScale(scale)
    asteroid:setRot(rng:getQuat())

    if i > (count - oreCount) then
      asteroid:addYield(rng:choose(Item.T1), 1.0)
    end

    zone:add(asteroid)
    self:addChild(asteroid)
  end
  self:addZone(zone)
end

function System:spawnShip ()
  if not self.shipType then
    self.shipType = ShipType(self.rng:get31(), Gen.Ship.ShipFighter, 4)
  end
  local ship = self.shipType:instantiate()
  ship:setInventoryCapacity(kInventory)
  ship:setPos(self.rng:getDir3():scale(kSystemScale * (1.0 + self.rng:getExp())))
  self:addChild(ship)

  if true then
    while true do
      local thruster = Entities.Thruster()
      thruster:setScale(0.5 * ship:getScale())
      -- TODO : Does this leak a Thruster/RigidBody?
      if not ship:plug(thruster) then break end
    end
  end
  if true then
    while true do
      local turret = Entities.Turret()
      turret:setScale(2 * ship:getScale())
      -- TODO : Does this leak a Turret/RigidBody?
      if not ship:plug(turret) then break end
    end
  end
  return ship
end

function System:spawnStation ()
  local station = Entities.Station(self.rng:get31())
  local p = self.rng:getDisc():scale(kSystemScale)
  station:setPos(Vec3f(p.x, 0, p.y))
  station:setScale(100)
  -- station:setFlow(Item.Silver, self.rng:getUniformRange(-1000, 0))
  station:addMarket()
  station:addTrader()

  local prod = self.rng:choose(Production.All())
  station:addFactory()
  station:addProduction(prod)
  station:setName(format('%s %s',
    genName(self.rng),
    prod:getName()))
  self:addChild(station)
  return station
end

return System
