local CameraBindings = require('Game.Controls.CameraBindings')
local ShipBindings = require('Game.Controls.ShipBindings')
local Disposition = require('Game.Components.Dispositions')

local HUD = {}
HUD.__index = HUD
setmetatable(HUD, UI.Panel)

HUD.name      = 'HUD'
HUD.focusable = true
HUD:setPadUniform(8)

function HUD:onEnable ()
  -- TODO : Wtf does this do? Who wrote this?? WHY.
  local pCamera = self.gameView.camera
  local camera = self.gameView.camera
  camera:warp()
  camera:lerpFrom(pCamera.pos, pCamera.rot)
end

function HUD:drawTargets (a)
  if not Config.ui.showTrackers then return end
  local camera = self.gameView.camera

  local cTarget = Color(1.0, 0.5, 0.1, 1.0 * a)
  local cLock = Color(1.0, 0.5, 0.1, 1.0 * a)

  local player = self.player
  local playerShip = player:getControlling()
  local playerTarget = playerShip:getTarget()

  local closest = nil
  local minDist = 128
  local center = Vec2f(self.sx / 2, self.sy / 2)

  for i = 1, #self.targets.tracked do
    local target = self.targets.tracked[i]
    if target ~= playerShip and target:isAlive() then
      local pos = target:getPos()
      local ndc = camera:worldToNDC(pos)
      local ndcMax = max(abs(ndc.x), abs(ndc.y))

      local disp = target:getOwnerDisposition(player)
      local c = Disposition.GetColor(disp)
      c.a = a * c.a
      if ndcMax <= 1.0 and ndc.z > 0 then
        do -- Draw rounded box corners
          local bx1, by1, bsx, bsy = camera:entityToScreenRect(target)
          local bx2, by2 = bx1 + bsx, by1 + bsy
          --local a = a * (1.0 - exp(-0.5 * max(0.0, max(bsx, bsy) - 2.0)))
          UI.DrawEx.Wedge(bx2, by1, 4, 4, 0.125, 0.2, c)
          UI.DrawEx.Wedge(bx1, by1, 4, 4, 0.375, 0.2, c)
          UI.DrawEx.Wedge(bx1, by2, 4, 4, 0.625, 0.2, c)
          UI.DrawEx.Wedge(bx2, by2, 4, 4, 0.875, 0.2, c)
          if playerTarget == target then
            UI.DrawEx.Wedge(bx2, by1, 12, 12, 0.125, 0.3, cLock)
            UI.DrawEx.Wedge(bx1, by1, 12, 12, 0.375, 0.3, cLock)
            UI.DrawEx.Wedge(bx1, by2, 12, 12, 0.625, 0.3, cLock)
            UI.DrawEx.Wedge(bx2, by2, 12, 12, 0.875, 0.3, cLock)
          elseif self.target == target then
            UI.DrawEx.Wedge(bx2, by1, 8, 8, 0.125, 0.2, cTarget)
            UI.DrawEx.Wedge(bx1, by1, 8, 8, 0.375, 0.2, cTarget)
            UI.DrawEx.Wedge(bx1, by2, 8, 8, 0.625, 0.2, cTarget)
            UI.DrawEx.Wedge(bx2, by2, 8, 8, 0.875, 0.2, cTarget)
          end
        end

        local ss = camera:ndcToScreen(ndc)
        local dist = ss:distance(center)
        if disp < 0.5 and dist < minDist then
          closest = target
          minDist = dist
        end
      else
        ndc.x = ndc.x / ((1 + 16/camera.sx) * ndcMax)
        ndc.y = ndc.y / ((1 + 16/camera.sy) * ndcMax)
        local x = ( ndc.x + 1)/2 * camera.sx
        local y = (-ndc.y + 1)/2 * camera.sy
        if disp < 0.0 then
          c.a = c.a * 0.5
          UI.DrawEx.Point(x, y, 64, c)
        end
      end
    end
  end

  self.target = closest
end

function HUD:drawLock (a)
  local playerShip = self.player:getControlling()
  local target = self.player:getControlling():getTarget()
  if not target then return end
  local camera = self.gameView.camera
  local center = Vec2f(self.sx / 2, self.sy / 2)

  do -- Direction indicator
    local r = 96
    local pos = target:getPos()
    local ndc = camera:worldToNDC(pos)
    local ndcMax = max(abs(ndc.x), abs(ndc.y))
    if ndcMax > 1 or ndc.z <= 0 then ndc:idivs(ndcMax) end
    local ss = camera:ndcToScreen(ndc)
    local dir = ss - center
    local dist = dir:length()
    if dist > 1 then
      dir:inormalize()
      ss = center + dir:scale(r)
      local a = a * (1.0 - exp(-max(0.0, dist / (r + 16) - 1.0)))
      UI.DrawEx.Arrow(ss, dir:scale(6), Color(1.0, 0.5, 0.1, a))
    end
  end

  -- Impact point
  if playerShip.socketSpeedMax > 0 then
    local tHit, pHit = Math.Impact(
      playerShip:getPos(),
      target:getPos(),
      playerShip:getVelocity(),
      target:getVelocity(),
      playerShip.socketSpeedMax)

    if tHit then
      local ndc = camera:worldToNDC(pHit)
      local ndcMax = max(abs(ndc.x), abs(ndc.y))
      if ndcMax <= 1 and ndc.z > 0 then
        local ss = camera:ndcToScreen(ndc)
        UI.DrawEx.Cross(ss.x, ss.y, 4, Color(1.0, 0.5, 0.1, a))
      end
    end
  end
end

function HUD:drawReticle (a)
  local cx, cy = self.sx / 2, self.sy / 2
  do -- Reticle
    do -- Central Crosshair
      local c = Color(0.1, 0.5, 1.0, a)
      local phase = 0.125
      local r1 = 24
      local r2 = 28
      local n = 3
      for i = 0, n - 1 do
        local angle = -(Math.Pi2 + (i / n) * Math.Tau)
        local dx, dy = cos(angle), sin(angle)
        UI.DrawEx.Line(cx + r1 * dx, cy + r1 * dy, cx + r2 * dx, cy + r2 * dy, c)
      end
    end

    if false then -- Aim
      local c = Color(0.1, 0.5, 1.0, a)
      local yaw, pitch = ShipBindings.Yaw:get(), ShipBindings.Pitch:get()
      local x = cx + 0.5 * self.sx * self.aimX
      local y = cy - 0.5 * self.sy * self.aimY
      UI.DrawEx.Ring(x, y, 16, c)
    end
  end
end

function HUD:drawDockPrompt (a)
  local x, y, sx, sy = self:getRectGlobal()
  UI.DrawEx.TextAdditive(
    'NovaMono',
    'Press ??? to Dock',
    16,
    x, y, sx, sy,
    1, 1, 1, self.dockPromptAlpha * a,
    0.5, 0.99
  )
end

function HUD:controlThrust (e)
  if not e:hasThrustController() then return end
  local c = e:getThrustController()
  c:setThrust(
    ShipBindings.ThrustZ:get(),
    ShipBindings.ThrustX:get(),
    0,
    ShipBindings.Yaw:get(),
   -ShipBindings.Pitch:get(),
    ShipBindings.Roll:get(),
    ShipBindings.Boost:get())
  self.aimX = c.yaw
  self.aimY = c.pitch
end

function HUD:controlTurrets (e)
  local targetPos, targetVel
  local target = e:getTarget()
  if target and target:getOwnerDisposition(self.player) <= 0.0 then
    targetPos = target:getPos()
    targetVel = target:getVelocity()
  end

  local firing   = ShipBindings.Fire:get() > 0 and 1 or 0
  local camera   = self.gameView.camera
  local ndc      = Vec3f(self.aimX, self.aimY)
  local fallback = camera:mouseToRay(1):getPoint(e.socketRangeMin)

  -- Compute a firing solution separately for each turret to support
  -- different projectile velocities & ranges
  for turret in e:iterSocketsByType(SocketType.Turret) do
    if Config.game.autoTarget and targetPos then
      turret:aimAtTarget(target, fallback)
    else
      turret:aimAt(fallback)
    end
    turret.firing = firing
  end
end

function HUD:controlTargetLock (e)
  if ShipBindings.LockTarget:get() > 0.5 then e:setTarget(self.target) end
  if ShipBindings.ClearTarget:get() > 0.5 then e:setTarget(nil) end
end

function HUD:onInput (state)
  local camera = self.gameView.camera
  camera:push()
  camera:modRadius(exp(-0.1 * CameraBindings.Zoom:get()))
  -- camera:modYaw(0.005 * CameraBindings.Yaw:get())
  -- camera:modPitch(0.005 * CameraBindings.Pitch:get())

  local e = self.player:getControlling()
  self:controlThrust(e)
  self:controlTurrets(e)
  self:controlTargetLock(e)
  camera:pop()

  if self.dockable then
    if ShipBindings.Dock:get() > 0 then
      e:pushAction(Actions.DockAt(self.dockable))
      self.dockable = nil
    end
  end
end

function HUD:onUpdate (state)
  self.targets:update()
  self.dockables:update()

  local f = 1.0 - exp(-state.dt * 8.0)
  local alphaT = self.dockable and 1 or 0
  self.dockPromptAlpha = Math.Lerp(self.dockPromptAlpha, alphaT, f)

  local pPos    = self.player:getControlling():getPos()
  local pRad    = self.player:getControlling():getRadius()
  local minDist = Config.game.dockRange
  self.dockable = nil
  for i = 1, #self.dockables.tracked do
    local dockable = self.dockables.tracked[i]

    local dPos = dockable:getPos()
    local dRad = dockable:getRadius()
    local dist = pPos:distance(dPos) - pRad - dRad
    if dist < minDist then
      minDist = dist
      self.dockable = dockable
    end
  end
end

function HUD:onDraw (focus, active)
  Profiler.Begin('HUD.DrawTargets') self:drawTargets   (self.enabled) Profiler.End()
  Profiler.Begin('HUD.DrawLock')    self:drawLock      (self.enabled) Profiler.End()
  Profiler.Begin('HUD.DrawReticle') self:drawReticle   (self.enabled) Profiler.End()
  Profiler.Begin('HUD.DrawPrompt')  self:drawDockPrompt(self.enabled) Profiler.End()
end

function HUD:onDrawIcon (iconButton, focus, active)
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

  local cx = x + sx/2
  local w1y, w1sx, w1sy = 10, 10, 8
  local w2y, w2sx, w2sy =  0,  5, 4
  local ty, by = y + 8, y + sy - 12
  UI.DrawEx.Line(cx,     ty,       cx,        by,              contentColor)
  UI.DrawEx.Line(cx + 2, ty + w1y, cx + w1sx, ty + w1y + w1sy, contentColor)
  UI.DrawEx.Line(cx - 2, ty + w1y, cx - w1sx, ty + w1y + w1sy, contentColor)
  UI.DrawEx.Line(cx + 2, by,       cx + w2sx, by + w2y + w2sy, contentColor)
  UI.DrawEx.Line(cx - 2, by,       cx - w2sx, by + w2y + w2sy, contentColor)
end

function HUD.Create (gameView, player)
  local self = setmetatable({
    gameView        = gameView,
    player          = player,
    icon            = UI.Icon(),

    target          = nil,
    targets         = TrackingList(player, Entity.isAlive),

    -- TODO Probably want a reusable prompt thing
    dockPromptAlpha = 0,
    dockable        = nil,
    dockables       = TrackingList(player, Entity.hasDockable),
    aimX            = 0,
    aimY            = 0,
    impacts         = 0,

    children  = List(),
  }, HUD)

  self.icon:setOnDraw(function (ib, focus, active)
    self:onDrawIcon(ib, focus, active)
  end)
  self.targets:update()
  self.dockables:update()
  return self
end

return HUD
