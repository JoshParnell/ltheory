local Generator = require('Gen.Generator')
local GenUtil   = require('Gen.GenUtil')

local function generateNebulaLightTransport (rng, res, starDir)
  Profiler.Begin('Nebula.Generate.LightTransport')
  local buffDst = TexCube.Create(res, TexFormat.RGBA16F)
  local buffSrc = TexCube.Create(res, TexFormat.RGBA16F)
  buffDst:setMagFilter(TexFilter.Linear)
  buffDst:setMinFilter(TexFilter.Linear)
  buffSrc:setMagFilter(TexFilter.Linear)
  buffSrc:setMinFilter(TexFilter.Linear)
  buffSrc:clear(0.05, 0.05, 0.05, 0)

  local emit   = Cache.Shader('ui', 'gen/nebula_emit')
  local absorb = Cache.Shader('ui', 'gen/nebula_absorb')

  for i = 1, 8 do
    for j = 1, rng:getInt(4, 8) do -- Emission
      local ss = ShaderState.Create(emit)
      local rot = rng:getQuat()
      local dir = rng:getDir3()
      -- ss:setFloat('seed', rng:getUniform())
      local T = rng:getUniform()
      local K = Math.Lerp(1600.0, 15000.0, T)
      local C = Color.FromTemperature(K, 2.5):toVec3():normalize():scale(1.0 + rng:getExp())
      ss:setFloat3('color', C.x, C.y, C.z)
      ss:setFloat4('rot', rot.x, rot.y, rot.z, rot.w)
      -- ss:setFloat3('starDir', starDir.x, starDir.y, starDir.z)
      ss:setTexCube('src', buffSrc)
      buffDst:generate(ss)
      ss:free()
      buffSrc, buffDst = buffDst, buffSrc
    end

    for j = 1, rng:getInt(2, 4) do -- Extinction
      local ss = ShaderState.Create(absorb)
      local rot = rng:getQuat()
      ss:setFloat('density', 1.0 + rng:getExp())
      ss:setFloat('seed', rng:getUniform())
      ss:setFloat4('rot', rot.x, rot.y, rot.z, rot.w)
      ss:setTexCube('src', buffSrc)
      buffDst:generate(ss)
      ss:free()
      buffSrc, buffDst = buffDst, buffSrc
    end
  end

  buffDst:free()
  buffSrc:setMinFilter(TexFilter.LinearMipLinear)
  buffSrc:genMipmap()
  Profiler.End()
  return buffSrc
end

Generator.Add('Nebula', 0.1, generateNebulaLightTransport)
