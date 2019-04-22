local Camera = require('Util.Camera')

local CameraOrbit = subclass(Camera, function (self)
  self.yaw      = -Math.Pi2
  self.yawT     = -Math.Pi2
  self.pitch    = Math.Pi6
  self.pitchT   = Math.Pi6
  self.radius   = 100
  self.radiusT  = 100
  self.center   = Vec3f(0, 0, 0)
  self.centerT  = Vec3f(0, 0, 0)
  self.targetUp = Vec3f(0, 1, 0)

  self.target   = nil
  self.relative = false

  self.smooth   = true
  self.rigidity = 8.0
end)

function CameraOrbit:modPitch (delta)
  self.pitchT = self.pitchT + delta
  self.pitchT = Math.Clamp(self.pitchT, -0.49 * math.pi, 0.49 * math.pi)
  return self
end

function CameraOrbit:modRadius (mult)
  self.radiusT = self.radiusT * mult
  return self
end

function CameraOrbit:modYaw (delta)
  self.yawT = self.yawT + delta
  return self
end

function CameraOrbit:modCenter (delta)
  self.centerT = self.centerT + delta
  return self
end

function CameraOrbit:onUpdate (dt)
  if self.target then
    self.centerT:setv(self.target:getPos())
    if self.relative then
      self.targetUp:setv(self.target:getUp())
    end
  end

  if self.smooth then
    local t = 1.0 - exp(-self.rigidity * dt)
    self.yaw    = Math.Lerp(self.yaw,    self.yawT,    t)
    self.pitch  = Math.Lerp(self.pitch,  self.pitchT,  t)
    self.radius = Math.Lerp(self.radius, self.radiusT, t)
    self.center:ilerp(self.centerT, t)
  else
    self.yaw    = self.yawT
    self.pitch  = self.pitchT
    self.radius = self.radiusT
    self.center:setv(self.centerT)
  end

  if self.target and self.relative then
    self.posT = self.target:toWorld(Math.Spherical(self.radius, self.pitch, -self.yaw))
  else
    self.posT = self.center + Math.Spherical(self.radius, self.pitch, self.yaw)
  end

  local look = (self.center - self.posT):normalize()
  local up   = self.targetUp:reject(look):normalize()
  self.rotT  = Quat.FromLookUp(look, up)

  self:lerp(dt)
end

function CameraOrbit:setYaw (value)
  self.yaw  = value
  self.yawT = value
  return self
end

function CameraOrbit:setPitch (value)
  value = Math.Clamp(value, -0.49 * math.pi, 0.49 * math.pi)
  self.pitch  = value
  self.pitchT = value
  return self
end

function CameraOrbit:setRadius (value)
  self.radius  = value
  self.radiusT = value
  return self
end

function CameraOrbit:setCenter (x, y, z)
  self.center:set(x, y, z)
  self.centerT:set(x, y, z)
  return self
end

function CameraOrbit:setTarget (target)
  self.target = target
  return self
end

function CameraOrbit:setRelative (relative)
  self.relative = relative
  return self
end

function CameraOrbit:setSmooth (smooth)
  self.smooth = smooth
  return self
end

function CameraOrbit:setRigidity (value)
  self.rigidity = value
  return self
end

function CameraOrbit:warp ()
  self.yaw    = self.yawT
  self.pitch  = self.pitchT
  self.radius = self.radiusT
  self.center:setv(self.centerT)
  self:onUpdate(0)
  self.pos = self.posOffset + self.posT
  self.rot = self.rotOffset * self.rotT
end

return CameraOrbit

--[[ TODO : What happens if we have a pick/target, leave this camera, then
            return to it after the object is destroyed? ]]
