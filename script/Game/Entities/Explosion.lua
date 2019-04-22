-- TODO : Refactor as part of particle engine

if false then

local Explosion = class(function (self, pos, age)
  self.age = 0
  self.pos = pos
  self.seed = rng:getUniform()
end)

local cache
local mesh
local rng
local shader

Preload.Add (function ()
  mesh = Gen.Primitive.Billboard(-1, -1, 1, 1)
  rng = RNG.FromTime()
  shader = Cache.Shader('billboard/quadpos', 'effect/explosion')
  cache = ShaderVarCache(shader, { 'color', 'origin', 'up', 'age', 'seed', 'size' })
end)

function Explosion.RenderAdditive (ents, state)
  Profiler.Begin('Explosion.RenderAdditive')
  shader:start()
  Shader.ISetFloat3(cache.color, 2.0, 1.5, 1.0)
  Shader.ISetFloat3(cache.up, state.up.x, state.up.y, state.up.z)
  Shader.ISetFloat(cache.size, 64)
  mesh:drawBind()
  for i = 1, #ents do
    local self = ents[i]
    if self.age >= 0 then
      Shader.ISetFloat(cache.age, self.age)
      Shader.ISetFloat(cache.seed, self.seed)
      Shader.ISetFloat3(cache.origin, self.pos.x, self.pos.y, self.pos.z)
      mesh:drawBound()
    end
  end
  mesh:drawUnbind()
  shader:stop()
  Profiler.End()
end

function Explosion.Update (ents, dt)
  Profiler.Begin('Explosion.Update')
  for i = #ents, 1, -1 do
    local self = ents[i]
    self.age = self.age + dt
    if self.age >= 10 then
      ents[i] = ents[#ents]
      ents[#ents] = nil
      self:delete()
    end
  end
  Profiler.End()
end

return Explosion
end
