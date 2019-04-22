local Bindings = require('phx.util.ApplicationBindings')

local Application = class(function (self) end)

-- Virtual ---------------------------------------------------------------------

function Application:getDefaultSize ()
  return 1600, 900
end

function Application:getTitle () return
  'Phoenix Engine Application'
end

function Application:getWindowMode ()
  return Bit.Or32(WindowMode.Shown, WindowMode.Resizable)
end

function Application:onInit         ()       end
function Application:onDraw         ()       end
function Application:onResize       (sx, sy) end
function Application:onUpdate       (dt)     end
function Application:onExit         ()       end
function Application:onInput        ()       end

function Application:quit ()
  self.exit = true
end

-- Application Template --------------------------------------------------------

function Application:run ()
  self.resX, self.resY = self:getDefaultSize()
  self.window = Window.Create(
    self:getTitle(),
    WindowPos.Default,
    WindowPos.Default,
    self.resX,
    self.resY,
    self:getWindowMode())

  self.exit = false
  self.window:setVsync(Config.render.vsync)

  if Config.jit.profile and Config.jit.profileInit then Jit.StartProfile() end

  Preload.Run()

  Input.LoadGamepadDatabase('gamecontrollerdb_205.txt');
  self:onInit()
  self:onResize(self.resX, self.resY)

  local font = Font.Load('NovaMono', 10)
  self.lastUpdate = TimeStamp.GetFuture(-1.0 / 60.0)

  if Config.jit.dumpasm then Jit.StartDump() end
  if Config.jit.profile and not Config.jit.profileInit then Jit.StartProfile() end
  if Config.jit.verbose then Jit.StartVerbose() end

  local profiling = false
  local toggleProfiler = false
  while not self.exit do
    if toggleProfiler then
      toggleProfiler = false
      profiling = not profiling
      if profiling then Profiler.Enable() else Profiler.Disable() end
    end

    Profiler.SetValue('gcmem', GC.GetMemory())
    Profiler.Begin('Frame')
    Engine.Update()

    do
      Profiler.SetValue('gcmem', GC.GetMemory())
      Profiler.Begin('App.onResize')
      local size = self.window:getSize()
      if size.x ~= self.resX or size.y ~= self.resY then
        self.resX = size.x
        self.resY = size.y
        self:onResize(self.resX, self.resY)
      end
      Profiler.End()
    end

    local timeScale = 1.0
    local doScreenshot = false

    do
      Profiler.SetValue('gcmem', GC.GetMemory())
      Profiler.Begin('App.onInput')

       -- TODO : Remove this once bindings are fixed
      if Input.GetKeyboardCtrl() and Input.GetPressed(Button.Keyboard.W) then self:quit() end
      if Input.GetPressed(Bindings.Exit) then self:quit() end

      if Input.GetPressed(Bindings.ProfilerToggle) then
        toggleProfiler = true
      end

      if Input.GetPressed(Bindings.Screenshot) then
        doScreenshot = true
        if Settings.exists('render.superSample') then
          self.prevSS = Settings.get('render.superSample')
          Settings.set('render.superSample', 2)
        end
      end

      if Input.GetPressed(Bindings.ToggleFullscreen) then
        self.window:toggleFullscreen()
      end

      if Input.GetPressed(Bindings.Reload) then
        Profiler.Begin('Engine.Reload')
        Cache.Clear()
        SendEvent('Engine.Reload')
        Preload.Run()
        Profiler.End()
      end

      if Input.GetDown(Bindings.TimeAccel) then
        timeScale = Config.debug.timeAccelFactor
      end

      if Input.GetPressed(Bindings.ToggleWireframe) then
        Settings.set('render.wireframe', not Settings.get('render.wireframe'))
      end

      self:onInput()
      Profiler.End()
    end

    do
      Profiler.SetValue('gcmem', GC.GetMemory())
      Profiler.Begin('App.onUpdate')
      local now = TimeStamp.Get()
      self.dt = TimeStamp.GetDifference(self.lastUpdate, now)
      self.lastUpdate = now
      self:onUpdate(timeScale * self.dt)
      Profiler.End()
    end

    do
      Profiler.SetValue('gcmem', GC.GetMemory())
      Profiler.Begin('App.onDraw')
      self.window:beginDraw()
      self:onDraw()
      Profiler.End()
    end

    if doScreenshot then
      ScreenCap()
      if self.prevSS then
        Settings.set('render.superSample', self.prevSS)
        self.prevSS = nil
      end
    end

    do -- Metrics display
      if Config.debug.metrics then -- Metrics Display
        local s = string.format(
          '%.2f ms / %.0f fps / %.2f MB / %.1f K tris / %d draws / %d imms / %d swaps',
          1000.0 * self.dt,
          1.0 / self.dt,
          GC.GetMemory() / 1000.0,
          Metric.Get(Metric.TrisDrawn) / 1000,
          Metric.Get(Metric.DrawCalls),
          Metric.Get(Metric.Immediate),
          Metric.Get(Metric.FBOSwap))
        BlendMode.Push(BlendMode.Alpha)
        Draw.Color(0.1, 0.1, 0.1, 0.5)
        Draw.Rect(0, self.resY - 20, self.resX, self.resY)
        font:draw(s, 10, self.resY - 5, 1, 1, 1, 1)

        local y = self.resY - 5
        if profiling then
          font:draw('>> PROFILER ACTIVE <<', self.resX - 128, y, 1, 0, 0.15, 1)
          y = y - 12
        end
        BlendMode.Pop()
      end
    end

    do -- End Draw
      Profiler.SetValue('gcmem', GC.GetMemory())
      Profiler.Begin('App.SwapBuffers')
      self.window:endDraw()
      Profiler.End()
    end
    Profiler.End()
    Profiler.LoopMarker()
  end

  if profiling then Profiler.Disable() end

  if Config.jit.dumpasm then Jit.StopDump() end
  if Config.jit.profile then Jit.StopProfile() end
  if Config.jit.verbose then Jit.StopVerbose() end

  do -- Exit
    self:onExit()
    self.window:free()
  end
end

return Application
