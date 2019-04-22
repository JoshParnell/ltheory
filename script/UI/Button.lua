local Widget = require('UI.Widget')

local Button = {}
Button.__index = Button
setmetatable(Button, Widget)

Button.name      = 'Button'
Button.focusable = true

Button:setPadUniform(6)

local defaultText = ' '
local defaultOnClick = function (self, state) end

function Button:onDraw (focus, active)
  self:applyColor(focus, active, Config.ui.color.border)
  local textCol = focus == self
                  and Config.ui.color.textNormalFocused
                  or  Config.ui.color.textNormal

  local x, y, sx, sy = self:getRectGlobal()
  Draw.Rect(x, y, sx, sy)

  -- Center without considering descenders
  local font  = Config.ui.font.normal
  local bound = font:getSize(self.text)
  font:draw(self.text,
      x - bound.x + (sx - bound.z)/2,
      y - bound.y + (sy + bound.y)/2,
      textCol.r, textCol.g, textCol.b, textCol.a)
end

function Button:setText (text)
  self.text = text or defaultText
  self.name = string.format('Button %s', tostring(self.text))
  local bound = Config.ui.font.normal:getSize(self.text)
  self.desiredSX = self.padSumX + bound.z
  self.desiredSY = self.padSumY + bound.w
  return self
end

function Button:setOnClick (onClick)
  onClick = onClick or defaultOnClick
  self.onClick = onClick
  return self
end

function Button.Create (text, onClick)
  local self = setmetatable({}, Button)
  self:setText(text)
  self:setOnClick(onClick)
  return self
end

return Button
