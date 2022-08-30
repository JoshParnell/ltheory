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

    -- player escorts
    local ships = {}
    for i = 1, 100 do
      local escort = self.system:spawnShip()
      local offset = rng:getSphere():scale(100)
      escort:setPos(ship:getPos() + offset)
      escort:setOwner(self.player)
      escort:pushAction(Actions.Escort(ship, offset))
      insert(ships, escort)
    end

    for i = 1, #ships do
      local j = rng:getInt(1, #ships)
      if i ~= j then
        -- ships[i]:pushAction(Actions.Attack(ships[j]))
      end
    end
  end

  for i = 1, 1 do
    local station = self.system:spawnStation()
  end

  for i = 1, 0 do
    self.system:spawnAI(100)
  end

  for i = 1, 1 do
    self.system:spawnAsteroidField(500, 10)
  end

  for i = 1, 0 do
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

-- Flat: add basic Game Control menu items
function LTheory:showGameCtrlInner ()
  HmGui.BeginGroupY()
  if HmGui.Button("Load Game") then
    drawExitMenu = false
  end
  HmGui.SetSpacing(8)
  if HmGui.Button("Save Game") then
    drawExitMenu = false
  end
  HmGui.SetSpacing(8)
  if HmGui.Button("Settings") then
    drawExitMenu = false
  end
  HmGui.SetSpacing(8)
  if HmGui.Button("Credits") then
    drawExitMenu = false
  end
  HmGui.SetSpacing(8)
  if HmGui.Button("Quit to Main Menu") then
    drawExitMenu = false
  end
  HmGui.SetSpacing(8)
  if HmGui.Button("Quit to Desktop") then
    LTheory:quit()
  end
  HmGui.EndGroup()
end

-- Flat: add basic Game Control menu dialog
function LTheory:showCtrlMenu ()
  HmGui.BeginWindow("Game Control")
    HmGui.TextEx(Cache.Font('Iceland', 20), 'Game Control', 0.3, 0.4, 0.5, 1.0)
    HmGui.SetAlign(0.5, 0.5)
    HmGui.SetSpacing(16)
    self:showGameCtrlInner()
  HmGui.EndWindow()
  HmGui.SetAlign(0.5, 0.5)
end

function LTheory:onUpdate (dt)
  self.player:getRoot():update(dt)
  self.canvas:update(dt)

  -- Flat: add basic Game Control menu (only "Quit to Desktop" actually works at the moment)
  if Input.GetPressed(Button.Keyboard.Escape) then
    drawExitMenu = not drawExitMenu
  end
  HmGui.Begin(self.resX, self.resY)
    if drawExitMenu then
      HmGui.BeginGroupStack()
      self:showCtrlMenu()
      HmGui.EndGroup()
    end
  HmGui.End()
end

function LTheory:onDraw ()
  self.canvas:draw(self.resX, self.resY)
  HmGui.Draw() -- Flat: draw controls
end

return LTheory
