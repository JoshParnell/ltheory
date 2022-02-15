local Entity = require('Game.Entity')

local genColor = function (rng)
  local h = rng:getUniformRange(0, 0.5)
  local l = Math.Saturate(rng:getUniformRange(0.2, 0.3) + 0.05 * rng:getExp())
  local s = rng:getUniformRange(0.1, 0.3)
  local c = Color.FromHSL(h, s, l)
  return Vec3f(c.r, c.g, c.b)
end

local Planet = subclass(Entity, function (self, seed)
  -- TODO : Had to lower quality to 2 because RigidBody is automatically
  --        building BSP, and sphere is pathological case for BSPs. Need
  --        generalized CollisionShape.
  local mesh = Gen.Primitive.IcoSphere(5):managed()

  self:addRigidBody(true, mesh)
  self:setMass(1000)

  self.mesh = mesh
  self.meshAtmo = Gen.Primitive.IcoSphere(5):managed()
  self.meshAtmo:computeNormals()
  self.meshAtmo:invert()

  local rng = RNG.Create(seed):managed()
  self.texSurface = Gen.GenUtil.ShaderToTexCube(2048, TexFormat.RGBA16F, 'gen/planet', {
    seed = rng:getUniform(),
    freq = 4 + rng:getExp(),
    power = 1 + 0.5 * rng:getExp(),
    coef = (rng:getVec4(0.05, 1.00) ^ Vec4f(2, 2, 2, 2)):normalize()
  }):managed()

  self.cloudLevel = rng:getUniformRange(-0.2, 0.15)
  self.oceanLevel = rng:getUniform() ^ 1.5
  self.atmoScale = 1.1

  self.color1 = genColor(rng)
  self.color2 = genColor(rng)
  self.color3 = genColor(rng)
  self.color4 = genColor(rng)

  self:register(Event.Render, self.render)
end)

function Planet:render (state)
  if state.mode == BlendMode.Disabled then
    local shader = Cache.Shader('wvp', 'material/planet')
    shader:start()
    Shader.SetFloat('heightMult', 1.0)
    Shader.SetFloat('oceanLevel', self.oceanLevel)
    Shader.SetFloat('rPlanet', self:getScale())
    Shader.SetFloat('rAtmo', self:getScale() * self.atmoScale)
    Shader.SetFloat3('color1', self.color1.x, self.color1.y, self.color1.z)
    Shader.SetFloat3('color2', self.color2.x, self.color2.y, self.color2.z)
    Shader.SetFloat3('color3', self.color3.x, self.color3.y, self.color3.z)
    Shader.SetFloat3('color4', self.color4.x, self.color4.y, self.color4.z)
    local pos = self:getPos()
    Shader.SetFloat3('origin', pos.x, pos.y, pos.z)
    Shader.SetFloat3('starColor', 1.0, 0.5, 0.1)
    Shader.SetMatrix('mWorld', self:getToWorldMatrix())
    Shader.SetMatrixT('mWorldIT', self:getToLocalMatrix())
    Shader.SetTexCube('surface', self.texSurface)
    self.mesh:draw()
    shader:stop()
  elseif state.mode == BlendMode.Alpha then
    CullFace.Push(CullFace.Back)
    BlendMode.Push(BlendMode.PreMultAlpha)
    local shader = Cache.Shader('wvp', 'material/atmosphere')
    shader:start()
    do -- TODO : Scale the atmosphere mesh in shader...
      local mScale = Matrix.Scaling(1.5, 1.5, 1.5)
      local mWorld = self:getToWorldMatrix():product(mScale)
      Shader.SetMatrix('mWorld', mWorld)
      mScale:free()
      mWorld:free()
    end

    Shader.SetMatrixT('mWorldIT', self:getToLocalMatrix())
    local scale = self:getScale()
    Shader.SetFloat('rAtmo', scale * self.atmoScale)
    Shader.SetFloat('rPlanet', scale)
    local pos = self:getPos()
    Shader.SetFloat3('origin', pos.x, pos.y, pos.z)
    Shader.SetFloat3('scale', scale, scale, scale)
    Shader.SetFloat3('starColor', 1.0, 0.5, 0.1)
    self.meshAtmo:draw()
    shader:stop()
    BlendMode.Pop()
    CullFace.Pop()
  end
end

return Planet
