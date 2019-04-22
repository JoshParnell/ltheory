local DebugContext = require('Game.DebugContext')

local SystemMap = {}
SystemMap.__index  = SystemMap
setmetatable(SystemMap, UI.Container)

local kPanSpeed = 500
local kZoomSpeed = 0.1

SystemMap.scrollable = true
SystemMap.focusable  = true
SystemMap:setPadUniform(0)

function SystemMap:onDraw (state)
  Draw.Color(0.1, 0.11, 0.12, 1)
  local x, y, sx, sy = self:getRectGlobal()
  Draw.Rect(x, y, sx, sy)

  Draw.Color(0, 1, 0, 1)
  local hx, hy = sx / 2, sy / 2
  local dx, dy = self.pos.x + hx, self.pos.y + hy

  local c = {
    r = 0.1,
    g = 0.5,
    b = 1.0,
    a = 0.1,
  }

  local best = nil
  local bestDist = math.huge
  local mp = Input.GetMousePosition()

  BlendMode.PushAlpha()
  Draw.SmoothPoints(true)
  for _, e in self.system:iterChildren() do
    local p = e:getPos()
    local x = p.x - dx
    local y = p.z - dy
    x = self.x + x * self.zoom + hx
    y = self.y + y * self.zoom + hy
    Draw.PointSize(2.0)
    if e:hasActions() then
      Draw.Color(1.0, 0.0, 0.4, 1)
    else
      Draw.Color(0.3, 0.3, 0.3, 1)
    end
    Draw.Point(x, y)

    if e:hasFlows() then
      UI.DrawEx.Ring(x, y, self.zoom * e:getScale(), { r = 0.1, g = 0.5, b = 1.0, a = 1.0 })
    end

    if e:hasYield() then
      UI.DrawEx.Ring(x, y, self.zoom * e:getScale(), { r = 1.0, g = 0.5, b = 0.1, a = 0.5 })
    end

    if self.focus == e then
      UI.DrawEx.Ring(x, y, 8, { r = 1.0, g = 0.0, b = 0.3, a = 1.0 })
    end

    local d = Vec2f(x, y):distanceSquared(mp)
    if d < bestDist then
      bestDist = d
      best = e
    end
  end
  Draw.Color(1, 1, 1, 1)
  Draw.SmoothPoints(false)
  BlendMode.Pop()

  if Input.GetDown(Button.Mouse.Left) then self.focus = best end

  do -- Debug Info
    local dbg = DebugContext(16, 16)
    dbg:text('--- System ---')
    dbg:indent()
    self.system:send(Event.Debug(dbg))
    dbg:undent()

    if self.focus then
      dbg:text('')
      dbg:text('--- %s ---', self.focus:getName())
      dbg:indent()
      self.focus:send(Event.Debug(dbg))
      dbg:undent()
    end
  end
end

function SystemMap:onInput (state)
  self.zoom = self.zoom * exp(kZoomSpeed * Input.GetMouseScroll().y)
  self.pos.x = self.pos.x + (kPanSpeed * state.dt / self.zoom) * (
    Input.GetValue(Button.Keyboard.D) - Input.GetValue(Button.Keyboard.A))
  self.pos.y = self.pos.y + (kPanSpeed * state.dt / self.zoom) * (
    Input.GetValue(Button.Keyboard.S) - Input.GetValue(Button.Keyboard.W))
  self.zoom = self.zoom * exp(10.0 * kZoomSpeed * state.dt * (
    Input.GetValue(Button.Keyboard.P) - Input.GetValue(Button.Keyboard.O)))
end

function SystemMap.Create (system)
  local self = setmetatable(UI.Window('System Map', false), SystemMap)
  self:setStretch(1, 1)
  self.system = system
  self.pos = Vec2f(0, 0)
  self.zoom = 0.1
  return self
end

return SystemMap
