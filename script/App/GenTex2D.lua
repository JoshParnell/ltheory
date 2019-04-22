local GenTex2D = Application()

local kTexSize = 1024
local rng = RNG.FromTime()

local vs = Cache.File('../shared/res/shader/vertex/ui.glsl')

-- Main generating fragment shader
local fs = [[

#include fragment
#include noise
#include math
#include bezier

/* Declare inputs. */
uniform vec2 size;
uniform float seed;
uniform float borderThreshold;

void main() {
  vec3 c = vec3(0.0);

  /* Compute frag color. */ {

    vec2 t = cellNoiseMH(7.0 * uv, seed);
    c = vec3(1.0, 1.0, 1.0) * exp(-32.0 * abs(t.x - t.y));
    //c = vec3(t.x, t.x, t.x);
  }

  /* Tonemap, just for the purpose of viewing. This is roughly the same
     tonemap under which an in-game texture runs. */ {
    c = 1.0 - exp(-2.3 * pow(c, 1.25 + c));
  }

  /* Output frag color. */ {
    gl_FragColor.xyz = c;
    gl_FragColor.w = 1.0;
  }
}

]]

function GenTex2D:onSetShaderVars ()
  -- Set shader variables here
  Shader.SetFloat('seed', rng:getUniformRange(0, 1000.0))
  Shader.SetFloat2('size', kTexSize, kTexSize)
  Shader.SetFloat('borderThreshold', 0.01)
end

function GenTex2D:onGenerate ()
  do -- Free old texture
    if self.texture ~= nil then
      self.texture:free()
      self.texture = nil
    end
  end

  do -- Generate new texture
    local tex = Tex2D.Create(kTexSize, kTexSize, TexFormat.RGBA16F)

    RenderState.PushAllDefaults()
    tex:push()
    Draw.Clear(0, 0, 0, 1)

    self:DrawWorn(tex)

    tex:pop()
    Draw.Color(1, 1, 1, 1)
    RenderState.PopAll()

    tex:genMipmap()
    tex:setMagFilter(TexFilter.Linear)
    tex:setMinFilter(TexFilter.LinearMipLinear)
    self.texture = tex
  end
end

function GenTex2D:DrawWorn(tex)
  -- blank grey texture
  Draw.Color(0.8, 0.8, 0.8, 1)
  Draw.Rect(0, 0, kTexSize, kTexSize)

  Draw.Color(0.5, 0.5, 0.5, 1)
  Draw.LineWidth(2)
  -- rect plates with line details
  local n = 10
  local w = kTexSize / n
  for i = 0, n - 1 do
    -- outer rect
    local x = i*w
    Draw.Border(5, x, 0, x + w, kTexSize)
    -- inner detail lines
    local nd = rng:getInt(1, 3)
    local dist = Gen.MathUtil.GenerateNumsThatAddToSum(nd, w, rng)
    local dx = x
    for j = 0, nd - 1 do
      local y = rng:getUniformRange(0, kTexSize)
      Draw.Line(dx, 0, dx, y)
      dx = dx + dist[j+1]
    end
  end
end

function GenTex2D:DrawCel(tex)
  self.genShader:start()
  self:onSetShaderVars()
  Draw.Rect(0, 0, kTexSize, kTexSize)
  self.genShader:stop()
end

function GenTex2D:DrawRect1 (tex)
  local kHalfTS = kTexSize * 0.5

  -- blank grey texture
  Draw.Color(0.8, 0.8, 0.8, 1)
  Draw.Rect(0, 0, kTexSize, kTexSize)

  -- buncha random dark grey boxes
  Draw.Color(0.5, 0.5, 0.5, 1)
  local lineWidth = 2
  Draw.LineWidth(lineWidth)
  local numRows = 10
  local rowHeight = kTexSize / numRows
  local numCols = 0
  local columnWidths = {}
  local x, y
  for i = 0, numRows - 1 do
    x = 0
    y = rowHeight * i
    numCols = rng:getInt(5, 20)
    columnWidths = Gen.MathUtil.GenerateNumsThatAddToSum(numCols, kTexSize, rng)
    for j = 1, numCols do
      Draw.Border(lineWidth, x, y, columnWidths[j], rowHeight)
      -- vertical box subdivision
      local sub = rng:choose({0, 0, 0, 1, 2, 3, 4, 5})
      local subHeight = rowHeight / sub
      for k = 0, sub-1 do
        Draw.Line(x, y + k*subHeight, x+columnWidths[j], y + k*subHeight)
      end
      -- increment x-pos
      x = x + columnWidths[j]
    end
  end

  -- buncha random small boxes
  --[[
  Draw.Color(0.2, 0.2, 0.2, 1)
  local numBoxes = rng:getInt(50, 100)
  local width, length
  for i = 0, numBoxes do
    width = rng:getUniformRange(kTexSize/100, kTexSize/50)
    length = rng:getUniformRange(kTexSize/100, kTexSize/50)
    x = rng:getUniformRange(0, kTexSize)
    y = rng:getUniformRange(0, kTexSize)
    Draw.Rect(x, y, width, length)
  end--]]
end

function GenTex2D:onInit ()
  self.genShader = Shader.Create(vs, fs)
  self.zoom = 1
  self.zoomT = 1
  self.panX = 0
  self.panY = 0
  self:onGenerate()
end

function GenTex2D:onUpdate (dt)
  if Input.GetDown(Button.Keyboard.LCtrl) and Input.GetPressed(Button.Keyboard.W) then self:quit() end
  if Input.GetPressed(Button.Keyboard.Space) then self:onGenerate() end
  if Input.GetDown(Button.Mouse.Left) then
    local dp = Input.GetMouseDelta()
    self.panX = self.panX + dp.x / self.zoom
    self.panY = self.panY + dp.y / self.zoom
  end
  self.zoomT = self.zoomT * exp(0.1 * Input.GetValue(Button.Mouse.ScrollY))
  self.zoom = Math.Lerp(self.zoom, self.zoomT, 1.0 - exp(-16.0 * dt))
end

function GenTex2D:onDraw ()
  local sx = self.zoom * kTexSize
  local sy = self.zoom * kTexSize
  local x = (self.resX - sx) / 2 + self.panX * self.zoom
  local y = (self.resY - sy) / 2 + self.panY * self.zoom
  Draw.Clear(0.1, 0.1, 0.1, 1.0)
  self.texture:draw(x, y, sx, sy)
end

return GenTex2D
