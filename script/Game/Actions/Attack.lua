local Action = require('Game.Action')

local Attack = subclass(Action, function (self, target)
  self.target = target
end)

local rng = RNG.FromTime()

function Attack:getName ()
  return format('Attack %s', self.target:getName())
end

function Attack:onStart (e)
  self.radiusMin = 2.0 * self.target:getRadius() + e:getRadius()
  self.radiusMax = e.socketRangeMin
  self.timer = 0
  self.dist = 0
end

local kVelFactor = 0.0
local expMap = PHX.Math.ExpMap1Signed

function Attack:onUpdateActive (e, dt)
  local target = self.target
  if not target:isAlive() then
    e:popAction()
    return
  end

  e:setTarget(target)

  self.timer = self.timer - dt
  if self.timer <= 0 or self.dist < e:getSpeed() then
    self.offset = rng:getDir3()
    self.offset:iscale(Math.Sign(self.offset:dot(e:getPos() - self.target:getPos())))
    self.timer = rng:getUniformRange(5, 10)
    self.radius = Math.Lerp(
      self.radiusMin,
      self.radiusMax,
      rng:getUniformRange(0, 1) ^ 2.0)
  end

  local targetPos =
      target:getPos() + self.offset:scale(self.radius) +
      target:getVelocity():scale(kVelFactor)

  local course   = targetPos - e:getPos()
  local dist     = course:length()
  self.dist = dist
  local courseN  = course:normalize()

  local forward  = course:normalize()
  local yawPitch = e:getForward():cross(forward)
  local roll     = e:getUp():cross(target:getUp())

  course = course - e:getVelocity():scale(kVelFactor)
  e.thrustRight   = expMap(  2.0 * e:getRight():dot(course))
  e.thrustUp      = expMap(  2.0 * e:getUp():dot(course))
  e.thrustForward = expMap(  2.0 * e:getForward():dot(course))
  e.thrustYaw     = expMap(-10.0 * e:getUp():dot(yawPitch))
  e.thrustPitch   = expMap( 10.0 * e:getRight():dot(yawPitch))
  e.thrustRoll    = expMap(  0.0 * e:getForward():dot(roll))
  if Config.game.aiUsesBoost then
    e.thrustBoost = 1.0 - exp(-max(0.0, (dist / 1000.0) - 1.0))
  end
end

function Attack:onUpdatePassive (e, dt)
  local align = (self.target:getPos() - e:getPos()):normalize():dot(e:getForward())
  if align < 0.25 then return end
  local firing = Config.game.aiFire(dt, rng)
  for turret in e:iterSocketsByType(SocketType.Turret) do
    -- TODO : Fix
    turret:aimAt(self.target, firing)
  end
end

return Attack
