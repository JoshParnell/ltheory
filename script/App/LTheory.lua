local Entities = requireAll('Game.Entities')
local DebugControl = require('Game.Controls.DebugControl')

local LTheory = Application()
local rng = RNG.FromTime()

function LTheory:generate ()
  self.seed = rng:get64()
  if true then
    -- self.seed = 7035008865122330386ULL
    -- self.seed = 15054808765102574876ULL
    -- self.seed = 1777258448479734603ULL
    -- self.seed = 5023726954312599969ULL
  end
  printf('Seed: %s', self.seed)

  if self.system then self.system:delete() end
  self.system = Entities.System(self.seed)

  local ship
  do -- Player Ship
    ship = self.system:spawnShip()
    ship:setPos(Config.gen.origin)
    ship:setFriction(0)
    ship:setSleepThreshold(0, 0)
    ship:setOwner(self.player)
    self.system:addChild(ship)
    self.player:setControlling(ship)
  end

  for i = 1, 1 do
    local station = self.system:spawnStation()
  end

  for i = 1, 1 do
    self.system:spawnAI(100)
  end

  for i = 1, 1 do
    self.system:spawnAsteroidField(500, 10)
  end

  for i = 1, 1 do
    self.system:spawnPlanet()
  end
end

function LTheory:onInit ()
  self.player = Entities.Player()
  self:generate()

  DebugControl.ltheory = self
  self.gameView = GUI.GameView(self.player)
  self.canvas = UI.Canvas()
  self.canvas
    :add(self.gameView
      :add(Controls.MasterControl(self.gameView, self.player)))
end

function LTheory:onInput ()
  self.canvas:input()
end

function LTheory:onUpdate (dt)
  self.player:getRoot():update(dt)
  self.canvas:update(dt)
end

function LTheory:onDraw ()
  self.canvas:draw(self.resX, self.resY)
end

return LTheory
