local DebugWindow = {}
DebugWindow.__index = DebugWindow
setmetatable(DebugWindow, UI.Window)

DebugWindow.name = 'Debug Window'

function DebugWindow:onLayoutSize ()
  UI.Window.onLayoutSize(self)
  self.desiredSX = self.enabledT * self.desiredSX
end

function DebugWindow:onDraw (focus, active)
  self.timer:reset()
  UI.Window.onDraw(self, focus, active)
  self.drawTime = self.timer:getElapsed()
end

local lastAlloc = 0
local emaAlloc = 0
local emaFrameTime = 0

local function getAllocationRate (dt)
  local alloc = GC.GetMemory()
  local freq = alloc - lastAlloc
  -- Only update the EMA if the GC is inactive (freq < 0 -> GC is running)
  if freq >= 0 then emaAlloc = Math.EMA(emaAlloc, freq, dt, 1.0) end
  lastAlloc = alloc
  return emaAlloc
end

function DebugWindow:createProfilingText ()
  return UI.NavGroup()
    :add(UI.Collapsible('Profiling')
      :add(UI.Grid():setCols(1):setPad(2, 0, 2, 2)
        :add(UI.Grid():setPadCellX(8)
          :add(UI.Label('Frame Time'))
          :add(UI.Label():setMinWidth(60):setFormat('%.2f ms')
            :setPollFn(function () return 1000 * self.ltheory.dt end))
          :add(UI.Label('Frame Time EMA1'))
          :add(UI.Label():setMinWidth(60):setFormat('%.2f ms')
            :setPollFn(function ()
              emaFrameTime = Math.EMA(emaFrameTime, self.ltheory.dt, self.ltheory.dt, 1.0)
              return 1000.0 * emaFrameTime end))
          :add(UI.Label('FPS'))
          :add(UI.Label():setMinWidth(60):setFormat('%.0f')
            :setPollFn(function () return 1.0 / emaFrameTime end))
          :add(UI.Label('Lua Memory'))
          :add(UI.Label():setMinWidth(70):setFormat('%.2f kb')
            :setPollFn(GC.GetMemory))
          :add(UI.Label('Lua Allocation Rate'))
          :add(UI.Label():setMinWidth(70):setFormat('%.2f kb/s')
            :setPollFn(function () return getAllocationRate(self.ltheory.dt) end))
          :add(UI.Label('Lua GC Passes'))
          :add(UI.Label():setPollFn(GC.GetPasses))
          :add(UI.Label('Lua GC Frequency'))
          :add(UI.Label():setFormat('%.2f Hz')
            :setPollFn(GC.GetFrequency))
          :add(UI.Label('Total Rigidbodies'))
          :add(UI.Label():setPollFn(function ()
            local total = 0
            for i = 1, Type.GetCount() do
              local type = Type.GetByID(i)
              if type.pool and type:hasField('body') then
                total = total + libphx.MemPool_GetSize(type.pool)
              end
            end
            return total
          end))
          --:add(UI.Label('Awake Rigidbodies'))
          --:add(UI.Label():setPollFn(function ()
          --  local total = 0
          --  for i = 1, Type.GetCount() do
          --    local type = Type.GetByID(i)
          --    if type.pool and type:hasField('body') then
          --      total = total + libphx.MemPool_GetSize(type.pool)
          --    end
          --  end
          --  return total
          --end))
        )
      )
    )
end

function DebugWindow:createProfilingGraphs ()
  return UI.NavGroup()
    :add(UI.Collapsible('Profiling Graphs')
      :add(UI.Grid():setCols(1):setPad(2, 0, 2, 2)
        :add(UI.Label('Frame Time (s)'))
        :add(UI.Graph()
          :setMode(UI.Graph.Mode.Sweep)
          :setPollFn(function () return self.ltheory.dt * 1000 end)
          :addRuler(1000 /  60,  '100%', Vec3f(1.0, 0.2, 0.05))
          :addRuler(1000 / 120, '50%', Vec3f(1.0, 0.5, 0.10), true)
          :addRuler(1000 / 240, '25%', Vec3f(0.5, 1.0, 0.20), true)
        )
        :add(UI.Label('Lua Memory Allocated (Kb)'))
        :add(UI.Graph()
          :setMode(UI.Graph.Mode.Scroll)
          :setPollFn(GC.GetMemory)
          :setMaxHeight(64)
        )
      )
    )
end

function DebugWindow:createAudioSection ()
  return UI.NavGroup()
    :add(UI.Collapsible('Audio')
      :add(UI.Grid():setPad(2, 0, 2, 2):setPadCellX(8)
        :add(UI.Label('Loaded Sounds'))
        :add(UI.Label():setPollFn(Audio.GetLoadedCount))
        :add(UI.Label('Total Sounds'))
        :add(UI.Label():setPollFn(Audio.GetTotalCount))
        :add(UI.Label('Playing Sounds'))
        :add(UI.Label():setPollFn(Audio.GetPlayingCount))
      )
    )
end

function DebugWindow:createUISection ()
  local canvas = self.ltheory.canvas
  local state  = self.ltheory.canvas.state
  local uiDebugGrid = UI.Grid()

  return UI.NavGroup()
    :add(UI.Collapsible('UI')
      :add(UI.Grid():setCols(1):setPad(2, 0, 2, 2)
        :add(UI.Button('Toggle Grid Layout', function (button, state)
          if uiDebugGrid.fixedRows then uiDebugGrid:setCols(2) else uiDebugGrid:setRows(2) end end))
        :add(uiDebugGrid:setPadCellX(8)
          --:add(UI.Label('Input Time'))
          --:add(UI.Label():setFormat('%.3f ms')
          --  :setPollFn(function () return 1000 * canvas.inputTime end))
          :add(UI.Label('Update Time'))
          :add(UI.Label():setFormat('%.3f ms')
            :setPollFn(function () return 1000 * canvas.updateTime end))
          :add(UI.Label('Layout Time'))
          :add(UI.Label():setFormat('%.3f ms')
            :setPollFn(function () return 1000 * canvas.layoutTime end))
          :add(UI.Label('Draw Time'))
          :add(UI.Label():setFormat('%.3f ms')
            :setPollFn(function () return 1000 * self.drawTime end))
          --:add(UI.Label('Total Time'))
          --:add(UI.Label():setFormat('%.3f ms')
          --  :setPollFn(function () return 1000 * (canvas.inputTime + canvas.updateTime + canvas.layoutTime + self.drawTime) end))
          -- TODO : Fix this
          --:add(UI.Label('Input Events'))
          --:add(UI.Label():setPollFn(function () return self.ltheory.eventCount end))
          :add(UI.Label('Focus'))
          :add(UI.Label():setMinWidth(160):setPollFn(function ()
            return state.focus and state.focus.name or 'nil' end))
          :add(UI.Label('Active'))
          :add(UI.Label():setMinWidth(160):setPollFn(function ()
            return state.active and state.active.name or 'nil' end))
          :add(UI.Label('Scroll Focus'))
          :add(UI.Label():setMinWidth(160):setPollFn(function ()
            return state.scrollFocus and state.scrollFocus.name or 'nil' end))
          :add(UI.Label('Scroll Active'))
          :add(UI.Label():setMinWidth(160):setPollFn(function ()
            return state.scrollActive and state.scrollActive.name or 'nil' end))
          :add(UI.Label('Nav Focus'))
          :add(UI.Label():setMinWidth(160):setPollFn(function ()
            return state.navFocus and state.navFocus.name or 'nil' end))
          :add(UI.Label('Panel Focus'))
          :add(UI.Label():setMinWidth(160):setPollFn(function ()
            return state.panelFocus and state.panelFocus.name or 'nil' end))
          :add(UI.Label('Show Layout'))
          :add(UI.Checkbox(
            function () return canvas.drawDebug end,
            function (enabled) canvas.drawDebug = enabled end))
          :add(UI.Label('Show Focus'))
          :add(UI.Checkbox(
            function () return canvas.drawFocus end,
            function (enabled) canvas.drawFocus = enabled end))
          :add(UI.Label('Mouse Position'))
          :add(UI.Label():setPollFn(function () return (Vec2i(state.mousePosX, state.mousePosY)) end))
          --:add(UI.Label('Active Device'))
          --:add(UI.Label():setPollFn(function () local d = ffi.new('Device') Input.GetActiveDevice(d) return d end))
          :add(UI.Label('Active Device Type'))
          :add(UI.Label():setPollFn(Input.GetActiveDeviceType))
          :add(UI.Label('Active Device ID'))
          :add(UI.Label():setPollFn(Input.GetActiveDeviceID))
        )
      )
    )
end

function DebugWindow:createSettingsSections ()
  local vars = Settings.getAll()
  for i = 1, #vars do
    local var = vars[i]
    local keys = var.key:split('%.')
    local section = self:getSection(keys[1])
    if var.type == 'float' then
      section
        :add(UI.Label(var.name))
        :add(UI.Slider(var.getter, var.setter, var.min, var.max))
    elseif var.type == 'bool' then
      section
        :add(UI.Label(var.name))
        :add(UI.Checkbox(var.getter, var.setter))
    elseif var.type == 'enum' then
      section
        :add(UI.Label(var.name))
        :add(UI.OptionSlider(var.getter, var.setter, var.elems, var.value))
    end
  end
end

function DebugWindow:getSection (name)
  local section = self.sections[name]
  if section then return section end
  section = UI.Grid():setPadCellX(8):setPad(2, 0, 2, 2)
  self.contents
    :add(UI.NavGroup()
      :add(UI.Collapsible(name)
        :add(UI.Grid():setCols(1)
          :add(section)
        )
      )
    )
  self.sections[name] = section
  section.childMap = {}
  return section
end

-- TODO JP : Temporary hack to avoid Debug wrapper
local instance

function DebugWindow.SetValue (section, name, value)
  local self = instance
  local s = self:getSection(section)
  local w = s.childMap[name]
  if not w then
    w = UI.Label():setMinWidth(60)
    s:add(UI.Label(name))
    s:add(w)
    s.childMap[name] = w
  end

  w:setText(value)
end

function DebugWindow.Create (ltheory)
  local self
  self = UI.Window('Debug')
  self = setmetatable(self, DebugWindow)

  self.ltheory  = ltheory
  self.timer    = Timer.Create()
  self.drawTime = 0
  self.sections = {}

  self.contents = UI.Grid()
    :setCols(1)
    :setStretchY(0)
    :add(self:createProfilingText())
    :add(self:createProfilingGraphs())
    :add(self:createAudioSection())
    :add(self:createUISection())

  self:createSettingsSections()

  if Config.debug.windowSection then
    for i = 1, #self.contents.children do
      local child = self.contents.children[i]
      child.expanded = (child.title == Config.debug.windowSection)
    end
  end

  self.draggable = false
  self
    :setStretchY(1)
    :add(UI.ScrollView()
      :setPadUniform(2)
      :setScrollable(false, true)
      :add(self.contents))

  instance = self
  return self
end

return DebugWindow
