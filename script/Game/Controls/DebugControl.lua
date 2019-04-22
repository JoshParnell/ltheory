local Bindings = require('Game.Controls.DebugBindings')

local DebugControl = {}
DebugControl.__index = DebugControl
setmetatable(DebugControl, UI.Panel)

DebugControl.name      = 'DebugControl'
DebugControl.focusable = true
DebugControl.ltheory   = nil
DebugControl:setPadUniform(8)

function DebugControl:onEnable ()
  self.gameView:setOrbit(true)
  self.gameView.camera:warp()
end

function DebugControl:onDisable ()
end

function DebugControl:onInput (state)
  local camera = self.gameView.camera
  camera:push()

  if Input.GetPressed(Bindings.ToggleDebugWindow) then
    self.debugWindow:toggleEnabled()
  end

  if Input.GetPressed(Bindings.InspectWidget) then
    if state.focus then
      self:createWidgetInspector(state.focus)
    end
  end

  camera:pop()
end

function DebugControl:onDraw (focus, active)
  if false then -- Underlay
    local a = UI.DrawEx.GetAlpha()
    Draw.Color(0.1, 0.1, 0.1, a * 0.25)
    Draw.Rect(self.x, self.y, self.sx, self.sy)
    Draw.Color(1, 1, 1, 1)
  end

  local camera = self.gameView.camera
  local world = self.player:getRoot()

  if false then -- Raycast
    local ray = camera:mouseToRay(1e7)
    local hit, t = world:raycast(ray)
    self.hit = hit
    if Input.GetPressed(Button.Mouse.Left) then
      self.target = self.hit
    end
  end
end

function DebugControl:onDrawIcon (iconButton, focus, active)
  local borderColor = iconButton == active
                      and Config.ui.color.controlActive
                      or iconButton == focus
                         and Config.ui.color.controlFocused
                         or Config.ui.color.control
  local contentColor = self:isEnabled()
                       and Config.ui.color.controlFocused
                       or Config.ui.color.control

  local x, y, sx, sy = iconButton:getRectGlobal()
  UI.DrawEx.RectOutline(x, y, sx, sy, borderColor)

  UI.DrawEx.RectOutline(x + 16, y + 8, sx - 32, sy - 16, contentColor)
  for y = y + 8 + 4, y + sy - 8 - 4, 6 do
    UI.DrawEx.Line(x + 16,      y, x + 10,      y, contentColor)
    UI.DrawEx.Line(x + sx - 16, y, x + sx - 10, y, contentColor)
  end
end

function DebugControl:createWidgetInspector (widget)
  local w            = widget
  local canvas       = self:getCanvas()
  local oldInspector = self.widgetInspector
  local newInspector = UI.Window(w.name .. ' Inspector', false, true)

  local childGrid = UI.Grid():setPad(2, 0, 2, 2)
  if w.children then
    for i = 1, #w.children do
      local child = w.children[i]
      childGrid:add(UI.Label(i):setMinWidth(16))
      childGrid:add(UI.Button(child.name)
        :setOnClick(function (button, state) self:createWidgetInspector(child) end)
      )
    end
  end

  -- TODO : Add functions to Widgets to fill in this information
  newInspector
    :add(UI.NavGroup():setPadUniform(2)
      :add(UI.Grid():setCols(1)
        :add(UI.Button('Refresh'):setOnClick(function (button, state) self:createWidgetInspector(w) end))
        :add(UI.Grid():setPadCellX(8)
          :add(UI.Label('Name'))
          :add(UI.Label():setPollFn(function () return w.name end))
          :add(UI.Label('Rect'))
          :add(UI.Label():setPollFn(function () return string.format('%.1f, %.1f, %.1f, %.1f', w.x, w.y, w.sx, w.sy) end))
          :add(UI.Label('Origin X'))
          :add(UI.Label():setPollFn(function () return w.originX end))
          :add(UI.Label('Origin Y'))
          :add(UI.Label():setPollFn(function () return w.originY end))
          :add(UI.Label('Focusable'))
          :add(UI.Label():setPollFn(function () return w.focusable end))
          :add(UI.Label('Draggable'))
          :add(UI.Label():setPollFn(function () return w.draggable end))
          :add(UI.Label('Auto-align'))
          :add(UI.Label():setPollFn(function () return w.align end))
          :add(UI.Label('Padding'))
          :add(UI.Label():setPollFn(function () return string.format('Min: %.1f, %.1f; Max: %.1f, %.1f', w.padMinX, w.padMinY, w.padMaxX, w.padMaxX) end))
          :add(UI.Label('Desired Size'))
          :add(UI.Label():setPollFn(function () return string.format('%.1f, %.1f', w.desiredSX, w.desiredSY) end))
          :add(UI.Label('Min Size'))
          :add(UI.Label():setPollFn(function () return string.format('%.1f, %.1f', w.minSX, w.minSY) end))
          :add(UI.Label('Max Size'))
          :add(UI.Label():setPollFn(function () return string.format('%.1f, %.1f', w.maxSX, w.maxSY) end))
          :add(UI.Label('Fixed Size'))
          :add(UI.Label():setPollFn(function () return string.format('%.1f, %.1f', w.fixedSX or 0, w.fixedSY or 0) end))
          :add(UI.Label('Align X'))
          :add(UI.Slider(
            function () return w.alignX end,
            function (value)   w:setAlignX(value) end))
          :add(UI.Label('Align Y'))
          :add(UI.Slider(
            function () return w.alignY end,
            function (value)   w:setAlignY(value) end))
          :add(UI.Label('Stretch X'))
          :add(UI.Slider(
            function () return w.stretchX end,
            function (value)   w:setStretchX(value) end))
          :add(UI.Label('Stretch Y'))
          :add(UI.Slider(
            function () return w.stretchY end,
            function (value)   w:setStretchY(value) end))
          :add(UI.Label('Max Width'))
          :add(UI.Slider(
            function () return w.maxSX or 0 end,
            function (value)   w:setMaxWidth(value) end,
            200, 600))
          :add(UI.Label('Max Height'))
          :add(UI.Slider(
            function () return w.maxSY or 0 end,
            function (value)   w:setMaxHeight(value) end,
            200, 600))
          :add(UI.Label('Parent'))
          :add(UI.Button(w.parent and w.parent.name or 'nil', function (button, state)
              if w.parent then self:createWidgetInspector(w.parent) end end))
        )
        :add(UI.Collapsible('Children')
          :add(childGrid)
        )
      )
    )
  newInspector:setAlign(1, 0)

  if oldInspector then
    if w == oldInspector then w = newInspector end

    newInspector.align = oldInspector.align
    newInspector.x = oldInspector.x
    newInspector.y = oldInspector.y
    canvas:remove(oldInspector)
  end
  canvas:add(newInspector)

  self.widgetInspector = newInspector
end

function DebugControl.Create (gameView, player)
  local self = setmetatable({
    gameView        = gameView,
    player          = player,
    icon            = UI.Icon(),
    debugWindow     = GUI.DebugWindow(DebugControl.ltheory),
    widgetInspector = nil,

    children        = List(),
  }, DebugControl)

  self:add(self.debugWindow:setStretch(0, 1), Config.debug.window)
  self.icon:setOnDraw(function (ib, focus, active)
    self:onDrawIcon(ib, focus, active)
  end)
  return self
end

return DebugControl
