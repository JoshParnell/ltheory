local Icon   = require('UI.Icon')
local Widget = require('UI.Widget')

local IconButton = {}
IconButton.__index = IconButton
setmetatable(IconButton, Widget)

IconButton.name      = 'IconButton'
IconButton.focusable = true

local defaultOnClick = function (self, state) end
local defaultIcon    = Icon()

function IconButton:onDraw (focus, active)
  self.icon.onDraw(self, focus, active)
end

function IconButton:setIcon (icon)
  icon = icon or defaultIcon
  self.icon = icon
  return self
end

function IconButton:setOnClick (onClick)
  onClick = onClick or defaultOnClick
  self.onClick = onClick
  return self
end

function IconButton.Create (icon, onClick)
  local self = setmetatable({}, IconButton)
  self:setOnClick(onClick)
  self:setIcon(icon)
  return self
end

return IconButton
