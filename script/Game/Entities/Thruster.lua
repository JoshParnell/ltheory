local Entity = require('Game.Entity')

local mesh
local meshJet
local rng = RNG.FromTime()

local Thruster
Thruster = subclass(Entity, function (self)
  if not mesh then
    mesh = Gen.ShipFighter.EngineSingle(rng)
    mesh:computeNormals()
    mesh:computeAO(0.1)
    meshJet = Gen.Primitive.Billboard(-1, 0, 1, 1)
  end

  self:addRigidBody(true, mesh)
  self:addVisibleMesh(mesh, Material.Debug())

  self.activation = 0
  self.activationT = 0
  self.boost = 0
  self.boostT = 0
  self.time = rng:getUniformRange(0, 1000)

  self:register(Event.Render, Thruster.render)
  self:register(Event.Update, Thruster.update)
end)

function Thruster:getSocketType ()
  return SocketType.Thruster
end

function Thruster:render (state)
  if state.mode == BlendMode.Additive then
    local a = math.abs(self.activation)
    if a < 1e-3 then return end
    local shader = Cache.Shader('billboard/axis', 'effect/thruster')
    shader:start()
    Shader.SetFloat('alpha', a)
    Shader.SetFloat('time', self.time)
    Shader.SetFloat2('size', 2, 32 * self.activation)
    Shader.SetFloat3('color', 0.1 + 1.2 * self.boost, 0.3 + 0.2 * self.boost, 1.0 - 0.7 * self.boost)
    Shader.SetMatrix('mWorld', self:getToWorldMatrix())
    meshJet:draw()
    shader:stop()
  end
end

function Thruster:update (state)
  local t = 1.0 - exp(-4.0 * state.dt)
  self.activation = Math.Lerp(self.activation, self.activationT, t)
  self.boost = Math.Lerp(self.boost, self.boostT, t)
  self.time = self.time + state.dt
end

return Thruster
