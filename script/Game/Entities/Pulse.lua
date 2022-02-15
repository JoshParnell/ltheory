local Entity = require('Game.Entity')

local Pulse = CType.Struct('Pulse', Entity)
Pulse:add(CType.Int32,   'source' )
Pulse:add(CType.Vec3f,   'pos'    )
Pulse:add(CType.Vec3f,   'vel'    )
Pulse:add(CType.Vec3f,   'dir'    )
Pulse:add(CType.Float32, 'lifeMax')
Pulse:add(CType.Float32, 'life'   )
Pulse:add(CType.Float32, 'dist'   )
Pulse:add(CType.Pointer(CType.Matrix),  'matrix' )

local cacheHead
local cacheTail
local meshHead
local meshTail
local shaderHead
local shaderTail
local onAddedToParent

Preload.Add (function ()
  meshHead = Gen.Primitive.Billboard(-1, -1, 1, 1)
  meshTail = Gen.Primitive.Billboard(-1, -1, 1, 0)
  shaderHead = Cache.Shader('billboard/quad', 'effect/pulsehead')
  shaderTail = Cache.Shader('billboard/axis', 'effect/pulsetail')
  cacheHead = ShaderVarCache(shaderHead, { 'size', 'alpha', 'mWorld' })
  cacheTail = ShaderVarCache(shaderTail, { 'alpha', 'size', 'axis', 'mWorld' })
end)

Pulse:setInitializer (function (self)
  self.matrix = Matrix.Identity()
  self:register(Event.AddedToParent, onAddedToParent)
end)

Pulse:addOnDestruct(function (self)
  self.matrix:free()
end)

Pulse:define()

onAddedToParent = function (self, parent)
  self:refreshMatrix()
end

function Pulse:refreshMatrix ()
  self.matrix:free()
  self.matrix = Matrix.LookUp(self.pos, self.dir, Math.OrthoVector(self.dir))
end

function Pulse.Render (ents, state)
  if state.mode == BlendMode.Additive then
    do -- Heads
      Profiler.Begin('Pulse.RenderAdditive.Head')
      local shader = shaderHead
      shader:start()
      Shader.SetFloat3('color', 1.0, 1.3, 2.0)
      meshHead:drawBind()
      for i = 1, #ents do
        local self = ents[i]
        Shader.ISetFloat(cacheHead.size, 16)
        Shader.ISetFloat(cacheHead.alpha, self.life / self.lifeMax)
        Shader.ISetMatrix(cacheHead.mWorld, self.matrix)
        meshHead:drawBound()
      end
      meshHead:drawUnbind()
      shader:stop()
      Profiler.End()
    end

    do -- Tails
      Profiler.Begin('Pulse.RenderAdditive.Tail')
      local shader = shaderTail
      shader:start()
      Shader.SetFloat3('color', 1.0, 1.3, 2.0)
      meshTail:drawBind()
      for i = 1, #ents do
        local self = ents[i]
        Shader.ISetFloat(cacheTail.alpha, self.life / self.lifeMax)
        Shader.ISetFloat2(cacheTail.size, 16, min(Config.game.pulseSize, 2.0 * self.dist))
        Shader.ISetFloat3(cacheTail.axis, self.dir.x, self.dir.y, self.dir.z)
        Shader.ISetMatrix(cacheTail.mWorld, self.matrix)
        meshTail:drawBound()
      end
      meshTail:drawUnbind()
      shader:stop()
      Profiler.End()
    end
  end
end

function Pulse.UpdatePrePhysics (ents, dt)
  Profiler.Begin('Pulse.UpdatePre')
  local t = 1.0 - exp(-dt)
  for i = #ents, 1, -1 do
    local self = ents[i]
    self.life = self.life - dt
    if self.life <= 0 then
      ents[i] = ents[#ents]
      ents[#ents] = nil
      self:delete()
    else
      self.pos:imadds(self.vel, dt)
      self.dir:ilerp(self.vel:normalize(), t)
      self.dist = self.dist + dt * Config.game.pulseSpeed
      self:refreshMatrix()
    end
  end
  Profiler.End()
end

function Pulse.Update (ents, dt)
  Profiler.Begin('Pulse.Update')
  local restitution = 0.4 * Config.game.pulseSize
  for i = #ents, 1, -1 do
    local self = ents[i]
    local hit = Physics.QueryPoint(self.pos.x, self.pos.y, self.pos.z)
    if hit ~= 0 and hit ~= self.source then
      local hitEnt = RefGet(hit)
      hitEnt:damage(Config.game.pulseDamage, RefGet(self.source))
      ents[i] = ents[#ents]
      ents[#ents] = nil
      self:delete()
    end
  end
  Profiler.End()
end

return Pulse
