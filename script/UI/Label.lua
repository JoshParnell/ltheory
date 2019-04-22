local Widget = require('UI.Widget')

local Label = {}
Label.__index = Label
setmetatable(Label, Widget)

Label.name = 'Label'
Label:setStretch(0.0, 0.0)
Label:setAlign(0.0, 0.5)

function Label:onUpdate (state)
  if self.pollFn then self:setText(self.pollFn()) end
end

function Label:onDraw (focus, active)
  self:drawText(self.font, self.text, self.bound, self.fontColor)
end

function Label:setFormat (format)
  self.format = format
  return self
end

function Label:setText (text)
  -- NOTE : Text may not be a string! Automatic conversion is supported.
  if self.format then
    self.text = format(self.format, text)
  else
    self.text = tostring(text)
  end

  self.bound     = self.font:getSize(self.text)
  self.desiredSX = self.padSumX + self.bound.z
  self.desiredSY = self.padSumY + ceil(self.bound.w / self.fontSize) * self.fontSize
  return self
end

function Label:setPollFn (pollFn)
  self.pollFn = pollFn
  return self
end

function Label.Create (text)
  -- NOTE : Changing the font after label creation is currently unsupported.
  if not Label.init then
    Label.init      = true
    Label.font      = Config.ui.font.normal
    Label.fontSize  = Config.ui.font.normalSize
    Label.fontColor = Config.ui.color.textNormal
  end

  local self = setmetatable({}, Label)
  self:setText(text)
  return self
end

return Label
