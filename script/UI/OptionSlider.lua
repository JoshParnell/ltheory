local Bindings = require('UI.Bindings')
local Widget   = require('UI.Widget')

local OptionSlider = {}
OptionSlider.__index = OptionSlider
setmetatable(OptionSlider, Widget)

OptionSlider.value     = 0
OptionSlider.minValue  = 0
OptionSlider.maxValue  = 1
OptionSlider.elems     = nil
OptionSlider.getFn     = function() return 0.0 end
OptionSlider.setFn     = function(value) Log.Warning('OptionSlider - setFn has not been assigned') end

OptionSlider.dimBox  = 14

OptionSlider.name      = 'OptionSlider'
OptionSlider.focusable = true
OptionSlider.draggable = true

OptionSlider:setHeight(14)
OptionSlider:setAlign(0.0, 0.5)
OptionSlider.minX = 128

function OptionSlider:onClick (state)
  self:setNextValue()
end

function OptionSlider:onInput (state)
  if Bindings.Right:get() > 0 or Bindings.Down:get() > 0 then
    self:setNextValue()
  end

  if Bindings.Left:get() > 0 or Bindings.Up:get() > 0 then
    self:setPrevValue()
  end
end

function OptionSlider:onUpdate (state)
  Widget.onUpdate(self, state)

  local getValue = self.getFn()
  if getValue < self.minValue or getValue > self.maxValue then
    if not self.didRangeWarning then
      self.didRangeWarning = true
      Log.Warning('OptionSlider - Value returned from getFn (%s) is out of the range [%s, %s]',
        self.getFn(), self.minValue, self.maxValue
      )
    end
    getValue = Math.Clamp(getValue, self.minValue, self.maxValue)
  end

  self.value = getValue
end

function OptionSlider:onDraw (focus, active)
  local x, y, sx, sy = self:getRectGlobal()

  -- triangles
  local triSize = 8
  local tri2 = triSize / 2
  local padRight = Vec2f(x + sx - triSize, y + sy - tri2)
  local a = padRight + Vec2f(0, 0)
  local b = padRight + Vec2f(0, -triSize)
  local c = padRight + Vec2f(tri2, -tri2)
  local padLeft = Vec2f(x, y + sy - tri2)
  local a1 = padLeft + Vec2f(0, -tri2)
  local b1 = padLeft + Vec2f(tri2, -triSize)
  local c1 = padLeft + Vec2f(tri2, 0)
  self:applyColor(focus, active, Config.ui.color.fill)
  Draw.Tri(a, b, c);
  Draw.Tri(a1, b1, c1);

  -- Value Label
  local font = Config.ui.font.normal
  local valName = self.elems[self.value]
  local bound = font:getSize(valName)
  local labelX = x - bound.x + (sx - bound.z)/2 - triSize
  local labelY = y - bound.y + (sy + bound.y)/2
  local color = Config.ui.color.textNormal
  local textX = labelX + triSize
  font:draw(valName, textX, labelY, color.r, color.g, color.b, color.a)

end

function OptionSlider:setNextValue ()
  self.value = Math.Wrap(self.value + 1, self.minValue, self.maxValue)
  self.setFn(self.value)
end

function OptionSlider:setPrevValue ()
  self.value = Math.Wrap(self.value - 1, self.minValue, self.maxValue)
  self.setFn(self.value)
end

function OptionSlider.Create (getFn, setFn, elems, val)
  local self = setmetatable({}, OptionSlider)
  if getFn    then self.getFn    = getFn end
  if setFn    then self.setFn    = setFn end
  if elems    then self.minValue = 1 end
  if elems    then self.maxValue = #elems end
  if elems    then self.elems    = elems end
  if val      then self.value    = val end
  return self
end

return OptionSlider
