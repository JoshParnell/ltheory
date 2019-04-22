local Bindings  = require('UI.Bindings')
local Container = require('UI.Container')
local DrawEx    = require('UI.DrawEx')
local State     = require('UI.State')

local Canvas = {}
Canvas.__index = Canvas
setmetatable(Canvas, Container)

Canvas.isCanvas = true
Canvas.name     = 'Canvas'

function Canvas:findMouseFocus ()
  local s = self.state
  local foci = {}

  if s.modalFocus then
    s.modalFocus:findMouseFocus(s.mousePosX, s.mousePosY, foci)

  elseif s.scrollActive then
    return

  else
    self:onFindMouseFocusChildren(s.mousePosX, s.mousePosY, foci)
  end

  if foci.focus then
    s:setPanelFocus (foci.panelFocus)
    s:setScrollFocus(foci.scrollFocus)
    s:setNavFocus   (foci.navFocus)
    s:setFocus      (foci.focus)
  end
end

function Canvas:input ()
  Profiler.Begin('Canvas.Input')
  local s = self.state

  Profiler.Begin('Canvas.Focus')
  -- Mouse Focus
  local md = Input.GetMouseDelta()
  local mouseMoved = md.x ~= 0 or md.y ~= 0

  if mouseMoved then
    s.scrollActive = nil
    self:findMouseFocus()
  end

  -- TODO : Remove this once Control:delta() works properly
  local select = Bindings.Select:get()
  local cancel = Bindings.Cancel:get()

  -- Modal Focus
  if s.modalFocus then
    if cancel > 0 then
      s.modalFocus:cancel()
    end

    if select > 0 then
      if not s.focus and not s.modalFocus:containsPoint(s.mousePosX, s.mousePosY) then
        s.modalFocus:cancel()
      end
    end
  end
  Profiler.End()

  Profiler.Begin('Canvas.Drag')
  -- Activate, Begin Drag
  if s.focus then
    if select > 0 then
      s.active = s.focus
      if s.active.draggable then s.active:dragBegin(s) end
    end
  end

  -- Drag, End Drag, Deactivate
  if s.active then
    if mouseMoved then
      if s.active.draggable then s.active:drag(s) end
    end

    if select < 0 then
      if s.active.draggable  then s.active:dragEnd(s) end
      if s.active == s.focus then s.active:click(s) end
      s.active = nil
    end
  end
  Profiler.End()

  Profiler.Begin('Canvas.InputFocused')
  local focus = s:getDeepestFocus()
  while focus and focus ~= self do
    if not focus.removed then focus:inputFocused(s) end
    focus = focus.parent
  end
  Profiler.End()

  Profiler.Begin('Canvas.InputChildren')
  for i = 1, #self.children do
    local child = self.children[i]
    if not child.removed then child:input(s) end
  end
  Profiler.End()

  Profiler.End()
end

function Canvas:update (dt)
  Profiler.Begin('Canvas.Update')
  local s = self.state
  local mp = Input.GetMousePosition()
  s.dt = dt
  s.mousePosX = mp.x
  s.mousePosY = mp.y

  self.timer:reset()
  for i = 1, #self.children do
    local child = self.children[i]
    if not child.removed then child:update(s, dt) end
  end

  do -- Deferred add/remove
    Profiler.Begin('Canvas.DeferredAddRemove')
    for i = 1, #self.removeQueue do
      local op = self.removeQueue[i]
      op.parent:removeImmediate(op.child)
    end
    self.removeQueue:clear()

    for i = 1, #self.addQueue do
      local op = self.addQueue[i]
      op.parent:addImmediate(op.child)
    end
    self.addQueue:clear()
    Profiler.End()
  end

  self.updateTime = self.timer:getElapsed()
  Profiler.End()
end

function Canvas:draw (sx, sy)
  Profiler.Begin('Canvas.Draw')
  local s = self.state

  do -- Layout
    Profiler.Begin('Canvas.Layout')
    self.timer:reset()
    for i = 1, #self.children do self.children[i]:layoutSize() end
    for i = 1, #self.children do self.children[i]:layoutPos(0, 0, 0, 0, sx, sy) end
    self.layoutTime = self.timer:getElapsed()
    Profiler.End()
  end

  s:refreshFocus()

  do -- Debug
    if self.printFocus then
      print('focus      ', s.focus       and s.focus.name)
      print('active     ', s.active      and s.active.name)
      print('scrollFocus', s.scrollFocus and s.scrollFocus.name)
      print('navFocus   ', s.navFocus    and s.navFocus.name)
      print('panelFocus ', s.panelFocus  and s.panelFocus.name)
      print('modalFocus ', s.modalFocus  and s.modalFocus.name)
      print()
    end
  end

  do -- Draw
    self.timer:reset()
    if self.enabled > 0 then
      BlendMode.Push(BlendMode.Alpha)
      Draw.PushAlpha(self.enabled)
      DrawEx.PushAlpha(self.enabled)
      for i = 1, #self.children do self.children[i]:draw(s.focus, s.active) end
      DrawEx.PopAlpha()
      Draw.PopAlpha()
      BlendMode.Pop()
    end
  end

  do -- Debugging
    BlendMode.Push(BlendMode.Alpha)
    if self.drawDebug then
      -- Don't use wireframe! (it's not pixel-perfect)
      Config.ui.color.debugRect:set()
      self:onDrawDebugChildren(s.focus, s.active)
    end

    if self.drawFocus then
      if s.focus then
        Draw.Color(1.0, 0.0, 0.0, 0.1)
        Draw.Rect(s.focus:getRectGlobal())
      end
    end
    BlendMode.Pop()
    self.drawTime = self.timer:getElapsed()
  end

  Draw.Color(1.0, 1.0, 1.0, 1.0)
  Profiler.End()
end

function Canvas:queueAdd (parent, child)
  local op = { parent = parent, child = child }
  self.addQueue:append(op)
end

function Canvas:queueRemove (parent, child)
  local op = { parent = parent, child = child }
  self.removeQueue:append(op)
end

function Canvas.Create ()
  local self = setmetatable({
    state          = nil,
    addQueue       = List(),
    removeQueue    = List(),

    -- Debug
    drawFocus   = false,
    drawDebug   = false,
    printFocus  = false,
    updateTime  = 0,
    layoutTime  = 0,
    drawTime    = 0,
    timer       = Timer.Create(),

    children    = List(),
  }, Canvas)

  self.state = State.Create(self)
  self:setEState(Container.EState.Enabled)
  return self
end

return Canvas
