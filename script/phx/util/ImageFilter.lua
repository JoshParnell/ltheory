local Cache = require('phx.util.Cache')
local ImageFilter = {}

function ImageFilter.IAdd (dst, src1, src2, mult1, mult2)
  local shader = Cache.Shader('identity', 'filter/add')
  dst:push()
  shader:start()
    Shader.SetFloat('mult1', mult1)
    Shader.SetFloat('mult2', mult2)
    Shader.SetTex2D('src1', src1)
    Shader.SetTex2D('src2', src2)
    Draw.Color(1, 1, 1, 1)
    Draw.Rect(-1, -1, 2, 2)
  shader:stop()
  dst:pop()
end

function ImageFilter.IComposite (dst, src1, src2)
  local shader = Cache.Shader('identity', 'ui/composite')
  dst:push()
  shader:start()
    Shader.SetTex2D('srcBottom', src1)
    Shader.SetTex2D('srcTop', src2)
    Draw.Color(1, 1, 1, 1)
    Draw.Rect(-1, -1, 2, 2)
  shader:stop()
  dst:pop()
end

function ImageFilter.IGlitch (dst, src, strength)
  local shader = Cache.Shader('identity', 'filter/glitch')
  local size = src:getSize()
  dst:push()
  shader:start()
    Shader.SetFloat('strength', strength)
    Shader.SetFloat('scroll', 0.0)
    Shader.SetFloat2('size', size.x, size.y)
    Shader.SetTex2D('src', src)
    Draw.Color(1, 1, 1, 1)
    Draw.Rect(-1, -1, 2, 2)
  shader:stop()
  dst:pop()
end

function ImageFilter.ITonemap (dst, src)
  local shader = Cache.Shader('identity', 'filter/tonemap')
  dst:push()
  shader:start()
    Shader.SetTex2D('src', src)
    Draw.Color(1, 1, 1, 1)
    Draw.Rect(-1, -1, 2, 2)
  shader:stop()
  dst:pop()
end

function ImageFilter.IVignette (dst, src, strength, hardness)
  local shader = Cache.Shader('identity', 'filter/vignette')
  local size = src:getSize()
  dst:push()
  shader:start()
    Shader.SetFloat('strength', strength)
    Shader.SetFloat('hardness', hardness)
    Shader.SetTex2D('src', src)
    Draw.Color(1, 1, 1, 1)
    Draw.Rect(-1, -1, 2, 2)
  shader:stop()
  dst:pop()
end


function ImageFilter.Blur (src, dx, dy, radius)
  local size = src:getSize()
  local self = Tex2D.Create(size.x, size.y, src:getFormat())
  ImageFilter.IBlur(self, src, dx, dy, radius)
  return self
end

function ImageFilter.IBlur (dst, src, dx, dy, radius)
  local shader = Cache.Shader('identity', 'filter/blur')
  local size = dst:getSize()
  dst:push()
  shader:start()
    Shader.SetFloat('variance', 0.2 * radius)
    Shader.SetFloat2('dir', dx, dy)
    Shader.SetFloat2('size', size.x, size.y)
    Shader.SetInt('radius', radius)
    Shader.SetTex2D('src', src)
    Draw.Color(1, 1, 1, 1)
    Draw.Rect(-1, -1, 2, 2)
  shader:stop()
  dst:pop()
end

function ImageFilter.ILerp (dst, src1, src2, t)
  local shader = Cache.Shader('identity', 'filter/add')
  dst:push()
  shader:start()
    Shader.SetFloat('mult1', 1 - t)
    Shader.SetFloat('mult2', t)
    Shader.SetTex2D('src1', src1)
    Shader.SetTex2D('src2', src2)
    Draw.Color(1, 1, 1, 1)
    Draw.Rect(-1, -1, 2, 2)
  shader:stop()
  dst:pop()
end

function ImageFilter.Lerp (src1, src2, t)
  local size = src1:getSize()
  local self = Tex2D.Create(size.x, size.y, src1:getFormat())
  ImageFilter.ILerp(self, src1, src2, t)
  return self
end

return ImageFilter
