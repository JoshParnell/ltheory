--[[----------------------------------------------------------------------------
  Base metatable for all UI widgets. Provides default property values and basic
  widget functions.
----------------------------------------------------------------------------]]--
local Rect = require('UI.Rect')

local Widget = {}
Widget.__index    = Widget
Widget.__call     = function (t, ...) return t.Create(...) end
Widget.__tostring = function (t) return t.name end

Widget.name    = 'Widget'
Widget.parent  = nil
Widget.removed = false

Widget.focusable = false
Widget.draggable = false
Widget.align     = true
Widget.clamp     = true

Widget.originX = 0
Widget.originY = 0
Widget.x       = 0
Widget.y       = 0
Widget.sx      = 0
Widget.sy      = 0

Widget.padMinX = 0
Widget.padMaxX = 0
Widget.padMinY = 0
Widget.padMaxY = 0
Widget.padSumX = 0
Widget.padSumY = 0

Widget.desiredSX = 128
Widget.desiredSY = 128
Widget.minSX     = 0
Widget.minSY     = 0
Widget.maxSX     = 1e6
Widget.maxSY     = 1e6
Widget.fixedSX   = nil
Widget.fixedSY   = nil

Widget.stretchX = 1.0
Widget.stretchY = 1.0
Widget.alignX   = 0.0
Widget.alignY   = 0.0

-- UI Loop Events, presented in the order they are called ----------------------

function Widget:findMouseFocus (mx, my, foci)             end
function Widget:dragBegin      (state)                    end
function Widget:drag           (state)                    end
function Widget:dragEnd        (state)                    end
function Widget:click          (state)                    end
function Widget:inputFocused   (state)                    end
function Widget:input          (state)                    end
function Widget:update         (state)                    end

function Widget:layoutSize     ()                         end
function Widget:layoutPos      (ox, oy, px, py, psx, psy) end
function Widget:draw           (focus, active)            end
function Widget:drawDebug      (focus, active)            end


-- Default implementations -----------------------------------------------------

function Widget:findMouseFocus (mx, my, foci)
  self:onFindMouseFocus(mx, my, foci)
end

function Widget:onFindMouseFocus (mx, my, foci)
  if self.focusable and self:containsPoint(mx, my) then
    foci.focus = self
  end
end

function Widget:dragBegin (state)
  state.dragBeginX    = state.mousePosX
  state.dragBeginY    = state.mousePosY
  state.dragOffsetX   = (self.originX + self.x) - state.dragBeginX
  state.dragOffsetY   = (self.originY + self.y) - state.dragBeginY
  state.dragBeginTime = TimeStamp.Get()

  self:onDragBegin(state)
end

function Widget:onDragBegin (state)
end

function Widget:drag (state)
  state.dragDeltaX   = state.mousePosX - state.dragBeginX
  state.dragDeltaY   = state.mousePosY - state.dragBeginY
  state.dragDuration = TimeStamp.GetDifference(state.dragBeginTime, TimeStamp.Get())
  self:onDrag(state)
end

function Widget:onDrag (state)
  self.align = false
  self.x = state.dragOffsetX + state.mousePosX - self.originX
  self.y = state.dragOffsetY + state.mousePosY - self.originY
end

function Widget:dragEnd (state)
  state.dragEndTime  = TimeStamp.Get()
  state.dragDuration = TimeStamp.GetDifference(state.dragBeginTime, state.dragEndTime)

  self:onDragEnd(state)

  state.dragBeginX    = 0
  state.dragBeginY    = 0
  state.dragOffsetX   = 0
  state.dragOffsetY   = 0
  state.dragDeltaX    = 0
  state.dragDeltaY    = 0
  state.dragBeginTime = nil
  state.dragEndTime   = nil
  state.dragDuration  = nil
end

function Widget:onDragEnd (state)
end

function Widget:click (state)
  self:onClick(state)
end

function Widget:onClick (state)
end

function Widget:inputFocused (state)
  self:onInput(state)
end

function Widget:input (state)
  self:onInput(state)
end

function Widget:onInput (state)
end

function Widget:update (state)
  self:onUpdate(state)
end

function Widget:onUpdate (state)
end

function Widget:layoutSize ()
  self:onLayoutSize()

  self.sx = Math.Clamp(self.desiredSX, self.minSX, self.maxSX)
  if self.fixedSX then self.sx = self.fixedSX end

  self.sy = Math.Clamp(self.desiredSY, self.minSY, self.maxSY)
  if self.fixedSY then self.sy = self.fixedSY end
end

function Widget:onLayoutSize ()
end

function Widget:layoutPos (ox, oy, px, py, psx, psy)
  self.originX = ox
  self.originY = oy
  self:onLayoutPos(px, py, psx, psy)
end

function Widget:onLayoutPos (px, py, psx, psy)
  -- Stretch
  if not self.fixedSX then
    self.sx = max(self.sx, Math.Sign0(self.stretchX) * psx)
    self.sx = min(self.sx, self.maxSX)
  end
  if not self.fixedSY then
    self.sy = max(self.sy, Math.Sign0(self.stretchY) * psy)
    self.sy = min(self.sy, self.maxSY)
  end

  -- Align to parent
  if self.align then
    self.x = px + self.alignX * (psx - self.sx)
    self.y = py + self.alignY * (psy - self.sy)

  -- Clamp to parent
  elseif self.clamp then
    self.x = Math.Clamp(self.x, px, px + psx - self.sx)
    self.y = Math.Clamp(self.y, py, py + psy - self.sy)
  end
end

function Widget:draw (focus, active)
  self:onDraw(focus, active)
end

function Widget:onDraw (focus, active)
end

function Widget:drawDebug (focus, active)
  self:onDrawDebug(focus, active)
end

function Widget:onDrawDebug (focus, active)
  Draw.Rect(self:getRectGlobal())
end

--[[ Convenience Method List ---------------------------------------------------

  -- Non-Fluent
  Widget:applyColor                (focus, active, normal)
  Widget:containsPoint             (x, y)
  Widget:drawText                  (font, text, bound, color)
  Widget:drawTextRect              (font, text, bound, color, alignX, alignY, x, y, sx, sy)
  Widget:drawTextRectCentered      (font, text, bound, color, x, y, sx, sy)
  Widget:getCanvas                 ()
  Widget:getFirstParentWhere       (predicateFn, stopAt)
  Widget:getFirstParentOrSelfWhere (predicateFn, stopAt)
  Widget:getPosGlobal              ()
  Widget:getPosNormalized          (relX, relY)
  Widget:getPosPad                 ()
  Widget:getPosPadGlobal           ()
  Widget:getCenter                 ()
  Widget:getPosGlobal              ()
  Widget:getRect                   ()
  Widget:getRectGlobal             ()
  Widget:getRectPad                ()
  Widget:getRectPadForChildren     ()
  Widget:getRectPadGlobal          ()
  Widget:getState                  ()
  Widget:hasParentWhere            (predicateFn)
  Widget:hasParentOrSelfWhere      (predicateFn)
  Widget:isChildOf                 (widget)
  Widget:isChildOfOrSelf           (widget)
  Widget:isParentOf                (widget)
  Widget:isParentOfOrSelf          (widget)

  -- Fluent (returns self)
  Widget:setDebug                  (debug)
  Widget:setPos                    (x, y)
  Widget:setPosGlobal              (x, y)
  Widget:setPosRel                 (dx, dy)
  Widget:setSize                   (sx, sy)
  Widget:setWidth                  (sx)
  Widget:setHeight                 (sy)
  Widget:setMinSize                (sx, sy)
  Widget:setMinWidth               (sx)
  Widget:setMinHeight              (sy)
  Widget:setMaxSize                (sx, sy)
  Widget:setMaxWidth               (sx)
  Widget:setMaxHeight              (sy)
  Widget:setName                   (name)
  Widget:setStretch                (stretchX, stretchY)
  Widget:setStretchX               (stretchX)
  Widget:setStretchY               (stretchY)
  Widget:setAlign                  (alignX, alignY)
  Widget:setAlignX                 (alignX)
  Widget:setAlignY                 (alignY)
  Widget:setPadX                   (minX, maxX)
  Widget:setPadY                   (minY, maxY)
  Widget:setPad                    (minX, maxX, minY, maxY)
  Widget:setPadUniform             (pad)

----------------------------------------------------------------------------]]--

function Widget:applyColor (focus, active, normalColor, alpha)
  if active == self then
    Config.ui.color.active:set(alpha)
  elseif focus == self then
    Config.ui.color.focused:set(alpha)
  else
    normalColor:set(alpha)
  end
end

function Widget:containsPoint (x, y)
  return Rect.containsPoint(
    self.originX + self.x, self.originY + self.y, self.sx, self.sy,
    x, y)
end

function Widget:drawText (font, text, bound, color)
  font:draw(text,
    self.originX + self.x + self.padMinX + self.alignX * (self.sx - self.padSumX - bound.z) - bound.x,
    self.originY + self.y + self.padMinY + self.alignY * (self.sy - self.padSumY + bound.y) - bound.y,
    color.r, color.g, color.b, color.a)
end

function Widget:drawTextRect (font, text, bound, color, alignX, alignY, x, y, sx, sy)
  font:draw(text,
    x + alignX * (sx - bound.z) - bound.x,
    y + alignY * (sy + bound.y) - bound.y,
    color.r, color.g, color.b, color.a)
end

function Widget:drawTextRectCentered (font, text, bound, color, x, y, sx, sy)
  font:draw(text,
    x + 0.5 * (sx - bound.z) - bound.x,
    y + 0.5 * (sy + bound.y) - bound.y,
    color.r, color.g, color.b, color.a)
end

function Widget:findInHierarchy (predicate, filter)
  -- NOTE : Breadth first search
  filter = filter or function (w) return true end

  local i, queue = 1, List({ self })
  while i <= #queue do
    local children = queue[i]

    for j = 1, #children do
      local child = children[j]
      if filter(child) and (not child.isContainer or child:isEnabled()) then
        if predicate(child) then return child end
        if child.isContainer and child.expanded ~= false then
          queue:append(child.children)
        end
      end
    end
    i = i + 1
  end
  return nil
end

function Widget:findAllInHierarchy (predicate, filter)
  -- NOTE : Breadth first search
  filter = filter or function (w) return true end

  local results = List()
  local i, queue = 1, List({ self })
  while i <= #queue do
    local children = queue[i]

    for j = 1, #children do
      local child = children[j]
      if filter(child) and (not child.isContainer or child:isEnabled()) then
        if predicate(child) then results:append(child) end
        if child.isContainer and child.expanded ~= false then
          queue:append(child.children)
        end
      end
    end
    i = i + 1
  end
  return results
end

function Widget:getCanvas ()
  local parent = self
  while parent.parent do
    parent = parent.parent
  end

  if parent.isCanvas then return parent else return nil end
end

function Widget:getFirstParentWhere (predicateFn, stopAt)
  local widget = self.parent
  while widget do
    if widget == stopAt then break end
    if predicateFn(widget) then return widget end
    widget = widget.parent
  end
  return nil
end

function Widget:getFirstParentOrSelfWhere (predicateFn, stopAt)
  local widget = self
  while widget do
    if widget == stopAt then break end
    if predicateFn(widget) then return widget end
    widget = widget.parent
  end
  return nil
end

function Widget:getPosGlobal ()
  return self.originX + self.x, self.originY + self.y
end

function Widget:getPosNormalized (relX, relY)
  return self.x + relX * self.sy, self.y + relY * self.sy
end

function Widget:getPosPad ()
  return self.x + self.padMinX, self.y + self.padMinY
end

function Widget:getPosPadGlobal ()
  return self.originX + self.x + self.padMinX, self.originY + self.y + self.padMinY
end

function Widget:getCenter ()
  return Vec2f(self.x + 0.5 * self.sx, self.y + 0.5 * self.sy)
end

function Widget:getPosGlobal ()
  return self.originX + self.x, self.originY + self.y
end

function Widget:getRect ()
  return self.x, self.y, self.sx, self.sy
end

function Widget:getRectGlobal ()
  return self.originX + self.x, self.originY + self.y, self.sx, self.sy
end

function Widget:getRectPad ()
  return self.x  + self.padMinX,
         self.y  + self.padMinY,
         self.sx - self.padSumX,
         self.sy - self.padSumY
end

function Widget:getRectPadForChildren ()
  return self.padMinX,
         self.padMinY,
         self.sx - self.padSumX,
         self.sy - self.padSumY
end

function Widget:getRectPadGlobal ()
  return self.originX + self.x + self.padMinX,
         self.originY + self.y + self.padMinY,
         self.sx - self.padSumX,
         self.sy - self.padSumY
end

function Widget:getState ()
  local canvas = self:getCanvas()
  return canvas and canvas.state
end

function Widget:hasParentWhere (predicateFn)
  local parent = self.parent
  while parent do
    if predicateFn(parent) then return true end
    parent = parent.parent
  end
end

function Widget:hasParentOrSelfWhere (predicateFn)
  local parent = self
  while parent do
    if predicateFn(parent) then return true end
    parent = parent.parent
  end
end

function Widget:isChildOf (widget)
  local parent = self.parent
  while parent do
    if parent == widget then return true end
    parent = parent.parent
  end
  return false
end

function Widget:isChildOfOrSelf (widget)
  local parent = self
  while parent do
    if parent == widget then return true end
    parent = parent.parent
  end
  return false
end

function Widget:isParentOf (widget)
  widget = widget.parent
  while widget do
    if widget == self then return true end
    widget = widget.parent
  end
  return false
end

function Widget:isParentOfOrSelf (widget)
  while widget do
    if widget == self then return true end
    widget = widget.parent
  end
  return false
end

function Widget:setDebug (debug)
  self.debug = true
  return self
end

function Widget:setPos (x, y)
  self.align = false
  self.x = x
  self.y = y
  return self
end

function Widget:setPosGlobal (x, y)
  self.align = false
  self.x = x - self.originX
  self.y = y - self.originY
  return self
end

function Widget:setPosRel (dx, dy)
  self.align = false
  self.x = self.x + dx
  self.y = self.y + dy
  return self
end

function Widget:setSize (sx, sy)
  self.fixedSX = sx
  self.fixedSY = sy
  return self
end

function Widget:setWidth (width)
  self.fixedSX = width
  return self
end

function Widget:setHeight (height)
  self.fixedSY = height
  return self
end

function Widget:setMinSize (sx, sy)
  self.minSX = sx
  self.minSY = sy
  return self
end

function Widget:setMinWidth (width)
  self.minSX = width
  return self
end

function Widget:setMinHeight (height)
  self.minSY = height
  return self
end

function Widget:setMaxSize (sx, sy)
  self.maxSX = sx
  self.maxSY = sy
  return self
end

function Widget:setMaxWidth (width)
  self.maxSX = width
  return self
end

function Widget:setMaxHeight (height)
  self.maxSY = height
  return self
end

function Widget:setName (name)
  self.name = name
  return self
end

function Widget:setStretch (stretchX, stretchY)
  self.stretchX = stretchX
  self.stretchY = stretchY
  return self
end

function Widget:setStretchX (stretch)
  self.stretchX = stretch
  return self
end

function Widget:setStretchY (stretch)
  self.stretchY = stretch
  return self
end

function Widget:setAlign (alignX, alignY)
  self.alignX = alignX
  self.alignY = alignY
  return self
end

function Widget:setAlignX (align)
  self.alignX = align
  return self
end

function Widget:setAlignY (align)
  self.alignY = align
  return self
end

function Widget:setPadX (minX, maxX)
  self.padMinX = minX
  self.padMaxX = maxX
  self.padSumX = minX + maxX
  return self
end

function Widget:setPadY (minY, maxY)
  self.padMinY = minY
  self.padMaxY = maxY
  self.padSumY = minY + maxY
  return self
end

function Widget:setPad (minX, maxX, minY, maxY)
  self:setPadX(minX, maxX)
  self:setPadY(minY, maxY)
  return self
end

function Widget:setPadUniform (pad)
  self:setPadX(pad, pad)
  self:setPadY(pad, pad)
  return self
end

return Widget
