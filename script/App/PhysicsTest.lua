Config.debug.physics.drawBoundingBoxesLocal = false
Config.debug.physics.drawBoundingBoxesWorld = false
Config.debug.physics.drawTriggers           = true
Config.debug.physics.drawWireframes         = true

--[[-- Controls ----------------------------------------------------------------

  There are 2 asteroids you can control. Use Ctrl + <button> to control the
  first and Shift + <button> to control the second.

  Return      : Attach to/detach from your ship
  -/=         : Change asteroid's scale
  I/J/K/L/U/O : Change asteroid's position
  T/F/G/H/R/Y : Change asteroid's rotation

  TODO
  In the distance 2 collisions will occur soon after running: asteroid vs
  asteroid, ship vs ship and asteroid vs ship.

  A stationary asteroid and ship are placed in front of the ship to run into.

  A stationary ship is placed in front of the ship to test compound bounding
  boxes.

  A massive stationary asteroid is placed behind the ship to test small vs large
  collisions.

  A trigger box is positioned at the origin and content count is printed.
----------------------------------------------------------------------------]]--

local compoundTest        = true
local collisionTest       = true
local boundingTest        = true
local scaleTest           = true
local worldTriggerTest    = true
local attachedTriggerTest = true
local printCounts         = false

local print_ = print
local print = function (...) if printCounts then print_(...) end end

local Entities = requireAll('Game.Entities')
local DebugControl = require('Game.Controls.DebugControl')

local LTheory = Application()
local rng = RNG.FromTime()

function LTheory:generate ()
  if Config.gen.seedGlobal then
    rng:free()
    rng = RNG.Create(Config.gen.seedGlobal)
  end
  self.seed = rng:get64()
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

    if compoundTest then
      self.asteroid1 = Entities.Asteroid(1234, 5)
      self.asteroid1:setPos(Vec3f(-10, 0, 10))
      self.system:addChild(self.asteroid1)
      self.asteroid1.pos = Vec3f(1, 0, 0)

      self.asteroid2 = Entities.Asteroid(1234, 5)
      self.asteroid2:setPos(Vec3f(10, 0, 10))
      self.system:addChild(self.asteroid2)
      self.asteroid2.pos = Vec3f(-1, 0, 0)
    end

    if collisionTest then
      local asteroid = Entities.Asteroid(1234, 20)
      asteroid:setPos(Vec3f(20, 0, -100))
      self.system:addChild(asteroid)
      local ship = self.system:spawnShip()
      ship:setPos(Vec3f(-20, 0, -100))

      local ship = self.system:spawnShip()
      local mat = Matrix.YawPitchRoll(0, 0, math.pi/4)
      local rot = mat:toQuat()
      mat:free()
      ship:setPos(Vec3f(0, 40, -100))
      ship:setRot(rot)
      if boundingTest then
        ship:attach(Entities.Asteroid(1234, 5), Vec3f( 10, 0, 0), Quat.Identity())
        ship:attach(Entities.Asteroid(1234, 5), Vec3f(-10, 0, 0), Quat.Identity())
      end
    end

    if scaleTest then
      local asteroid = Entities.Asteroid(1234, 10000)
      asteroid:setPos(Vec3f(0, 0, 10500))
      self.system:addChild(asteroid)
    end
  end

  if worldTriggerTest then
    self.trigger1 = Entities.Trigger(Vec3f(20, 20, 20))
    self.trigger1:triggerSetPos(Vec3f(9, 0, 0))
    self.system:addChild(self.trigger1)
  end

  if attachedTriggerTest then
    self.trigger2 = Entities.Trigger(Vec3f(20, 20, 20))
    self.system:addChild(self.trigger2)
    self.trigger2:triggerAttach(self.player:getControlling().body, Vec3f())
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

  if compoundTest then
    local asteroids = List()
    if Input.GetDown(Button.Keyboard.LCtrl)  then asteroids:append(self.asteroid1) end
    if Input.GetDown(Button.Keyboard.LShift) then asteroids:append(self.asteroid2) end

    local ship = self.player:getControlling()
    for i = 1, #asteroids do
      local asteroid = asteroids[i]

      -- Attach/detach
      if Input.GetPressed(Button.Keyboard.Return) then
        local parent = asteroid:getParentBody()
        if parent == nil then
          self.system:removeChild(asteroid)
          ship:attach(asteroid, asteroid.pos:muls(5), Quat.Identity())
        else
          ship:detach(asteroid)
          self.system:addChild(asteroid)
        end
      end

      -- Scale
      if Input.GetPressed(Button.Keyboard.Minus) then
        local scale = asteroid:getScale()
        if scale > 1 then asteroid:setScale(scale - 1) end
      end
      if Input.GetPressed(Button.Keyboard.Equals) then
        local scale = asteroid:getScale()
        asteroid:setScale(scale + 1)
      end

      -- Position
      local pos = Vec3f(0, 0, 0)
      if Input.GetPressed(Button.Keyboard.I) then pos.z = pos.z - 1 end
      if Input.GetPressed(Button.Keyboard.K) then pos.z = pos.z + 1 end
      if Input.GetPressed(Button.Keyboard.L) then pos.x = pos.x + 1 end
      if Input.GetPressed(Button.Keyboard.J) then pos.x = pos.x - 1 end
      if Input.GetPressed(Button.Keyboard.O) then pos.y = pos.y + 1 end
      if Input.GetPressed(Button.Keyboard.U) then pos.y = pos.y - 1 end
      local parent = asteroid:getParentBody()
      if parent == nil then
        asteroid:setPos(pos + asteroid:getPos());
      else
        asteroid:setPosLocal(pos + asteroid:getPosLocal());
      end

      local ypr = Vec3f(0, 0, 0)
      if Input.GetPressed(Button.Keyboard.T) then ypr.y = ypr.y - math.pi/10 end
      if Input.GetPressed(Button.Keyboard.G) then ypr.y = ypr.y + math.pi/10 end
      if Input.GetPressed(Button.Keyboard.H) then ypr.z = ypr.z - math.pi/10 end
      if Input.GetPressed(Button.Keyboard.F) then ypr.z = ypr.z + math.pi/10 end
      if Input.GetPressed(Button.Keyboard.Y) then ypr.x = ypr.x - math.pi/10 end
      if Input.GetPressed(Button.Keyboard.R) then ypr.x = ypr.x + math.pi/10 end
      local mat = Matrix.YawPitchRoll(ypr.y, ypr.x, ypr.z)
      local rot = mat:toQuat()
      mat:free()
      local parent = asteroid:getParentBody()
      if parent == nil then
        asteroid:setRot(rot * asteroid:getRot());
      else
        asteroid:setRotLocal(rot * asteroid:getRotLocal());
      end
    end
  end
end

function LTheory:onUpdate (dt)
  self.player:getRoot():update(dt)
  self.canvas:update(dt)

  local collision = Collision()
  while (self.system.physics:getNextCollision(collision)) do
      --print('', collision.index, collision.body0, collision.body1)
  end
  print('Collision Count:', collision.count)

  if worldTriggerTest then
    local triggerCount = self.trigger1:getContentsCount()
    print('World Trigger Count:', triggerCount)
    for i = 1, triggerCount do
      self.trigger1:getContents(i - 1)
    end
  end

  if attachedTriggerTest then
    local triggerCount = self.trigger2:getContentsCount()
    print('Attached Trigger Count:', triggerCount)
    for i = 1, triggerCount do
      self.trigger2:getContents(i - 1)
    end
  end
end

function LTheory:onDraw ()
  self.canvas:draw(self.resX, self.resY)
end

return LTheory
