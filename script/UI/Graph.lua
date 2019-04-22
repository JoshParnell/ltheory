local Widget = require('UI.Widget')

local Graph = {}
Graph.__index = Graph
setmetatable(Graph, Widget)

Graph.Mode = {
  Scroll = 0,
  Sweep = 1,
  Scatter = 2,
  SIZE = 3,
}

local barSX       = 1
local barSpace    = 0
local barTotal    = barSX + barSpace
local hysteresis  = 0.5

Graph.rangeMin   = nil
Graph.rangeMax   = nil
Graph.modeScroll = nil
Graph.modeSweep  = nil
Graph.values     = nil

Graph.fixedRangeMin = nil
Graph.fixedRangeMax = nil
Graph.minValue      = nil
Graph.maxValue      = nil
Graph.barCount      = nil
Graph.head          = nil
Graph.quads         = nil

Graph.name      = 'Graph'
Graph.focusable = true

Graph:setStretch(1.0, 0.0)
Graph:setAlign(0.5, 0.5)
-- NOTE : The border assumes uniform padding
Graph:setPadUniform(1)

--[[ TODO
  Hysteresis doesn't feel good (moves too much)
  Scroll wheel to zoom y axis
  Shift scroll wheel to zoom x axis
  Middle click to pop out into resizable Panel
--]]

function Graph:onClick (state)
  self:setMode((self.mode + 1) % Graph.Mode.SIZE)
end

function Graph:onUpdate (state)
  Widget.onUpdate(self, state)
  if self.pollFn then
    self:append(self.pollFn(state.dt))
  end

  if not self.fixedRangeMin then
    local change = math.abs(self.minValue - self.rangeMin.target)
    self.rangeMin.target = self.minValue - 0.5 * math.abs(self.minValue)
  end
  if not self.fixedRangeMax then
    local change = math.abs(self.maxValue - self.rangeMax.target)
    self.rangeMax.target = self.maxValue + 0.5 * math.abs(self.maxValue)
  end

  local f1 = 1.0 - math.exp(-2.0 * state.dt)
  self.rangeMin.value = Math.Lerp(self.rangeMin.value, self.rangeMin.target, f1)
  self.rangeMax.value = Math.Lerp(self.rangeMax.value, self.rangeMax.target, f1)
end

function Graph:onLayoutPos (px, py, psx, psy)
  Widget.onLayoutPos(self, px, py, psx, psy)

  self.barCount = math.max(1, math.floor((self.sx - self.padSumX + barSpace) / barTotal))

  -- Clamp size to exactly fit bars
  if not self.fixedSX then
    self.sx = self.barCount * barTotal - barSpace + self.padSumX
    self.x = px + self.alignX * (psx - self.sx)
  end

  -- Grow buffer if necessary
  while #self.values < self.barCount do
    self.values:add((self.minValue + self.maxValue) / 2.0)
  end

  -- Shrink buffer if necessary
  while #self.values > self.barCount do
    self.values:removeAt(1)
  end
  self.head = math.min(self.head, #self.values)
end

function Graph:onDraw (focus, active)
  local x, y, sx, sy = self:getRectGlobal()

  do -- Draw Border
    self:applyColor(focus, active, Config.ui.color.border)
    Draw.Border(self.padMinX, x, y, sx, sy)
  end

  local ix, iy, isx, isy = self:getRectPadGlobal()
  ClipRect.PushCombined(ix, iy, isx, isy)

  do -- Draw Graph
    local usableSY = isy
    local range    = self.rangeMax.value - self.rangeMin.value
    local vMin     = self.rangeMin.value
    local dydv     = usableSY / range

    GLMatrix.ModeWV()
    GLMatrix.Push()
    GLMatrix.Translate(0, y + sy - self.padMaxY, 0)
    GLMatrix.Scale(1, -(sy / usableSY), 1)

    do -- Draw Bars
      Config.ui.color.focused:set(0.25)
      local fx = ix
      for i = 1, #self.values do
        local fy = dydv * (self.values:get(i) - vMin)
        Draw.Rect(fx, 0, barSX, fy)
        fx = fx + barTotal
      end
    end

    do -- Draw Lines
      Draw.LineWidth(1.0)
      Config.ui.color.focused:set()
      local xLast = ix
      local fx = xLast + barTotal
      local yLast = dydv * (self.values:get(1) - vMin)
      for i = 2, #self.values do
        local value = self.values:get(i)
        local fy = dydv * (value - vMin)
        Draw.Line(xLast, yLast, fx, fy)
        xLast = fx
        yLast = fy
        fx = fx + barTotal
      end
    end

    -- Draw ruler crossings
    if #self.rulers > 0 then
      local fx = ix
      for i = 1, #self.values do
        local value = self.values:get(i)
        local y = dydv * (value - vMin)
        for j = 1, #self.rulers do
          local ruler = self.rulers[j]
          if value >= ruler.value then
            Draw.Color(ruler.color.x, ruler.color.y, ruler.color.z, 1)
            Draw.Rect(fx - 2, dydv * (ruler.value - vMin) - 2, 4, 4)
          end
        end
        fx = fx + barTotal
      end
    end

    do -- Highlight Head
      Config.ui.color.focused:set()
      Draw.Rect(
        ix + (self.head - 1) * barTotal,
        0, barSX, dydv * (self.values:get(self.head) - vMin))
    end

    do -- Draw Rulers
      for i = 1, #self.rulers do
        local ruler = self.rulers[i]
        local fy = dydv * (ruler.value - vMin)
        ruler.y = fy
        Draw.Color(ruler.color.x, ruler.color.y, ruler.color.z, 0.75)
        Draw.Line(ix, fy, ix + isx, fy)
      end
    end

    GLMatrix.Pop()
  end

  do -- Draw Ruler Labels
    local font = Config.ui.font.normal
    for i = 1, #self.rulers do
      local ruler = self.rulers[i]
      local bound = font:getSize(ruler.label)
      font:draw(ruler.label,
        ix + isx - bound.x - bound.z,
        y + sy - ruler.y + bound.w,
        1.0, 1.0, 1.0, 0.25)
    end
  end

  ClipRect.Pop()

  do -- Draw Min / Max Labels
    local textPad = self.padMaxX + 2
    local color   = Config.ui.color.textTitle
    local font    = Config.ui.font.normal
    local text    = string.format('%.1f', self.rangeMax.value)
    local bound   = font:getSize(text)
    font:draw(text,
      x + sx - textPad - bound.x - bound.z,
      y + textPad + bound.w,
      color.r, color.g, color.b, color.a)

    text = string.format('%.1f', self.rangeMin.value)
    bound = font:getSize(text)
    font:draw(text,
      x + sx - textPad - bound.x - bound.z,
      y + sy - textPad,
      color.r, color.g, color.b, color.a)
  end
end

function Graph:addRuler (value, label, color, alwaysVisible)
  table.insert(self.rulers, {
    value = value,
    label = label,
    color = color,
  })

  if alwaysVisible then table.insert(self.rulerValues, value) end
  return self
end

function Graph:append (value)
  if self.mode == Graph.Mode.Scroll then
    self.head = self.barCount
    self.values:removeAt(1)
    self.values:add(value)
  elseif self.mode == Graph.Mode.Sweep then
    self.head = Math.Wrap(self.head + 1, 1, self.barCount)
    self.values:set(self.head, value)
  elseif self.mode == Graph.Mode.Scatter then
    self.head = math.random(1, self.barCount)
    self.values:set(self.head, value)
  end

  self.minValue =  1e6
  self.maxValue = -1e6
  for i = 1, #self.values do
    local v = self.values:get(i)
    self.minValue = math.min(self.minValue, v)
    self.maxValue = math.max(self.maxValue, v)
  end

  for i = 1, #self.rulerValues do
    self.minValue = math.min(self.minValue, self.rulerValues[i])
    self.maxValue = math.max(self.maxValue, self.rulerValues[i])
  end
end

function Graph:setMode (mode)
  self.mode = mode
  return self
end

function Graph:setPollFn (pollFn)
  self.pollFn = pollFn
  return self
end

function Graph.Create (rangeMin, rangeMax)
  local fixedRangeMin = rangeMin ~= nil
  local fixedRangeMax = rangeMax ~= nil
  rangeMin = rangeMin or 0
  rangeMax = rangeMax or 0

  local self = setmetatable({
    rangeMin      = { value = rangeMin, target = rangeMin },
    rangeMax      = { value = rangeMax, target = rangeMax },
    values        = CType.Array(CType.Float32):new(),
    rulers        = {},
    rulerValues   = {},
    fixedRangeMin = fixedRangeMin,
    fixedRangeMax = fixedRangeMax,
    mode          = Graph.Mode.Sweep,
    pollFn        = nil,
    minValue      = 0,
    maxValue      = 0,
    barCount      = 0,
    head          = 0,
  }, Graph)

  self:layoutSize()
  self:layoutPos(self.originX, self.originY, self:getRect())
  return self
end

return Graph
