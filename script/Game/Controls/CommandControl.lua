local CameraBindings = require('Game.Controls.CameraBindings')
local CommandBindings = require('Game.Controls.CommandBindings')
local Disposition = require('Game.Components.Dispositions')

local CommandControl = {}
CommandControl.__index = CommandControl
setmetatable(CommandControl, UI.Panel)

CommandControl.name      = 'Command Control'
CommandControl.focusable = true
CommandControl.draggable = true
CommandControl:setPadUniform(8)

local selectionPredicate = function (unit) return unit:isAlive() end

local SelectionMode = {
  Replace = 1,
  Toggle  = 2,
  Add     = 3,
  Remove  = 4,
}

local ContextEntries = {
  -- Move To
  {
    GetContextEntry = function ()
      return UI.Button('Move To')
    end,
    GetActionArgs = function ()
      return { range = 100 }
    end,
    GetDetailsEntry = function (args)
      return UI.Grid():setCols(2)
        :add(UI.Label('Range'))
        :add(UI.Slider(
          function ()      return args.range end,
          function (value) args.range = value end,
          0, 1000
        ))
    end,
    GetAction = function (target, args)
      return Actions.MoveTo(target, args.range)
    end,
  },
  -- Attack
  {
    GetContextEntry = function ()
      return UI.Button('Attack')
    end,
    GetActionArgs = function ()
      return nil
    end,
    GetDetailsEntry = function (args)
      return nil
    end,
    GetAction = function (target, args)
      return Actions.Attack(target)
    end,
  },
}

function CommandControl:onEnable ()
  local pCamera = self.gameView.camera
  self.gameView:setOrbit(true)

  self.camera = self.gameView.camera
  if self.firstRun then
    self.firstRun = false
    self.camera:setYaw(-Math.Pi2)
    self.camera:setPitch(Math.Pi2)
    self.camera:setRadius(1000)
  end
  self.camera:setTarget(nil)
  self.camera:setRelative(false)
  self.camera:warp()
  self.camera:lerpFrom(pCamera.pos, pCamera.rot)
end

function CommandControl:onDisable ()
end

function CommandControl:findSelection (sx, sy, ssx, ssy)
  -- NOTE : Window to view space
  sx = sx - self.camera.x
  sy = sy - self.camera.y

  -- NOTE : Fix rect if it's inverted
  if ssx < 0 then
    sx = sx + ssx
    ssx = -ssx
  end
  if ssy < 0 then
    sy = sy + ssy
    ssy = -ssy
  end

  -- NOTE : Inflate the rect so tiny units are easier to select
  local pad = 10
  sx  = sx  -   pad
  sy  = sy  -   pad
  ssx = ssx + 2*pad
  ssy = ssy + 2*pad

  local selection = List()
  for i = 1, #self.units.tracked do
    local unitRect = self.unitRects[i]

    local selectionRect = Vec4f(sx, sy, ssx, ssy)
    if Intersect.RectRectFast(selectionRect, unitRect) then
      local unit = self.units.tracked[i]
      if selectionPredicate(unit) then
        selection:append(unit)
      end
    end
  end
  return selection
end

function CommandControl:setSelection (state, newSelection)
  self.selection     = newSelection
  self.prevSelection = newSelection
end

function CommandControl:focusGroupPanel (state, get)
  -- TODO : Widgets need enabled/disabled support
  --local friendliesButton = self.unitGroups[1].widget
  --friendliesButton:setEnabled(get)
  --friendliesButton:completeFade()

  for i = 1, #self.unitGroups do
    self.unitGroups[i].widget:setOnClick(function(button)
      if get then
        self:setSelection(state, self.unitGroups[i].list)
      else
        self.unitGroups[i].list = self.selection
      end
      self.groupPanel:cancel()
    end)
  end

  self.groupPanel:setModal(true)
end

function CommandControl:setActionMenu (state, enabled)
  if enabled then
    -- NOTE : Close the current menu even in case we don't end up showing a new one
    self.actionMenu:disable()
    self.actionTarget = nil

    if #self.selection > 0 then
      local mx, my = state.mousePosX, state.mousePosY
      self.actionTarget = self:findSelection(mx, my, 0, 0)[1]
      if self.actionTarget then

        -- NOTE : Anything we can select has Integrity and is alive
        local contextGrid = UI.Grid():setCols(1)
        for i = 1, #ContextEntries do
          local entry = ContextEntries[i]

          local button = entry.GetContextEntry(self, contextGrid)
          if button then
            button:setOnClick(function (button)
              self.actionMenu:disable()
              self:setActionDetails(state, true, entry)
            end)
            contextGrid:add(button)
          end
        end

        if #contextGrid.children > 0 then
          self.actionMenu:removeAll()
          self.actionMenu:add(contextGrid)
          self.actionMenu:setPos(mx, my)
          self.actionMenu:enable()
        end
      end
    end
  else
    self.actionMenu:disable()
    self.actionTarget = nil
  end
end

function CommandControl:setActionDetails (state, enabled, entry)
  if enabled then
    self.actionDetails:disable()

    local args    = entry.GetActionArgs()
    local details = entry.GetDetailsEntry(args)
    if details then
      self.actionDetails:removeAll()
      self.actionDetails
        :add(UI.Grid():setCols(1)
          :add(details)
          :add(UI.Button('Apply', function (button)
            self:sendAction(state, entry, args)
          end))
        )
      local mx, my = state.mousePosX, state.mousePosY
      self.actionDetails:setPos(mx, my)
      self.actionDetails:enable()
    else
      self:sendAction(state, entry, args)
    end
  else
    self.actionDetails:disable()
    self.actionTarget = nil
  end
end

function CommandControl:sendAction (state, entry, args)
  for i = 1, #self.selection do
    local unit = self.selection[i]
    local action = entry.GetAction(self.actionTarget, args)
    unit:pushAction(action)
  end
  self:setActionDetails(state, false)
end

function CommandControl:centerOnFocus (zoom)
  local count = #self.focus
  if count == 0 then return end

  local center = Vec3f()
  for i = 1, count do
    local unit = self.focus[i]
    center:iadd(unit:getPos())
  end
  center:idivs(count)
  self.camera.centerT = center

  if zoom and count > 0 then
    local radius = 0
    for i = 1, count do
      local unit = self.focus[i]
      local dist = (unit:getPos() - center):length() + unit:getRadius()
      radius = max(radius, dist)
    end
    local fov = Settings.get('render.fovY')
    self.camera.radiusT = radius / tan(fov / 2)
  end
end

function CommandControl:onDrag (state)
  -- Begin selection
  -- TODO : Should we push this drag threshold down into Canvas?
  local dx, dy = state.dragDeltaX, state.dragDeltaY
  self.selecting = self.selecting or (dx*dx + dy*dy) >= 8*8
end

function CommandControl:onDragEnd (state)
  if self.selecting then
    self.prevSelection = self.selection
  end
end

function CommandControl:onClick (state)
  if not self.selecting then
    local selection = self:findSelection(state.mousePosX, state.mousePosY, 0, 0)
    self:setSelection(state, List(selection[1]))
  end
  self.selecting = false
end

function CommandControl:onInput (state)
  if CommandBindings.ToggleDetails:get() > 0 then
    self.detailsPanel:toggleEnabled()
  end

  self.camera:push()
  self.camera:modYaw(        0.005 * CameraBindings.Yaw:get())
  self.camera:modPitch(      0.005 * CameraBindings.Pitch:get())
  self.camera:modRadius(exp(-0.1  * CameraBindings.Zoom:get()))

  self.moveDir = Vec3f(
    CameraBindings.TranslateX:get(), 0,
    CameraBindings.TranslateZ:get()
  ):clampLength(1)
  if not self.moveDir:isZero() then
    self.focusLock = false
  end

  local toggle = CommandBindings.ToggleSelection:get() > 0.5
  local append = CommandBindings.AppendSelection:get() > 0.5
  local remove = toggle and append
  if     remove then self.selectionMode = SelectionMode.Remove
  elseif toggle then self.selectionMode = SelectionMode.Toggle
  elseif append then self.selectionMode = SelectionMode.Add
  else               self.selectionMode = SelectionMode.Replace
  end

  if CommandBindings.Context :get() > 0 then self:setActionMenu (state, true) end
  if CommandBindings.SetGroup:get() > 0 then self:focusGroupPanel(state, false) end
  if CommandBindings.GetGroup:get() > 0 then self:focusGroupPanel(state, true) end

  local lockFocus = CommandBindings.LockFocus:get() > 0
  if CommandBindings.SetFocus:get() > 0 or lockFocus then
    -- Focus selection
    if #self.selection > 0 then
      self.focus = self.selection:clone()

    else
    -- Focus player
      local fallback = self.player:getControlling()
      if fallback then self.focus = List(fallback) end
    end

    self:centerOnFocus(true)
    self.focusLock = false
  end
  if lockFocus then self.focusLock = true end

  self.camera:pop()
end

function CommandControl:onUpdate (state)
  -- Move camera
  local f = 1.0 - exp(-16.0 * state.dt)
  self.velocity:ilerp(self.moveDir, f)
  if not self.velocity:isZero() then
    local r = self.camera.rot:getRight()
    local u = Vec3f(0, 1, 0)
    local f = u:cross(r)
    local velocity = Vec3f()
    velocity = velocity + r:muls(self.velocity.x)
    velocity = velocity + u:muls(self.velocity.y)
    velocity = velocity + f:muls(self.velocity.z)
    velocity = velocity:scale(500 * log(self.camera.radius))
    self.camera:modCenter(velocity:scale(state.dt))
  end

  self.units:update()
  local friendlyUnits = self.units.tracked:matchAll(function (u)
    return selectionPredicate(u) and u:getOwnerDisposition(self.player) > 0
  end)
  self.unitGroups[1].list = friendlyUnits

  -- Drop destroyed units
  self.prevSelection:ifilter(selectionPredicate)
  self.selection    :ifilter(selectionPredicate)
  self.focus        :ifilter(selectionPredicate)
  for i = 1, #self.unitGroups do
    self.unitGroups[i].list:ifilter(selectionPredicate)
  end
  -- Close action menu if the clicked unit is destroyed
  if self.actionTarget and not selectionPredicate(self.actionTarget) then
    self:setActionMenu(false)
  end

  -- Refresh unit info
  self.unitRects:clear()
  self.unitNDCs:clear()
  for i = 1, #self.units.tracked do
    local unit = self.units.tracked[i]

    local rect = Vec4f(self.camera:entityToScreenRect(unit))
    local ndc  = self.camera:worldToNDC(unit:getPos())
    self.unitRects:append(rect)
    self.unitNDCs:append(ndc)
  end

  -- Refresh selection
  if self.selecting then
    local newSelection = self:findSelection(
      state.dragBeginX, state.dragBeginY,
      state.dragDeltaX, state.dragDeltaY
    )

    -- Remove Selection
    if self.selectionMode == SelectionMode.Remove then
      self.selection = self.prevSelection:difference(newSelection)

    -- Append Selection
    elseif self.selectionMode == SelectionMode.Add then
      self.selection = self.prevSelection:union(newSelection)

    -- Replace Selection
    elseif self.selectionMode == SelectionMode.Replace then
      self.selection = newSelection

     -- Toggle Selection
    elseif self.selectionMode == SelectionMode.Toggle then
      self.selection = self.prevSelection:clone()
      for i = 1, #newSelection do
        local selected = newSelection[i]

        local index = self.selection:find(selected)
        if index then
          self.selection:removeAtFast(index)
        else
          self.selection:append(selected)
        end
      end
    end
  end

  if self.focusLock then self:centerOnFocus(false) end
end

function CommandControl:drawUnitRect (rect, ndc, color, radius)
  local ndcMax = max(abs(ndc.x), abs(ndc.y))

  -- In View
  if ndcMax <= 1.0 and ndc.z > 0 then
    local l = rect.x
    local t = rect.y
    local r = rect.x + rect.z
    local b = rect.y + rect.w
    UI.DrawEx.Wedge(r, t, radius, radius, 0.125, 0.2, color)
    UI.DrawEx.Wedge(l, t, radius, radius, 0.375, 0.2, color)
    UI.DrawEx.Wedge(l, b, radius, radius, 0.625, 0.2, color)
    UI.DrawEx.Wedge(r, b, radius, radius, 0.875, 0.2, color)

  -- Out of view
  else
    ndc.x = ndc.x / ((1 + 16/self.camera.sx) * ndcMax)
    ndc.y = ndc.y / ((1 + 16/self.camera.sy) * ndcMax)
    local x = ( ndc.x + 1)/2 * self.camera.sx
    local y = (-ndc.y + 1)/2 * self.camera.sy
    color.a = color.a * 0.5
    UI.DrawEx.Point(x, y, 64, color)
  end
end

function CommandControl:onDraw (focus, active)
  -- HACK : not valid to draw until an update has occured
  if #self.unitRects ~= #self.units.tracked then return end

  local player = self.player

  -- Unit Icons
  for i = 1, #self.units.tracked do
    local unit = self.units.tracked[i]

    if unit:isAlive() then
      local rect = self.unitRects[i]
      local ndc = self.unitNDCs[i]
      local rel = unit:getOwnerDisposition(player)
      local color = Disposition.GetColor(rel)
      self:drawUnitRect(rect, ndc, color, 4, self.camera)
    end
  end

  -- Unit Selection
  for i = 1, #self.selection do
    local unit     = self.selection[i]
    local selected = self.units.tracked:find(unit)

    local rect  = self.unitRects[selected]
    local ndc   = self.unitNDCs[selected]
    local color = Config.ui.color.selection:clone()
    self:drawUnitRect(rect, ndc, color, 8, self.camera)

  end

  -- Selection Box
  local state = self:getState()
  if self.selecting then
    local state = self:getState()
    UI.DrawEx.RectOutline(
      state.dragBeginX, state.dragBeginY,
      state.dragDeltaX, state.dragDeltaY,
      Config.ui.color.selection
    )
  end
end

function CommandControl:onDrawIcon (iconButton, focus, active)
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

  local xSize = 4
  UI.DrawEx.Cross(x + sx/2,      y + xSize + 6,      xSize, contentColor)
  UI.DrawEx.Cross(x + sx/2 +  8, y + xSize + 6 + 14, xSize, contentColor)
  UI.DrawEx.Cross(x + sx/2 -  8, y + xSize + 6 + 14, xSize, contentColor)
  UI.DrawEx.Cross(x + sx/2 + 16, y + xSize + 6 + 28, xSize, contentColor)
  UI.DrawEx.Cross(x + sx/2 - 16, y + xSize + 6 + 28, xSize, contentColor)
end

function CommandControl:buildGroupPanel ()
  local groupGrid = UI.Grid():setCols(1)
  for i = 1, #self.unitGroups do
    local group = self.unitGroups[i]

    local text = i == 1 and 'Friendlies' or format('Group %i', i - 1)
    group.widget = UI.Button(text)
    group.widget:setSize(160, 30)
    groupGrid:add(group.widget)
  end

  self.groupPanel = UI.Panel('Group Panel', false):setAlign(1.0, 0.5):setStretch(0, 0)
    :setOnCancel(function (panel)
      panel:setModal(false)
    end)
    :add(UI.NavGroup()
      :add(groupGrid)
    )
  self:add(self.groupPanel)
end

function CommandControl:buildDetailsPanel ()
  self.detailsPanel = UI.Window('Details', true):setAlign(0.0, 0.5):setStretch(0, 0)
    :setOnCancel(function (panel) panel:disable() end)
    :add(UI.Grid():setCols(1)
      -- Formation
      :add(UI.NavGroup()
        :add(UI.Collapsible('Formation'):setPad(2, 0, 2, 2)
          :add(UI.Grid():setCols(1)
            :add(UI.Button('Standard'))
            :add(UI.Button('Wedge'))
          )
        )
      )
      -- Stance
      :add(UI.NavGroup()
        :add(UI.Collapsible('Stance'):setPad(2, 0, 2, 2)
          :add(UI.Grid():setCols(1)
            :add(UI.Button('Passive'))
            :add(UI.Button('Aggressive'))
            :add(UI.Button('Defensive'))
          )
        )
      )
    )
  self:add(self.detailsPanel, false)
end

function CommandControl:buildActionMenu ()
  self.actionMenu = UI.Window('Action Menu'):setModal(true)
    :setOnCancel(function (panel)
      local state = panel:getState()
      self:setActionMenu(state, false)
    end)
  self:add(self.actionMenu, false)
end

function CommandControl:buildActionDetails ()
  self.actionDetails = UI.Window('Action Details'):setModal(true)
    :setOnCancel(function (panel)
      local state = panel:getState()
      self:setActionDetails(state, false)
    end)
  self:add(self.actionDetails, false)
end

function CommandControl.Create (gameView, player)
  local self = setmetatable({
    gameView      = gameView,
    player        = player,
    icon          = UI.Icon(),
    camera        = nil,
    firstRun      = true,

    moveDir       = Vec3f(),
    velocity      = Vec3f(),

    units         = TrackingList(player, Entity.isAlive),
    unitRects     = List(),
    unitNDCs      = List(),
    unitGroups    = {
      { list = List(), widget = nil },
      { list = List(), widget = nil },
      { list = List(), widget = nil },
      { list = List(), widget = nil },
    },
    groupPanel    = nil,
    detailsPanel  = nil,

    selecting     = false,
    selectionMode = nil,
    selection     = List(),
    prevSelection = List(),

    focus         = List(),
    focusLocked   = false,

    actionTarget  = nil,
    actionMenu    = nil,
    actionDetails = nil,

    children      = List(),
  }, CommandControl)

  self.icon:setOnDraw(function (ib, focus, active)
    self:onDrawIcon(ib, focus, active)
  end)

  self:buildGroupPanel()
  self:buildDetailsPanel()
  self:buildActionMenu()
  self:buildActionDetails()
  self.units:update()
  return self
end

return CommandControl

-- TODO : Josh, before I do a cleanup pass, I'd like a fresh set of eyes on the code.
-- TODO : Attack action causes an error if a unit is told to attack itself
-- TODO : Need to draw the Group Panel differently when it becomes modal. It's confusing when using the mouse.
-- TODO : Handle system changes (clear selection, hide action menu, update group in/out of system indicators)
-- TODO : I think we can simplify the isAlive filtering.
-- TODO : Clicking when a Collapsible has focus will trigger a click event even though the mouse isn't over it
-- TODO : Grab a camera reference during creation and remove the firstRun jank

--[[ TODO : When the action menu or details are canceled via clicking off of
            them the input doesn't get handled by the CommandControl. From a
            polish point of view it may be preferable to let this input 'leak
            through'. e.g. If the player right clicks a unit but then decides to
            change their selection and begins dragging the selection it should
            close the action menu *and* begin a selection operation. ]]

--[[ NOTE : We rebuild unitRects and unitNDCs every frame so we don't have to
            worry about synchronizing with changes to the units TrackingList. ]]
