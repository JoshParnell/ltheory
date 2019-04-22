local Bindings  = require('UI.Bindings')
local Container = require('UI.Container')

local ScrollView = {}
ScrollView.__index = ScrollView
setmetatable(ScrollView, Container)

ScrollView.scrollAlphaTarget = 0
ScrollView.scrollAlphaValue  = 0

ScrollView.hScrollable   = true
ScrollView.hScrollMax    = 0
ScrollView.hScrollTarget = 0
ScrollView.hScrollValue  = 0
ScrollView.hDrag         = 0
ScrollView.hBarX         = 0
ScrollView.hBarY         = 0
ScrollView.hBarSX        = 0
ScrollView.hBarSY        = 0

ScrollView.vScrollable   = true
ScrollView.vScrollMax    = 0
ScrollView.vScrollTarget = 0
ScrollView.vScrollValue  = 0
ScrollView.vDrag         = 0
ScrollView.vBarX         = 0
ScrollView.vBarY         = 0
ScrollView.vBarSX        = 0
ScrollView.vBarSY        = 0

ScrollView.contentSX = 0
ScrollView.contentSY = 0

ScrollView.isScrollView = true
ScrollView.name         = 'Scroll View'
ScrollView.focusable    = false
ScrollView.draggable    = false

function ScrollView:findMouseFocus (mx, my, foci)
  if self.enabledT == 1 and self:containsPoint(mx, my) then
    foci.scrollFocus = self
    self:onFindMouseFocusChildren(mx, my, foci)
    if not foci.focus then
      self:onFindMouseFocus(mx, my, foci)
    end
  end
end

function ScrollView:onDrag (state)
  self.align  = false
  self.hDrag = -(state.mousePosX + state.dragOffsetX - self.x) * Math.Sign0(self.hScrollMax)
  self.vDrag = -(state.mousePosY + state.dragOffsetY - self.y) * Math.Sign0(self.vScrollMax)
end

function ScrollView:onDragEnd (state)
  self.hScrollValue = self.hScrollValue + self.hDrag
  self.vScrollValue = self.vScrollValue + self.vDrag
  self.hScrollTarget = Math.Clamp(self.hScrollTarget + self.hDrag, 0, self.hScrollMax)
  self.vScrollTarget = Math.Clamp(self.vScrollTarget + self.vDrag, 0, self.vScrollMax)
  self.hDrag = 0
  self.vDrag = 0
end

function ScrollView:keepFocusVisible (state)
  local fx, fy, fsx, fsy = state.focus:getRectGlobal()
  local ox = self.originX + self.x - Math.Round(self.hScrollValue + self.hDrag)
  local oy = self.originY + self.y - Math.Round(self.vScrollValue + self.vDrag)
  fx = fx - ox
  fy = fy - oy
  self.hScrollTarget = Math.ClampSafe(self.hScrollTarget, (fx + fsx) - self.sx, fx)
  self.vScrollTarget = Math.ClampSafe(self.vScrollTarget, (fy + fsy) - self.sy, fy)
end

function ScrollView:onInput (state)
  local sensitivity = -3000 -- -50
  local value

  -- TODO : Axis2D
  value = Bindings.ScrollH:get()
  if value ~= 0.0 then
    state.scrollActive = self
    self.hScrollTarget = Math.Clamp(self.hScrollTarget + sensitivity * value * state.dt, 0, self.hScrollMax)
  end

  value = Bindings.ScrollV:get()
  if value ~= 0.0 then
    state.scrollActive = self
    self.vScrollTarget = Math.Clamp(self.vScrollTarget + sensitivity * value * state.dt, 0, self.vScrollMax)
  end
end

function ScrollView:onUpdate (state)
  self.scrollAlphaTarget = state.scrollFocus == self and 1 or 0.15

  local f1 = 1.0 - exp(-11.0 * state.dt)
  self.hScrollValue     = Math.Lerp(self.hScrollValue,     self.hScrollTarget,     f1)
  self.vScrollValue     = Math.Lerp(self.vScrollValue,     self.vScrollTarget,     f1)
  self.scrollAlphaValue = Math.Lerp(self.scrollAlphaValue, self.scrollAlphaTarget, f1)

  Container.onUpdate(self, state)
end

function ScrollView:onLayoutSize ()
  self.contentSX = self.desiredSX - self.padSumX
  self.contentSY = self.desiredSY - self.padSumY

  if self.hScrollable then self.desiredSX = self.minSX end
  if self.vScrollable then self.desiredSY = self.minSY end
end

function ScrollView:onLayoutPos (px, py, psx, psy)
  Container.onLayoutPos(self, px, py, psx, psy)

  -- Scroll Bars
  self.hScrollMax = max(self.contentSX - (self.sx - self.padSumX), 0)
  self.vScrollMax = max(self.contentSY - (self.sy - self.padSumY), 0)
  self.hScrollTarget = min(self.hScrollTarget, self.hScrollMax)
  self.vScrollTarget = min(self.vScrollTarget, self.vScrollMax)

  if self.hScrollMax > 0 or self.vScrollMax > 0 then
    self.focusable = true
    self.draggable = true

    local barThickness = 3
    local x, y, sx, sy = self:getRect()

    -- Horizontal Scroll Bar
    self.hBarY  = y + sy - barThickness
    self.hBarSX = sx * (self.sx - self.padSumX) / self.contentSX
    self.hBarSY = barThickness

    -- Vertical Scroll Bar
    self.vBarX  = x + sx - barThickness
    self.vBarSX = barThickness
    self.vBarSY = sy * (self.sy - self.padSumY) / self.contentSY
  else
    -- TODO : If ScrollView suddenly becomes not draggable it should be removed from related Canvas state
    self.focusable = false
    self.draggable = false
  end
end

function ScrollView:onLayoutPosChildren ()
  local ox = self.originX + self.x - Math.Round(self.hScrollValue + self.hDrag)
  local oy = self.originY + self.y - Math.Round(self.vScrollValue + self.vDrag)
  for i = 1, #self.children do self.children[i]:layoutPos(ox, oy, self:getRectPadForChildren()) end
end

function ScrollView:onDrawChildren (focus, active)
  local x, y, sx, sy = self:getRectGlobal()
  ClipRect.PushCombined(x, y, sx, sy)
  for i = 1, #self.children do self.children[i]:draw(focus, active) end

  Config.ui.color.textTitle:set(self.scrollAlphaValue)

  if self.hScrollMax > 0 then
    self.hBarX = x + ((self.hScrollValue + self.hDrag) / self.hScrollMax) * (sx - self.hBarSX)
    Draw.Rect(self.hBarX, self.hBarY, self.hBarSX, self.hBarSY)
  end

  if self.vScrollMax > 0 then
    self.vBarY = y + ((self.vScrollValue + self.vDrag) / self.vScrollMax) * (sy - self.vBarSY)
    Draw.Rect(self.vBarX, self.vBarY, self.vBarSX, self.vBarSY)
  end
  ClipRect.Pop()
end

function ScrollView:onDrawDebugChildren (focus, active)
  ClipRect.PushCombined(widget:getRectGlobal())
  for i = 1, #self.children do self.children[i]:drawDebug(focus, active) end
  ClipRect.Pop()
end

function ScrollView:setScrollable (hScrollable, vScrollable)
  self.hScrollable = hScrollable
  self.vScrollable = vScrollable
  return self
end

function ScrollView.Create ()
  return setmetatable({
    children = List(),
  }, ScrollView)
end

return ScrollView
