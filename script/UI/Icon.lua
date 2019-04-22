-- NOTE : This is just a placeholder.

local Icon = class(function (self, onDraw)
  self:setOnDraw(onDraw)
end)

local defaultOnDraw = function (self, focus, active) end

function Icon:setOnDraw (onDraw)
  onDraw = onDraw or defaultOnDraw
  self.onDraw = onDraw
  return self
end

return Icon
