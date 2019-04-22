local Bindings = require('UI.Bindings')
local Widget   = require('UI.Widget')

local Slider = {}
Slider.__index = Slider
setmetatable(Slider, Widget)

Slider.value    = 0
Slider.minValue = 0.0
Slider.maxValue = 1.0
Slider.getFn    = function() return 0.0 end
Slider.setFn    = function(value) Log.Warning('Slider - setFn has not been assigned') end
Slider.thumbSX  = 4
Slider.thumbSY  = 12

Slider.name      = 'Slider'
Slider.focusable = true
Slider.draggable = true

Slider:setHeight(14)
Slider.minX = 128

function Slider:onDrag (state)
  local setValue
  local x, y = self:getPosGlobal()
  setValue = Math.InverseLerp(x, x + self.sx - self.thumbSX, state.mousePosX)
  self:setValueNormalized(setValue)
end

-- TODO : Nuking scroll as a way to move sliders temporarily. It needs work.
function Slider:onInput (state)
  local sensitivity = 0.1

  -- HACK : Jank-fucking-tastic.
  Bindings.Right:get()
  Bindings.Left:get()
  Bindings.Up:get()
  Bindings.Down:get()

  local value = Vec2f(
    Bindings.Right.last - Bindings.Left.last,
    Bindings.Up.last - Bindings.Down.last
  )

  if value.x ~= 0.0 or value.y ~= 0.0 then
    local setValue
    setValue = Math.InverseLerp(self.minValue, self.maxValue, self.getFn())
    setValue = setValue + 0.1 * (value.x + value.y)
    self:setValueNormalized(setValue)
  end
end

function Slider:onUpdate (state)
  Widget.onUpdate(self, state)

  local getValue = self.getFn()
  if getValue < self.minValue or getValue > self.maxValue then
    if not self.didRangeWarning then
      self.didRangeWarning = true
      Log.Warning('Slider - Value returned from getFn (%s) is out of the range [%s, %s]',
        self.getFn(), self.minValue, self.maxValue
      )
    end
    getValue = Math.Clamp(getValue, self.minValue, self.maxValue)
  end

  getValue = Math.InverseLerp(self.minValue, self.maxValue, getValue)
  getValue = Math.Clamp(getValue, 0, 1)
  self.value = getValue
end

function Slider:onDraw (focus, active)
  local x, y, sx, sy = self:getRectGlobal()

  -- Value display
  --[[
  local font = Config.ui.font.normal
  local displayVal = Math.Lerp(self.minValue, self.maxValue, self.value)
  local valName = string.format("%.2f", displayVal)
  local bound = font:getSize(valName)
  local labelX = self.x + self.padSumX/2 + self.alignX * (self.sx - self.padSumX - bound.z)
  local labelY = self.y + self.padSumY/2 + self.alignY * (self.sy - self.padSumY + bound.y) - bound.y
  local color = Config.ui.color.textNormal
  font:draw(valName, labelX, labelY, color.r, color.g, color.b, color.a)
  --]]


  -- Bar
  local barSX = sx - self.thumbSX
  local barSY = 4
  local barX  = x + self.thumbSX/2
  local barY  = y + (sy - barSY)/2
  Config.ui.color.border:set()
  Draw.Rect(barX, barY, barSX, barSY)

  -- Thumb
  local thumbX = Math.Lerp(x, x + sx - self.thumbSX, self.value)
  local thumbY = y + (sy - self.thumbSY)/2
  self:applyColor(focus, active, Config.ui.color.fill)
  Draw.Rect(thumbX, thumbY, self.thumbSX, self.thumbSY)
end

function Slider:setValueNormalized (value)
  value = Math.Clamp(value, 0, 1)
  value = Math.Lerp(self.minValue, self.maxValue, value)
  self.setFn(value)
end

function Slider.Create (getFn, setFn, minValue, maxValue)
  local self = setmetatable({}, Slider)
  if getFn    then self.getFn    = getFn end
  if setFn    then self.setFn    = setFn end
  if minValue then self.minValue = minValue end
  if maxValue then self.maxValue = maxValue end
  return self
end

return Slider
