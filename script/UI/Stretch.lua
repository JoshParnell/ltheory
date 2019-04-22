local Widget = require('UI.Widget')

local Stretch = {}
Stretch.__index = Stretch
setmetatable(Stretch, Widget)

Stretch.desiredSX = 0
Stretch.desiredSY = 0

function Stretch:onDraw (focus, active)
  if self.fillColor then
    self.fillColor:set()
    Draw.Rect(self:getRectGlobal())
  end
end

function Stretch:setFillColor (color)
  self.fillColor = color
  return self
end

function Stretch.Create (stretchX, stretchY)
  stretchX = stretchX or 1
  stretchY = stretchY or 1

  local self = setmetatable({
    fillColor = nil,
  }, Stretch)

  self:setStretch(stretchX, stretchY)
  return self
end

return Stretch
