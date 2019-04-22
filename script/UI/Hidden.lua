local Container = require('UI.Container')
local Widget    = require('UI.Widget')

local Hidden = {}
Hidden.__index = Hidden
setmetatable(Hidden, Container)

local default = 'Section Title'

function Hidden:setPadY (minY, maxY)
  minY = minY + Math.Round(1.4 * Config.ui.font.titleSize)
  return Widget.setPadY(self, minY, maxY)
end

Hidden.title    = nil
Hidden.expanded = false

Hidden:setPad(2, 0, 2, 2)
Hidden:setMinWidth(128)

function Hidden:onFindMouseFocusChildren (mx, my, focii)
  if self.expanded then
    for i = #self.children, 1, -1 do
      self.children[i]:findMouseFocus(mx, my, foci)
      if foci.focus then return end
    end
  end
end

function Hidden:onUpdate (state)
  if self.pollFn then self.expanded = self.pollFn() end
end

function Hidden:onUpdateChildren (state)
  if self.expanded then
    for i = 1, #self.children do
      local child = self.children[i]
      if not child.removed then child:update(state) end
    end
  end
end

function Hidden:onLayoutSizeChildren ()
  if self.expanded then
    for i = 1, #self.children do
      local child = self.children[i]

      child:layoutSize()
      if child.sx > 0 then self.desiredSX = max(self.desiredSX, child.x + child.sx + self.padMaxX) end
      if child.sy > 0 then self.desiredSY = max(self.desiredSY, child.y + child.sy + self.padMaxY) end
    end
  end
end

function Hidden:onLayoutSize ()
  if not self.expanded then
    self.desiredSX = self.minSX
    self.desiredSY = self.padMinY
  end

  -- Header and Title
  local font  = Config.ui.font.title
  local bound = font:getSize(self.title)
  self.desiredSX = max(self.desiredSX, self.padSumX + bound.z + 4*self.padSumX)
end

function Hidden:onLayoutPos (px, py, psx, psy)
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

function Hidden:onLayoutPosChildren ()
  if self.expanded then
    local ox, oy = self:getPosGlobal()
    for i = 1, #self.children do self.children[i]:layoutPos(ox, oy, self:getRectPadForChildren()) end
  end
end

function Hidden:onDraw (focus, active)
  local x, y = self:getPosGlobal()

  -- Header background
  Config.ui.color.border:set()
  Draw.Rect(x, y, self.sx, self.padMinY)

  -- Header title
  local font  = Config.ui.font.title
  local color = Config.ui.color.textTitle
  local bound = font:getSize(self.title)
  font:draw(self.title,
    x + (self.sx      - bound.z) / 2 - bound.x,
    y + (self.padMinY - bound.w) / 2 - bound.y + 1,
    color.r, color.g, color.b, color.a)
end

function Hidden:onDrawChildren (focus, active)
  if self.expanded then
    for i = 1, #self.children do self.children[i]:draw(focus, active) end
  end
end

function Hidden:onDrawDebugChildren (focus, active)
  if self.expanded then
    for i = 1, #self.children do self.children[i]:drawDebug(focus, active) end
  end
end

function Hidden:setPollFn (pollFn)
  self.pollFn = pollFn
  return self
end

function Hidden.Create (title, expanded)
  title    = title or default
  expanded = expanded or false

  return setmetatable({
    expanded = expanded,
    title    = title,
    name     = string.format('Hidden %s', tostring(title)),
    children = List(),
  }, Hidden)
end

return Hidden
