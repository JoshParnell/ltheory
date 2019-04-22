local DrawEx = {}

local function padOffCenter (pad, x, y, sx, sy)
  return x - pad, y - pad, sx + 2 * pad, sy + 2 * pad
end

local function padAndCenter (pad, x, y ,sx, sy)
  return x - 0.5 * sx - pad, y - 0.5 * sy - pad, sx + 2 * pad, sy + 2 * pad
end

-- TODO : Push the paddings down as far as possible without clipping halos
local padBox = 32
local padLine = 64
local padPanel = 64
local padPoint = 32
local padRing = 128
local padTri = 32
local padWedge = 32
local alphaStack = List()

function DrawEx.Arrow (p, n, color)
  local t = Vec2f(-n.y, n.x)
  DrawEx.TriV(p + n, p - n + t, p - n - t, color)
end

function DrawEx.Cross (x, y, r, color)
  DrawEx.Line(x - r, y - r, x + r, y + r, color)
  DrawEx.Line(x - r, y + r, x + r, y - r, color)
end

function DrawEx.GetAlpha ()
  return alphaStack:last() or 1
end

function DrawEx.Hex (x, y, r, c)
  local x, y, sx, sy = padAndCenter(padRing, x, y, r, r)
  local shader = Cache.Shader('ui', 'ui/hex')
  local alpha = alphaStack:last() or 1
  BlendMode.PushAdditive()
  shader:start()
    Shader.SetFloat('radius', r)
    Shader.SetFloat2('size', sx, sy)
    Shader.SetFloat4('color', c.r, c.g, c.b, c.a * alpha)
    Draw.Rect(x, y, sx, sy)
  shader:stop()
  BlendMode.Pop()
end

function DrawEx.Hologram (mesh, x, y, sx, sy, color, radius, yaw, pitch)
  local center = mesh:getCenter()
  local eye = center + Math.Spherical(radius, pitch, yaw)
  local mView = Matrix.ViewLookAt(eye, center, Vec3f(0, 1, 0))
  local mProj = Matrix.Perspective(70, sx / sy, 0.1, 1e6)
  local shader = Cache.Shader('ui3D', 'ui/hologram')
  local alpha = alphaStack:last() or 1
  BlendMode.PushAdditive()
  shader:start()
    Shader.SetMatrix('mView', mView)
    Shader.SetMatrix('mProj', mProj)
    Shader.SetFloat('time', Engine.GetTime())
    Shader.SetFloat3('eye', eye.x, eye.y, eye.z)
    Shader.SetFloat4('color', color.r, color.g, color.b, color.a * alpha)
    Shader.SetFloat4('viewport', x, y, x + sx, y + sy)
    mesh:draw()
  shader:stop()
  BlendMode.Pop()
  mView:free()
  mProj:free()
end

function DrawEx.Icon (icon, x, y, sx, sy, color)
  print(icon)
  local x, y, sx, sy = padAndCenter(0, x, y, sx, sy)
  local shader = Cache.Shader('ui', 'ui/icon')
  local alpha = alphaStack:last() or 1
  BlendMode.PushAdditive()
  shader:start()
    Shader.SetFloat4('color', color.r, color.g, color.b, color.a * alpha)
    Shader.SetTex2D('icon', icon)
    Draw.Rect(x, y, sx, sy)
  shader:stop()
  BlendMode.Pop()
end

function DrawEx.Line (x1, y1, x2, y2, color)
  local xMin = min(x1, x2) - padLine
  local yMin = min(y1, y2) - padLine
  local xMax = max(x1, x2) + padLine
  local yMax = max(y1, y2) + padLine
  local sx = xMax - xMin
  local sy = yMax - yMin
  local shader = Cache.Shader('ui', 'ui/line')
  local alpha = alphaStack:last() or 1
  BlendMode.PushAdditive()
  shader:start()
    Shader.SetFloat2('origin', xMin, yMin)
    Shader.SetFloat2('size', sx, sy)
    Shader.SetFloat2('p1', x1, y1)
    Shader.SetFloat2('p2', x2, y2)
    Shader.SetFloat4('color', color.r, color.g, color.b, color.a * alpha)
    Draw.Rect(xMin, yMin, sx, sy)
  shader:stop()
  BlendMode.Pop()
end

function DrawEx.Panel (x, y, sx, sy, color, innerAlpha)
  local color = color or Color(0.2, 0.2, 0.2, 1.0)
  local innerAlpha = innerAlpha or 1
  local alpha = alphaStack:last() or 1
  local x, y, sx, sy = padOffCenter(padPanel, x, y, sx, sy)
  local shader = Cache.Shader('ui', 'ui/panel')
  BlendMode.PushAlpha()
  shader:start()
    Shader.SetFloat('padding', padPanel)
    Shader.SetFloat('innerAlpha', innerAlpha * alpha)
    Shader.SetFloat2('size', sx, sy)
    Shader.SetFloat4('color', color.r, color.g, color.b, color.a * alpha)
    Draw.Rect(x, y, sx, sy)
  shader:stop()
  BlendMode.Pop()
end

function DrawEx.PanelGlow (x, y, sx, sy, color)
  local x, y, sx, sy = padOffCenter(padPanel, x, y, sx, sy)
  local shader = Cache.Shader('ui', 'ui/panelglow')
  local alpha = alphaStack:last() or 1
  BlendMode.PushAdditive()
  shader:start()
    Shader.SetFloat('padding', padPanel)
    Shader.SetFloat2('size', sx, sy)
    Shader.SetFloat4('color', color.r, color.g, color.b, color.a * alpha)
    Draw.Rect(x, y, sx, sy)
  shader:stop()
  BlendMode.Pop()
end

function DrawEx.Point (x, y, r, color)
  local x, y, sx, sy = padAndCenter(padPoint, x, y, r, r)
  BlendMode.PushAdditive()
  local shader = Cache.Shader('ui', 'ui/circle')
  local alpha = alphaStack:last() or 1
  shader:start()
    Shader.SetFloat2('size', sx, sy)
    Shader.SetFloat4('color', color.r, color.g, color.b, color.a * alpha)
    Draw.Rect(x, y, sx, sy)
  shader:stop()
  BlendMode.Pop()
end

function DrawEx.PushAlpha (a)
  alphaStack:append(a * (alphaStack:last() or 1))
end

function DrawEx.PopAlpha ()
  alphaStack:pop()
end

function DrawEx.Meter (x, y, sx, sy, color, spacing, level)
  for i = 1, level do
    DrawEx.Rect(x, y, sx, sy, color)
    x = x + sx + spacing
  end
end

function DrawEx.Rect (x, y, sx, sy, color)
  local x, y, sx, sy = padOffCenter(padBox, x, y, sx, sy)
  local shader = Cache.Shader('ui', 'ui/box')
  local alpha = alphaStack:last() or 1
  BlendMode.PushAdditive()
  shader:start()
    Shader.SetFloat2('size', sx, sy)
    Shader.SetFloat4('color', color.r, color.g, color.b, color.a * alpha)
    Draw.Rect(x, y, sx, sy)
  shader:stop()
  BlendMode.Pop()
end

function DrawEx.RectOutline (x, y, sx, sy, color)
  local p = 1.5
  local lx, rx = x, x + sx
  local ty, by = y, y + sy
  DrawEx.Line(lx + p, ty,     rx - p, ty,     color)
  DrawEx.Line(rx,     ty + p, rx,     by - p, color)
  DrawEx.Line(rx - p, by,     lx + p, by,     color)
  DrawEx.Line(lx,     by - p, lx,     ty + p, color)
end

function DrawEx.Ring (x, y, r, c)
  local x, y, sx, sy = padAndCenter(padRing, x, y, r, r)
  local shader = Cache.Shader('ui', 'ui/ring')
  local alpha = alphaStack:last() or 1
  BlendMode.PushAdditive()
  shader:start()
    Shader.SetFloat('radius', r)
    Shader.SetFloat2('size', sx, sy)
    Shader.SetFloat4('color', c.r, c.g, c.b, c.a * alpha)
    Draw.Rect(x, y, sx, sy)
  shader:stop()
  BlendMode.Pop()
end

function DrawEx.Tri (x1, y1, x2, y2, x3, y3, color)
  local xMin = min(x1, min(x2, x3)) - padTri
  local yMin = min(y1, min(y2, y3)) - padTri
  local xMax = max(x1, max(x2, x3)) + padTri
  local yMax = max(y1, max(y2, y3)) + padTri
  local shader = Cache.Shader('ui', 'ui/triangle')
  local alpha = alphaStack:last() or 1
  BlendMode.PushAdditive()
  shader:start()
    Shader.SetFloat2('p1', x1, y1)
    Shader.SetFloat2('p2', x2, y2)
    Shader.SetFloat2('p3', x3, y3)
    Shader.SetFloat4('color', color.r, color.g, color.b, color.a * alpha)
    Draw.Rect(xMin, yMin, xMax - xMin, yMax - yMin)
  shader:stop()
  BlendMode.Pop()
end

function DrawEx.TriV (p1, p2, p3, color)
  DrawEx.Tri(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, color)
end

function DrawEx.Wedge (x, y, r1, r2, to, tw, c, a)
  local x, y, sx, sy = padAndCenter(padWedge, x, y, 2.0 * r2, 2.0 * r2)
  local shader = Cache.Shader('ui', 'ui/wedge')
  local alpha = alphaStack:last() or 1
  BlendMode.PushAdditive()
  shader:start()
    Shader.SetFloat('r1', r1)
    Shader.SetFloat('r2', r2)
    Shader.SetFloat('to', to)
    Shader.SetFloat('tw', tw)
    Shader.SetFloat2('size', sx, sy)
    Shader.SetFloat4('color', c.r, c.g, c.b, (a or c.a) * alpha)
    Draw.Rect(x, y, sx, sy)
  shader:stop()
  BlendMode.Pop()
end

local function drawText (font, text, size, x, y, sx, sy, cr, cg, cb, ca, alignX, alignY)
  local ax = alignX or 0.0
  local ay = alignY or 1.0
  local font = Cache.Font(font, size)
  local bound = font:getSize(text)
  local shader = Cache.Shader('ui', 'ui/text')
  local alpha = alphaStack:last() or 1
  shader:start()
    Shader.SetFloat4('color', cr, cg, cb, ca * alpha)
    font:drawShaded(text,
      x + ax * (sx - bound.z) - bound.x,
      y + ay * (sy - bound.w) + bound.w)
  shader:stop()
end

function DrawEx.TextAdditive (...)
  BlendMode.PushAdditive()
  drawText(...)
  BlendMode.Pop()
end

function DrawEx.TextAlpha (...)
  BlendMode.PushAlpha()
  drawText(...)
  BlendMode.Pop()
end

return DrawEx
