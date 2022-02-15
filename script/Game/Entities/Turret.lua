local Entity = require('Game.Entity')
local Components = requireAll('Game.Components')

-- TODO : Constraints

local mesh
local material
local shader
local shared
local varCache
local rng = RNG.FromTime()

local Turret
Turret = subclass(Entity, function (self)
  if not shared then
    shared = {}
    shared.mesh = Gen.ShipFighter.TurretSingle(rng)
    shared.mesh:computeNormals()
    shared.mesh:computeAO(0.1)
    mesh = Gen.Primitive.Billboard(-1, -1, 1, 1)
  end

  if not material then
    material = Material.Create(
      'material/metal',
      Cache.Texture('metal/01_d'),
      Cache.Texture('metal/01_n'),
      Cache.Texture('metal/01_s'))
  end

  if not shader then
    shader = Cache.Shader('billboard/quad', 'effect/pulsehead')
  end

  if not varCache then
    varCache = ShaderVarCache(shader, { 'color', 'size', 'alpha', 'mWorld', })
  end

  self:addRigidBody(true, shared.mesh)
  self:addVisibleMesh(shared.mesh, Material.Debug())
  -- TODO : Tracking Component

  self.aim = Quat.Identity()
  self.mesh = shared.mesh
  self.firing = 0
  self.cooldown = 0
  self.heat = 0
  self.projRange = Config.game.pulseRange
  self.projSpeed = Config.game.pulseSpeed
  self.projLife = self.projRange / self.projSpeed
  self.projSpread = Config.game.pulseSpread

  self:register(Event.Update, Turret.updateTurret)
end)

function Turret:getSocketType ()
  return SocketType.Turret
end

function Turret:aimAt (pos)
  local look = pos - self:getPos()
  local up   = self:getParent():getUp()
  -- self.aim:iLerp(Quat.FromLookUp(look, up), 0.1)
  self.aim = Quat.FromLookUp(look, up)
  -- TODO : Isn't this already normalized?
  self.aim:iNormalize()
end

function Turret:aimAtTarget (target, fallback)
  local tHit, pHit = Math.Impact(
    self:getPos(),
    target:getPos(),
    self:getParent():getVelocity(),
    target:getVelocity(),
    self.projSpeed)
  if tHit and tHit < self.projLife then
    self:aimAt(pHit)
    return true
  elseif fallback then
    self:aimAt(fallback)
  end
  return false
end

function Turret:canFire ()
  return self.cooldown <= 0
end

function Turret:fire ()
  local e = self:getRoot():addProjectile(self:getParent())
  local dir = (self:getForward() + rng:getDir3():scale(self.projSpread * rng:getExp())):normalize()
  e.pos = self:toWorld(Vec3f(0, 0, 0))
  e.vel = dir:scale(self.projSpeed) + self:getParent():getVelocity()
  e.dir = dir
  assert(e.dir:length() >= 0.9)
  e.lifeMax = self.projLife
  e.life = e.lifeMax

  -- NOTE : In the future, it may be beneficial to store the actual turret
  --        rather than the parent. It would allow, for example, data-driven
  --        AI threat analysis by keeping track of which weapons have caused
  --        the most real damage to it, allowing for optimal sub-system
  --        targetting.
  self.cooldown = 1.0
  self.heat = self.heat + 1
end

function Turret:render (state)
  if state.mode == BlendMode.Additive then
    shader:start()
    Shader.ISetFloat3(varCache.color, 1.0, 1.3, 2.0)
    mesh:drawBind()
    -- TODO : Should this check be done first?
    if self.heat > 1e-3 then
      Shader.ISetFloat(varCache.size, 8)
      Shader.ISetFloat(varCache.alpha, 2.0 * self.heat)
      Shader.ISetMatrix(varCache.mWorld, self:getToWorldMatrix())
      mesh:drawBound()
    end
    mesh:drawUnbind()
    shader:stop()
  end
end

function Turret:updateTurret (state)
  local decay = exp(-16.0 * state.dt)
  self:setRotLocal(self:getParent():getRot():inverse() * self.aim)
  if self.firing > 0 then
    self.firing = 0
    if self.cooldown <= 0 then self:fire() end
  end
  self.cooldown = max(0, self.cooldown - state.dt * Config.game.rateOfFire)
  self.heat = self.heat * decay
end

return Turret
