local Camera = require('Util.Camera')

local CameraChase = subclass(Camera, function (self)
  self.posRel    = Vec3f(0, 4,-10)
  self.lookAtRel = Vec3f(0, 0, 1000)
  self.target    = nil
  self.radius    = 1
  self.radiusT   = 1
end)

function CameraChase:modRadius (mult)
  local radius = self.radiusT * mult
  if self.target then radius = max(radius, 0.5) end
  self.radiusT = radius
  return self
end

function CameraChase:onUpdate (dt)
  do
    local f = 1.0 - exp(-8.0 * dt)
    self.radius = Math.Lerp(self.radius, self.radiusT, f)
  end

  if self.target then
    local velA   = self.target:getVelocityALocal()
    local tRight = self.target:getRight()
    local tUp    = self.target:getUp()
    local radius = 0.25 * self.radius * self.target:getRadius()
    self.posT:setv(self.target:toWorld(self.posRel:scale(radius)))
    self.posT:iadd(tRight:scale(-4.0 * velA.y))
    self.posT:iadd(tUp:scale(4.0 * velA.x))

    local look = (self.target:toWorldScaled(self.lookAtRel) - self.posT):normalize()
    local up   = (tUp + tRight:scale(0.2 * velA.y)):normalize()
    up = up:reject(look):normalize()
    self.rotT = Quat.FromLookUp(look, up)
  end

  self:lerp(dt)
end

function CameraChase:setRadius (radius)
  if self.target then radius = max(radius, 0.5) end
  self.radius, self.radiusT = radius, radius
  return self
end

function CameraChase:setRelativePos (x, y, z)
  self.posRel = Vec3f(x, y, z)
  return self
end

function CameraChase:setRelativeLookAt (x, y, z)
  self.lookAtRel = Vec3f(x, y, z)
  return self
end

function CameraChase:setTarget (target)
  self.target = target
  return self
end

function CameraChase:warp ()
  self.radius = self.radiusT
  self:onUpdate(0)
  self.pos = self.posOffset + self.posT
  self.rot = self.rotOffset * self.rotT
end

return CameraChase

--[[ TODO : What happens if we have a target, leave this camera, then return to
            it after the object is destroyed? ]]
