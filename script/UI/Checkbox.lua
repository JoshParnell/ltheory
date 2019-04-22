local Widget = require('UI.Widget')

local Checkbox = {}
Checkbox.__index = Checkbox
setmetatable(Checkbox, Widget)

Checkbox.checked = false
Checkbox.getFn   = function() return false end
Checkbox.setFn   = function(enabled) Log.Warning('Checkbox - setFn has not been assigned') end
Checkbox.dimBox  = 14
Checkbox.dimFill = 6

Checkbox.name      = 'Checkbox'
Checkbox.focusable = true

Checkbox.desiredSX = Checkbox.dimBox + Checkbox.padSumX
Checkbox.desiredSY = Checkbox.dimBox + Checkbox.padSumY

function Checkbox:onClick (state)
  self.setFn(not self.checked)
  self.checked = self.getFn()
end

function Checkbox:onUpdate (state)
  self.checked = self.getFn()
end

function Checkbox:onDraw (focus, active)
  local x, y, sx, sy = self:getRectGlobal()

  -- Background
  local boxX = x + self.padSumX/2
  local boxY = y + (sy - self.dimBox)/2
  self:applyColor(focus, active, Config.ui.color.border)
  Draw.Rect(boxX, boxY, self.dimBox, self.dimBox)

  -- Checkmark
  if self.checked then
    local fillX = boxX + (self.dimBox - self.dimFill)/2
    local fillY = boxY + (self.dimBox - self.dimFill)/2
    Config.ui.color.fill:set()
    Draw.Rect(fillX, fillY, self.dimFill, self.dimFill)
  end
end

function Checkbox.Create (getFn, setFn)
  local self = setmetatable({}, Checkbox)
  if getFn then self.getFn = getFn end
  if setFn then self.setFn = setFn end
  return self
end

return Checkbox
