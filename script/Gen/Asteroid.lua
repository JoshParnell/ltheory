local GenUtil = require('Gen.GenUtil')

local function generateAsteroid (seed)
  Profiler.Begin('Asteroid.Generate')
  local rng = RNG.Create(seed)
  local self = LodMesh.Create()
  local shader = Cache.Shader('identity', 'sdf/asteroid')
  local ss = ShaderState.Create(shader)
  ss:setInt('octaves', 8)
  ss:setFloat('seed', rng:getUniformRange(0, 1000))
  ss:setFloat('smoothness', 2.5)

  local res = 96
  local dMin = 0
  local dMax = 1
  local lac = 1.5

  for i = 1, 8 do
    local density = GenUtil.ShaderToTex3D(ss, floor(res), TexFormat.R32F)
    local field = SDF.FromTex3D(density)
    field:computeNormals()
    local mesh = field:toMesh()
    field:free()
    mesh:computeOcclusion(density, 0.1)
    density:free()
    mesh:center()
    self:add(mesh, dMin, dMax)

    res = res / lac
    dMin = dMax
    dMax = dMax * lac * sqrt(2.0)
  end

  ss:free()
  rng:free()
  Profiler.End()
  return self
end

return generateAsteroid
