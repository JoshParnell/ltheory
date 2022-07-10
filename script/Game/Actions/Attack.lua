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

  self:flyToward(e, targetPos, forward, target:getUp())
end

function Attack:onUpdatePassive (e, dt)
  local align = (self.target:getPos() - e:getPos()):normalize():dot(e:getForward())
  if align < 0.25 then return end
  local firing = Config.game.aiFire(dt, rng)
  for turret in e:iterSocketsByType(SocketType.Turret) do
    turret:aimAtTarget(self.target, self.target:getPos())
    if firing then turret:fire() end
  end
end

return Attack
