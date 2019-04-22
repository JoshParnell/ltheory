local Entities = requireAll('Game.Entities')
local Actions = requireAll('Game.Actions')

local TestEcon = Application()
local rng = RNG.Create(10)

local kAssets = 5
local kPlayers = 1
local kStations = 2
local kFields = 5
local kFieldSize = 200

require('Game.Content')

function TestEcon:getWindowMode ()
  return Bit.Or32(WindowMode.Shown, WindowMode.Resizable)
end

function TestEcon:getTitle ()
  return 'Economy Simulation'
end

function TestEcon:onInit ()
  self.canvas = UI.Canvas()
  self.system = Entities.System(rng:get64())
  self.tradeAI = Entities.Player()
  self.tradeAI:addItem(Item.Credit, 1e10)
  self.tradeShip = Entity()
  self.tradeShip:addInventory(1e10)
  self.tradeShip:setOwner(self.tradeAI)

  for i = 1, kStations do self.system:spawnStation() end
  for i = 1, kPlayers do self.system:spawnAI(kAssets) end
  for i = 1, kFields do self.system:spawnAsteroidField(kFieldSize, 1) end

  self.canvas:add(SystemMap(self.system))

  self.system:register(Event.Debug, function (system, state)
    local ctx = state.context
    ctx:text('AI Players')
    ctx:indent()
    for i, v in ipairs(system.players) do
      ctx:text('[%d] : %d credits', i, v:getItemCount(Item.Credit))
    end
    ctx:undent()
  end)
end

function TestEcon:onInput ()
  self.canvas:input()
end

function TestEcon:onUpdate (dt)
  self.system:update(dt)
  self.canvas:update(dt)
end

function TestEcon:onDraw ()
  self.canvas:draw(self.resX, self.resY)
end

return TestEcon
