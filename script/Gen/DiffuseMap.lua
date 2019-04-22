--[[----------------------------------------------------------------------------
  Given a source texture, bakes a diffuse map in UV space using fractal
  triplanar sampling.
----------------------------------------------------------------------------]]--
local function createDiffuseMap (mesh, source, res)
  local self = Tex2D.Create(res, res, TexFormat.RGBA16F)
  local shader = Cache.Shader('uvspace', 'uvbake/triplanar')
  self:clear(0, 0, 0, 1)
  self:push()
  shader:start()
  Shader.SetTex2D('src', source)
  mesh:draw()
  shader:stop()
  self:pop()

  self:setMagFilter(TexFilter.Linear)
  self:setMinFilter(TexFilter.Linear)
  return self
end

return createDiffuseMap
