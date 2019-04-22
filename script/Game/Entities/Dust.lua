local kFleckDistance = 1024
local kCloudDistance = 1024

local Dust = class(function (self) end)

function Dust:forceLoad ()
  if self.clouds then return end
  local rng = RNG.FromTime():managed()

  do -- Dust clouds mesh
    local mesh = Mesh.Create():managed()
    for i = 1, Config.gen.nDustClouds do
      local p = rng:getVec3(-kFleckDistance, kFleckDistance)
      mesh:addVertex(p.x, p.y, p.z, 0, 0, 1, -1, -1)
      mesh:addVertex(p.x, p.y, p.z, 0, 0, 1,  1, -1)
      mesh:addVertex(p.x, p.y, p.z, 0, 0, 1,  1,  1)
      mesh:addVertex(p.x, p.y, p.z, 0, 0, 1, -1,  1)
      local i0 = 4 * (i + 1)
      mesh:addQuad(i0, i0 + 3, i0 + 2, i0 + 1)
    end
    self.clouds = mesh
  end

  do -- Dust fleck mesh
    local mesh = Mesh.Create():managed()
    for i = 1, Config.gen.nDustFlecks do
      local p = rng:getVec3(-kFleckDistance, kFleckDistance)
      mesh:addVertex(p.x, p.y, p.z, 0, 0, 1, -1, 0)
      mesh:addVertex(p.x, p.y, p.z, 0, 0, 1,  1, 0)
      mesh:addVertex(p.x, p.y, p.z, 0, 0, 1,  1, 1)
      mesh:addVertex(p.x, p.y, p.z, 0, 0, 1, -1, 1)
      local i0 = 4 * (i + 1)
      mesh:addQuad(i0, i0 + 3, i0 + 2, i0 + 1)
    end
    self.flecks = mesh
  end
end

local mIdentity = Matrix.Identity()
local texDust

function Dust:render (state)
  self:forceLoad()
  if state.mode == BlendMode.Alpha then
    Profiler.Begin('DustClouds.RenderAlpha')
    if not texDust then
      texDust = Tex2D.Create(128, 128, TexFormat.R8)
      local shader = Cache.Shader('identity', 'effect/dustcloudtex')
      texDust:push()
      shader:start()
      Draw.Rect(-1, -1, 2, 2)
      shader:stop()
      texDust:pop()
      texDust:genMipmap()
      texDust:setMagFilter(TexFilter.Linear)
      texDust:setMinFilter(TexFilter.LinearMipLinear)
      texDust:setWrapMode(TexWrapMode.Clamp)
    end

    local cam = Camera.get()
    local shader = Cache.Shader('billboard/wrapped', 'effect/dustcloud')
    local up = cam.rot:getUp()
    shader:start()
    Shader.SetFloat3('axis', up.x, up.y, up.z)
    Shader.SetFloat2('size', 64, 64)
    Shader.SetMatrix('mWorld', mIdentity)
    Shader.SetTex2D('texDust', texDust)
    self.clouds:draw()
    shader:stop()
    Profiler.End()
  elseif state.mode == BlendMode.Additive then
    Profiler.Begin('DustFlecks.RenderAdditive')
    -- TODO : Camera velocity
    local vl = 0 -- state.velocity:length()
    if vl > 1e-6 then
      local vn = state.velocity:normalize()
      local shader = Cache.Shader('billboard/wrapped', 'effect/dustfleck')
      shader:start()
      Shader.SetMatrix('mWorld', mIdentity)
      Shader.SetFloat2('size', 2.0, 0.1 * min(1000.0, vl))
      Shader.SetFloat3('axis', vn.x, vn.y, vn.z)
      self.flecks:draw()
      shader:stop()
    end
    Profiler.End()
  end
end

return Dust
