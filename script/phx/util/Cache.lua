local Cache = {}

local files    = {}
local fonts    = {}
local shaders  = {}
local textures = {}

function Cache.Clear ()
  for k, v in pairs(shaders) do v:free() end
  for k, v in pairs(textures) do v:free() end
  shaders = {}
  textures = {}
end

function Cache.File (path)
  if not File.Exists(path) then return nil end
  if files[path] then return files[path] end
  local f = io.open(path, 'rb')
  if not f then Log.Error('Failed to open file <%s> for reading', path) end
  local self = f:read('*a')
  f:close()
  files[path] = self
  return self
end

-- TODO AB : Figure out proper way to do UI font caching
function Cache.Font (name, size)
  local key = name .. size
  local self = fonts[key]
  if self then return self end
  self = Font.Load(name, size)
  fonts[key] = self
  return self
end

function Cache.Shader (vs, fs)
  local key = vs .. fs
  local self = shaders[key]
  if self then return self end
  self = Shader.Load('vertex/' .. vs, 'fragment/' .. fs)
  shaders[key] = self
  return self
end

function Cache.Texture (name, filtered)
  local self = textures[name]
  if self then return self end
  self = Tex2D.Load(name)
  textures[name] = self
  if filtered then
    self:setMagFilter(TexFilter.Linear)
    self:setMinFilter(TexFilter.LinearMipLinear)
    self:setWrapMode(TexWrapMode.Clamp)
    self:genMipmap()
  end
  return self
end

return Cache
