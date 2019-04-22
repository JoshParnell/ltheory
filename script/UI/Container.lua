local DrawEx = require('UI.DrawEx')
local Widget = require('UI.Widget')

local Container = {}
Container.__index = Container
Container.__call  = function (t, ...) return t.Create(...) end
setmetatable(Container, Widget)

Container.EState = {
  Enabling  = 1,
  Enabled   = 2,
  Disabling = 3,
  Disabled  = 4,
}
local EState = Container.EState

Container.enabled     = 0
Container.enabledT    = 0
Container.eState      = EState.Disabled
Container.fadeSpeed   = 18
Container.isContainer = true
Container.name        = 'Container'

-- Container Functions ---------------------------------------------------------

function Container:onFindMouseFocusChildren (mx, my, foci)   end
function Container:onInputChildren          (state)          end
function Container:onUpdateChildren         (state)          end
function Container:onLayoutSizeChildren     ()               end
function Container:onLayoutPosChildren      ()               end
function Container:onDrawChildren           (focus, active)  end
function Container:onDrawDebugChildren      (focus, active)  end

function Container:setEState                (eState)         end
function Container:setEnabled               (enabled, speed) end
function Container:toggleEnabled            (speed)          end
function Container:isEnabled                ()               end
function Container:enable                   (speed)          end
function Container:disable                  (speed)          end
function Container:completeFade             ()               end

function Container:onEnable                 ()               end
function Container:onEnableDone             ()               end
function Container:onDisable                ()               end
function Container:onDisableDone            ()               end

function Container:add                      (child, enabled) end
function Container:remove                   (child)          end
function Container:addImmediate             (child)          end
function Container:removeImmediate          (child)          end

-- Default Implementations -----------------------------------------------------

function Container:findMouseFocus (mx, my, foci)
  if self.enabledT == 1 and self:containsPoint(mx, my) then
    self:onFindMouseFocusChildren(mx, my, foci)
    if not foci.focus then
      self:onFindMouseFocus(mx, my, foci)
    end
  end
end

function Container:onFindMouseFocusChildren (mx, my, foci)
  for i = #self.children, 1, -1 do
    self.children[i]:findMouseFocus(mx, my, foci)
    if foci.focus then return end
  end
end

function Container:inputFocused (state)
  if self.enabledT == 1 then
    self:onInput(state)
  end
end

function Container:input (state)
  if self.enabledT == 1 then
    self:onInputChildren(state)
    self:onInput(state)
  end
end

function Container:onInputChildren (state)
  for i = 1, #self.children do
    local child = self.children[i]
    if not child.removed then child:input(state) end
  end
end

function Container:update (state)
  if self.enabled ~= self.enabledT then
    local f = 1.0 - exp(-state.dt * self.fadeSpeed)
    self.enabled = Math.Lerp(self.enabled, self.enabledT, f)
    if abs(self.enabledT - self.enabled) < 1e-3 then
      local eState = self.enabledT == 0 and EState.Disabled or EState.Enabled
      self:setEState(eState)
    end
  end

  if self:isEnabled() then
    self:onUpdate(state)
    self:onUpdateChildren(state)
  end
end

function Container:onUpdateChildren (state)
  for i = 1, #self.children do
    local child = self.children[i]
    if not child.removed then child:update(state) end
  end
end

function Container:layoutSize ()
  if self.enabled > 0 or self.enabledT == 1 then
    self.desiredSX = self.padSumX
    self.desiredSY = self.padSumY

    self:onLayoutSizeChildren()
    self:onLayoutSize()

    self.sx = Math.Clamp(self.desiredSX, self.minSX, self.maxSX)
    if self.fixedSX then self.sx = self.fixedSX end

    self.sy = Math.Clamp(self.desiredSY, self.minSY, self.maxSY)
    if self.fixedSY then self.sy = self.fixedSY end
  end
end

function Container:onLayoutSizeChildren ()
  local msx = 0
  local msy = 0
  for i = 1, #self.children do
    local child = self.children[i]

    child:layoutSize()
    local fixed = (child.align or child.clamp) and 0 or 1
    msx = max(msx, self.padMinX + fixed*child.x + child.sx)
    msy = max(msy, self.padMinY + fixed*child.y + child.sy)
  end
  self.desiredSX = max(self.desiredSX, msx + self.padMaxX)
  self.desiredSY = max(self.desiredSY, msy + self.padMaxY)
end

function Container:layoutPos (ox, oy, px, py, psx, psy)
  if self.enabled > 0 or self.enabledT == 1 then
    self.originX = ox
    self.originY = oy
    self:onLayoutPos(px, py, psx, psy)
    self:onLayoutPosChildren()
  end
end

function Container:onLayoutPosChildren ()
  local ox, oy = self:getPosGlobal()
  for i = 1, #self.children do self.children[i]:layoutPos(ox, oy, self:getRectPadForChildren()) end
end

function Container:draw (focus, active)
  if self.enabled > 0 then
    Draw.PushAlpha(self.enabled)
    DrawEx.PushAlpha(self.enabled)
    self:onDraw(focus, active)
    self:onDrawChildren(focus, active)
    DrawEx.PopAlpha()
    Draw.PopAlpha()
  end
end

function Container:onDrawChildren (focus, active)
  for i = 1, #self.children do self.children[i]:draw(focus, active) end
end

function Container:drawDebug (focus, active)
  if self.enabled > 0 then
    self:onDrawDebug(focus, active)
    self:onDrawDebugChildren(focus, active)
  end
end

function Container:onDrawDebug (focus, active)
  Draw.Rect(self:getRectGlobal())
  if self.padSumX > 0 or self.padSumY > 0 then
    Draw.Rect(self:getRectPadGlobal())
  end
end

function Container:onDrawDebugChildren (focus, active)
  for i = 1, #self.children do self.children[i]:drawDebug(focus, active) end
end

function Container:setEState (eState)
  if eState == EState.Enabling then
    if self.eState == EState.Enabling
    or self.eState == EState.Enabled
    then
      return

    elseif self.eState == EState.Disabling
        or self.eState == EState.Disabled
    then
      self.enabledT = 1
      self:onEnable()
      local state = self:getState()
      if state then state:onWidgetEnabled(self) end
    end

  elseif eState == EState.Enabled then
    if self.eState == EState.Enabled then
      return

    elseif self.eState == EState.Enabling then
      self.enabled = 1
      self:onEnableDone()

    elseif self.eState == EState.Disabling
        or self.eState == EState.Disabled
    then
      self.enabledT = 1
      self:onEnable()
      local state = self:getState()
      if state then state:onWidgetEnabled(self) end
      self.enabled = 1
      self:onEnableDone()
    end

  elseif eState == EState.Disabling then
    if self.eState == EState.Disabling
    or self.eState == EState.Disabled
    then
      return

    elseif self.eState == EState.Enabling
        or self.eState == EState.Enabled
    then
      self.enabledT = 0
      self:onDisable()
      local state = self:getState()
      if state then state:onWidgetDisabled(self) end
    end

  elseif eState == EState.Disabled then
    if self.eState == EState.Disabled then
      return

    elseif self.eState == EState.Enabling
        or self.eState == EState.Enabled
    then
      self.enabledT = 0
      self:onDisable()
      local state = self:getState()
      if state then state:onWidgetDisabled(self) end
      self.enabled = 0
      self:onDisableDone()

    elseif self.eState == EState.Disabling then
      self.enabled = 0
      self:onDisableDone()
    end
  end
  self.eState = eState
end

function Container:setEnabled (enabled, speed)
  self.fadeSpeed = speed or self.fadeSpeed
  local eState = enabled and EState.Enabling or EState.Disabling
  self:setEState(eState)
end

function Container:toggleEnabled (speed)
  self.fadeSpeed = speed or self.fadeSpeed
  local eState = self:isEnabled() and EState.Disabling or EState.Enabling
  self:setEState(eState)
end

function Container:isEnabled ()
  return self.enabledT == 1
end

function Container:completeFade ()
  if self.enabled ~= self.enabledT then
    local eState = self:isEnabled() and EState.Enabled or EState.Disabled
    self:setEState(eState)
  end
end

function Container:enable (speed)
  self.fadeSpeed = speed or self.fadeSpeed
  self:setEState(EState.Enabling)
end

function Container:disable (speed)
  self.fadeSpeed = speed or self.fadeSpeed
  self:setEState(EState.Disabling)
end

function Container:add (child, enabled)
  local ox, oy = self:getPosGlobal()
  child.originX = ox
  child.originY = oy

  local canvas = self:getCanvas()
  child.removed = false
  if child.isContainer then
    local eState = enabled == false and EState.Disabled or EState.Enabled
    child:setEState(eState)
  else
    if canvas then canvas.state:onWidgetEnabled(self) end
  end

  if canvas then
    canvas:queueAdd(self, child)
  else
    self:addImmediate(child)
  end
  return self
end

function Container:remove (child)
  local canvas = self:getCanvas()
  if canvas then
    canvas:queueRemove(self, child)
  else
    self:removeImmediate(child)
  end

  child.removed = true
  if child.isContainer then
    child:setEState(EState.Disabled)
  else
    if canvas then canvas.state:onWidgetDisabled(self) end
  end
  return self
end

function Container:removeAll ()
  for i = #self.children, 1, -1 do self:remove(self.children[i]) end
  return self
end

function Container:addImmediate (child)
  self.children:append(child)
  child.parent = self
end

function Container:removeImmediate (child)
  self.children:remove(child)
  child.parent = nil
end

return Container
