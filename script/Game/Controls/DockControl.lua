local Actions = requireAll('Game.Actions')
local ShipBindings = require('Game.Controls.ShipBindings')

local DockControl = {}
DockControl.__index = DockControl
setmetatable(DockControl, UI.Panel)

function DockControl:onEnable ()
  local pCamera = self.gameView.camera
  self.gameView:setOrbit(true)

  local station  = self.player:getControlling():getParent()

  self.camera = self.gameView.camera
  self.camera:setYaw(-Math.Pi2)
  self.camera:setPitch(Math.Pi4)
  self.camera:setRadius(1000)
  self.camera:setTarget(station)
  self.camera:setRelative(true)
  self.camera:warp()
  self.camera:lerpFrom(pCamera.pos, pCamera.rot)
end

function DockControl:onInput (state)
  if ShipBindings.Undock:get() > 0 then -- Flat: use the new Undock input control
    self.player:getControlling():pushAction(Actions.Undock())
  end
end

function DockControl:onDraw (focus, active)
  -- TODO : Unify this with HUD
  local x, y, sx, sy = self:getRectGlobal()
  UI.DrawEx.TextAdditive(
    'NovaMono',
    'Press J to Undock', -- Flat: use the input control mapped to Undock
    16,
    x, y, sx, sy,
    1, 1, 1, 1,
    0.5, 0.99
  )
end

function DockControl:onDrawIcon (iconButton, focus, active)
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

  UI.DrawEx.Ring(x + sx/2, y + 10,      14, contentColor)
  UI.DrawEx.Ring(x + sx/2, y + 10 + 12, 10, contentColor)
  UI.DrawEx.Ring(x + sx/2, y + 10 + 20,  6, contentColor)
end

function DockControl.Create (gameView, player)
  local self = setmetatable({
    gameView = gameView,
    player   = player,
    icon     = UI.Icon(),
    camera   = nil,

    children = List(),
  }, DockControl)

  self.icon:setOnDraw(function (ib, focus, active)
    self:onDrawIcon(ib, focus, active)
  end)
  return self
end

return DockControl
