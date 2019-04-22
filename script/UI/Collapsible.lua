local Container = require('UI.Container')
local Rect      = require('UI.Rect')
local Widget    = require('UI.Widget')

local Collapsible = {}
Collapsible.__index = Collapsible
setmetatable(Collapsible, Container)

local default = 'Collapsible'

function Collapsible:setPadY (minY, maxY)
  minY = minY + Math.Round(1.4 * Config.ui.font.titleSize)
  return Widget.setPadY(self, minY, maxY)
end

Collapsible.expanded = true
Collapsible.title    = nil

Collapsible.name      = 'Collapsible'
Collapsible.focusable = true

Collapsible:setPad(2, 0, 2, 2)
Collapsible:setMinWidth(128)

Collapsible.triPad  = 4*Collapsible.padMinX
Collapsible.triSize = 6

function Collapsible:onFindMouseFocus (mx, my, foci)
  if self.focusable then
    local x, y = self:getPosGlobal()
    if Rect.containsPoint(x, y, self.sx, self.padMinY, mx, my) then
      foci.focus = self
    end
  end
end

function Collapsible:onFindMouseFocusChildren (mx, my, foci)
  if self.expanded then
    for i = #self.children, 1, -1 do
      self.children[i]:findMouseFocus(mx, my, foci)
      if foci.focus then return end
    end
  end
end

function Collapsible:onClick (state)
  self.expanded = not self.expanded
end

-- TODO : Always update children
function Collapsible:onUpdateChildren (state)
  if self.expanded then
    for i = 1, #self.children do
      local child = self.children[i]
      if not child.removed then child:update(state) end
    end
  end
end

function Collapsible:onLayoutSizeChildren ()
  if self.expanded then
    for i = 1, #self.children do
      local child = self.children[i]

      child:layoutSize()
      if child.sx > 0 then self.desiredSX = max(self.desiredSX, child.x + child.sx + self.padMaxX) end
      if child.sy > 0 then self.desiredSY = max(self.desiredSY, child.y + child.sy + self.padMaxY) end
    end
  end
end

function Collapsible:onLayoutSize ()
  if not self.expanded then
    self.desiredSX = self.minSX
    self.desiredSY = self.padMinY
  end

  -- Header and Title
  local font  = Config.ui.font.title
  local bound = font:getSize(self.title)
  self.desiredSX = max(self.desiredSX, self.padSumX + bound.z + 2*(self.triPad + self.triSize) + 4*self.padSumX)
end

function Collapsible:onLayoutPos (px, py, psx, psy)
  if not self.expanded then
    -- Disable vertical stretching when collapsed
    local stretchY = self.stretchY
    self.stretchY = 0
    Widget.onLayoutPos(self, px, py, psx, psy)
    self.stretchY = stretchY
  else
    Widget.onLayoutPos(self, px, py, psx, psy)
  end
end

function Collapsible:onLayoutPosChildren ()
  if self.expanded then
    local ox, oy = self:getPosGlobal()
    for i = 1, #self.children do self.children[i]:layoutPos(ox, oy, self:getRectPadForChildren()) end
  end
end

function Collapsible:onDraw (focus, active)
  local x, y, sx, sy = self:getRectGlobal()
  local ts = self.triSize
  local tp = Vec2f(x + self.triPad, y + (self.padMinY + ts)/2)
  local a, b, c

  if self.expanded then
    Config.ui.color.border:set()
    Draw.Rect(x, y, sx, self.padMinY)

    self:applyColor(focus, active, Config.ui.color.border)
    Draw.Rect(x, y + self.padMinY, self.padMinX, sy - self.padSumY)
    Draw.Rect(x, y + sy - self.padMaxY, min(12, sx), self.padMaxY)

    a = tp + Vec2f( 0,   0)
    b = tp + Vec2f(ts,   0)
    c = tp + Vec2f(ts, -ts)
  else
    -- Header Only
    Config.ui.color.border:set()
    Draw.Rect(x, y, sx, self.padMinY)

    local r2 = sqrt(2)
    local os = ((r2 - 1) * ts) / 2
    a = tp + Vec2f((modf(0    )), (modf(         os)))
    b = tp + Vec2f((modf(ts/r2)), (modf(-ts/r2 + os)))
    c = tp + Vec2f((modf(0    )), (modf(-ts*r2 + os)))
  end

  -- Collapsed Indicator
  self:applyColor(focus, active, Config.ui.color.fill)
  Draw.Tri(a, b, c);

  -- Header Title
  local font  = Config.ui.font.title
  local color = Config.ui.color.textTitle
  local bound = font:getSize(self.title)

  self:drawTextRectCentered(
    font, self.title, bound, color,
    x, y, sx, self.padMinY + 2)
end

function Collapsible:onDrawChildren (focus, active)
  if self.expanded then
    for i = 1, #self.children do self.children[i]:draw(focus, active) end
  end
end

function Collapsible:onDrawDebugChildren (focus, active)
  if self.expanded then
    for i = 1, #self.children do self.children[i]:drawDebug(focus, active) end
  end
end

function Collapsible.Create (title, expanded)
  title = title or default

  return setmetatable({
    expanded = expanded,
    title    = title,
    name     = string.format('Collapsible %s', tostring(title)),
    children = List(),
  }, Collapsible)
end

return Collapsible
