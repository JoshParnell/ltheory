--[[----------------------------------------------------------------------------
  Responsible for deciding which set of controls are active any given time, such
  as the HUD/ShipControl, CommandControl, ResearchControl, ConstructionControl,
  etc.
----------------------------------------------------------------------------]]--
local Bindings       = require('Game.Controls.MasterBindings')
local CommandControl = require('Game.Controls.CommandControl')
local DebugControl   = require('Game.Controls.DebugControl')
local DockControl    = require('Game.Controls.DockControl')
local HUD            = require('Game.Controls.HUD')

local MasterControl = {}
MasterControl.__index = MasterControl
setmetatable(MasterControl, UI.Container)

local function isPlayerDocked (self)
  local playerShip   = self.player:getControlling()
  local playerParent = playerShip:getParent()
  local playerDocked = playerParent:hasDockable()
  return playerDocked
end

local ControlSets = {
  -- Undocked
  {
    predicate = function (self) return not self.player:getControlling():getCurrentAction() end,
    container = nil,
    controls  = List(
      {
        name       = 'Ship',
        ctor       = HUD,
        panel      = nil,
        iconButton = nil,
      },
      {
        name       = 'Command',
        ctor       = CommandControl,
        panel      = nil,
        iconButton = nil,
      },
      {
        name       = 'Debug',
        ctor       = DebugControl,
        panel      = nil,
        iconButton = nil,
      }
    ),
  },
  -- Docked
  {
    predicate  = function (self) return isPlayerDocked(self) end,
    container  = nil,
    controls   = List(
      {
        name       = 'Dock',
        ctor       = DockControl,
        panel      = nil,
        iconButton = nil,
      }
    ),
  },
}

function MasterControl:onInput (state)
  if Bindings.TogglePanel:get() > 0 then
    self.panel:toggleEnabled()
    if self.panel:isEnabled() and self.activeControlDef then
      local state = self:getState()
      if state then
        state:setFocus(self.activeControlDef.iconButton)
      end
    end
  end

  if self.panel:isEnabled() then
    if self.activeControlSet.predicate(self) then
      for i = 1, #self.activeControlSet.controls do
        local control = self.activeControlSet.controls[i]
        if Bindings.Controls[i]:get() > 0 then
          self:activateControl(control)
        end
      end
    end
  end
end

function MasterControl:onUpdate (state)
  local oldSet = self.activeControlSet
  local newSet
  for i = #ControlSets, 1, -1 do
    local set = ControlSets[i]
    if set.predicate(self) then
      newSet = set
      break
    end
  end

  if oldSet ~= newSet then
    if oldSet then
      oldSet.container:disable()
      if newSet then oldSet.container:completeFade() end
      self:activateControl(nil)
    end
    self.activeControlSet = newSet
    if newSet then
      newSet.container:enable()
      if oldSet then newSet.container:completeFade() end
      self:activateControl(newSet.controls[1])
    end
  end
end

function MasterControl:activateControl (controlDef)
  if controlDef == self.activeControlDef then return end

  if self.activeControlDef then
    self.activeControlDef.panel:disable()
  end
  self.activeControlDef = controlDef
  if self.activeControlDef then
    self.activeControlDef.panel:enable()

    local state = self:getState()
    if state then
      state:setFocus(self.activeControlDef.iconButton)
    end
  end
end

function MasterControl.Create (gameView, player)
  local self = setmetatable({
    gameView         = gameView,
    player           = player,
    activeControlSet = nil,
    activeControlDef = nil,
    panel            = nil,

    children         = List(),
  }, MasterControl)

  -- Create Controls
  for i = 1, #ControlSets do
    local set = ControlSets[i]
    for j = 1, #set.controls do
      local controlDef = set.controls[j]
      controlDef.panel = controlDef.ctor(self.gameView, self.player)
      self:add(controlDef.panel, false)
    end
  end

  -- Create Panel
  local barHeight = Config.ui.controlBarHeight
  -- TODO : Will the NavGroup behave well with disabled sets?
  local navGroup  = UI.NavGroup()
  for i = 1, #ControlSets do
    local set = ControlSets[i]

    set.container = UI.Grid():setRows(1):setPadCellX(4):setPadUniform(8)
    navGroup:add(set.container)
    for j = 1, #set.controls do
      local controlDef = set.controls[j]

      controlDef.iconButton = UI.IconButton(controlDef.panel.icon, function (button)
        self:activateControl(controlDef)
      end):setSize(barHeight, barHeight):setAlignX(0.5)
      controlDef.iconButton.name = format('Control Button %i', i)
      set.container:add(controlDef.iconButton)
    end
  end

  self.panel = UI.Panel('Control Selector', true):setAlign(0.5, 0.0):setStretch(0, 0)
    :setOnCancel(function (panel) panel:disable() end)
    :add(navGroup)
  self:add(self.panel, false)

  -- Init Control Set
  for i = 1, #ControlSets do
    local set = ControlSets[i]
    if set.predicate(self) and not self.activeControlSet then
      self.activeControlSet = set
      set.container:enable()
    else
      set.container:disable()
    end
  end

  -- Set Default Control
  for i = 1, #ControlSets do
    local set = ControlSets[i]
    if set.predicate(self) then
      local default
      for j = 1, #set.controls do
        local control = set.controls[j]
        if control.name == Config.ui.defaultControl then
          default = control
          break
        end
      end
      self:activateControl(default or set.controls[1])
      break
    end
  end
  self.activeControlDef.panel:completeFade()
  self.gameView.camera:cancelLerp()
  return self
end

return MasterControl

--[[ TODO : Attempt to invert the GameView-Control relationship. Controls are
            the things determining what the view should be. There's a good
            chance what we really want is MasterControl as the root, SomeInput
            as the child and a set of SomeViews as the children of that. In the
            case of VR there would be a single SomeInput and a SomeView for each
            eye. ]]

-- TODO : Target trackers are wrong for the first frame
-- TODO : Auto-close the top bar when a control is selected?

--[[ TODO : It's not ideal that we refresh focus twice when changing Controls.
            Once when disabling the current Control and once when enabling the
            new Control. This leads to a focus being found on the first refresh
            and the newly enabled control will not be considered. On the other
            hand, there's nothing valid for focus during that first refresh, so
            this won't actually cause a problem currently, but I'd consider it a
            design flaw that is going to bite someone in the future. ]]
