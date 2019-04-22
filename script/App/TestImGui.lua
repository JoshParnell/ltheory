local Test = Application()
local rng = RNG.FromTime()

local useRenderer = true

function Test:onInit ()
  self.bg = Tex2D.Load('./screenshot/wp2.png')
  self.showInventory = false
  self.todo = {
    { desc = "autosizing", value = true },
    { desc = "text", value = true },
    { desc = "buttons", value = true },
    { desc = "checkboxes", value = true },
    { desc = "style vars", value = true },
    { desc = "icons", value = false },
    { desc = "batched glyph render", value = false },
    { desc = "layering", value = true },
    { desc = "radio groups", value = false },
    { desc = "draggable windows", value = true },
    { desc = "persistent storage", value = true },
    { desc = "scrollbars", value = true },
    { desc = "scrollbars: focus clipping", value = true },
    { desc = "selectable", value = true },
    { desc = "tooltips", value = false },
    { desc = "textfields", value = false },
    { desc = "navigation : keyboard", value = false },
    { desc = "navigation : gamepad", value = false },
    { desc = "cache invalidation", value = false },
  }

  self.renderer = Renderer()
end

function Test:onInput ()
end

local time = 0

function Test:showTodo ()
  ImGui.BeginWindow("PhxImGui Todo List", 256, 400)
    ImGui.SetFont(Cache.Font("Shentox", 14))
    ImGui.PushStyleFont(Cache.Font("Shentox", 20))
    ImGui.TextColored("PHXImGui > Todo List", 0.5, 0.7, 1.0, 0.2)
    ImGui.PopStyle()
    ImGui.BeginGroupX(0)
    for i = 1, 1 do
      ImGui.BeginScrollFrame(0, 0)
        ImGui.SetSpacing(8, 0)
        for i = 1, #self.todo do
          local elem = self.todo[i]
          ImGui.BeginGroupX(24)
            elem.value = ImGui.Checkbox(elem.value)
            ImGui.Text(elem.desc)
          ImGui.EndGroup()
        end
      ImGui.EndScrollFrame()
    end
    ImGui.EndGroup()
  ImGui.EndWindow()
end

local list1 = {
  'Fighter',
  'Corvette',
  'Frigate',
  'Destroyer',
  'Cruiser',
  'Battlecruiser',
  'Battleship',
  'Carrier',
  'Leviathan',
}

local toggle = false
function Test:showBar ()
  ImGui.SetCursor(0, 0)
  ImGui.BeginPanel(0, 64)
    ImGui.BeginGroupX(0)
      ImGui.PushStyleFont(Cache.Font('ShentoxMedium', 30))
      ImGui.TextColored(" >> ", 0.1, 0.5, 1.0, 1.0)
      ImGui.PopStyle()
      ImGui.ButtonEx("ASSETS", 96, 0)
      ImGui.Divider()
      ImGui.ButtonEx("SYSTEM", 96, 0)
      ImGui.ButtonEx("CARGO", 96, 0)
      ImGui.ButtonEx("SUBSYS", 96, 0)
    ImGui.EndGroup()
  ImGui.EndPanel()
end

function Test:showScrollWindow ()
  ImGui.BeginWindow('Yes!', 800, 320)
    ImGui.SetFont(Cache.Font("Shentox", 17))
    ImGui.PushStyleFont(Cache.Font("Shentox", 30))
    ImGui.TextColored("Market", 0.5, 0.7, 1.0, 0.2)
    ImGui.PopStyle()
    ImGui.BeginGroupX(0)
      ImGui.BeginScrollFrame(196, 0)
        ImGui.TextColored("SHIPS", 0.1, 0.5, 1.0, 1.0)
          ImGui.Indent()
          for _, v in ipairs(list1) do
            if ImGui.Selectable(v) then printf(v) end
          end
          ImGui.Undent()

        ImGui.TextColored("SUBSYSTEMS", 0.1, 0.5, 1.0, 1.0)
          ImGui.Indent()
          ImGui.Selectable("Beam Turrets")
          ImGui.Indent()
          ImGui.Selectable("Drone Launchers")
          ImGui.Undent()
          ImGui.Selectable("Missile Launchers")
          ImGui.Selectable("Pulse Turrets")
          ImGui.Selectable("Rail Turrets")
          ImGui.Undent()

      ImGui.EndScrollFrame()

      ImGui.BeginScrollFrame(-200, 0)
        ImGui.SetSpacing(0, 8)
        for i = 1, 20 do
          ImGui.ButtonEx(format("Text Line %d!", i), -8, 60)
        end
        ImGui.BeginScrollFrame(200, 300)
        for i = 1, 10 do
          ImGui.Selectable(format("Text Line %d!", i))
        end
        ImGui.EndScrollFrame()
      ImGui.EndScrollFrame()
      ImGui.BeginGroupY(0)
        ImGui.SetFont(Cache.Font("Iceland", 16))
        ImGui.Text("price : 13")
        ImGui.Text(" mass : 1")
      ImGui.EndGroup()
    ImGui.EndGroup()
  ImGui.EndWindow()
end

local group = 1
function Test:showUniverseMenu ()
  ImGui.BeginPanel(640, 480)
    ImGui.SetFont(Cache.Font("Shentox", 17))
    ImGui.BeginGroupX(48)
      if ImGui.Selectable("General") then group = 1 end
      if ImGui.Selectable("Star Distribution") then group = 2 end
      if ImGui.Selectable("Resources") then group = 3 end
      if ImGui.Selectable("AI Players") then group = 4 end
    ImGui.EndGroup()
    ImGui.Divider()
    ImGui.BeginScrollFrame(0, -64)
    if group == 1 then
      ImGui.Text("General Stuff 1")
      ImGui.Text("General Stuff 2")
      ImGui.Text("General Stuff 3")
    elseif group == 2 then
      ImGui.Checkbox(true)
      ImGui.Checkbox(false)
    end
    ImGui.EndScrollFrame()
    ImGui.BeginGroupX(0)
      ImGui.ButtonEx("Create", -128, 0)
      ImGui.ButtonEx("Cancel", 0, 0)
    ImGui.EndGroup()
  ImGui.EndPanel()
end

function Test:onUpdate (dt)
  time = time + dt

  ImGui.Begin(self.resX, self.resY)
    if self.bg then ImGui.Tex2D(self.bg) end
    ImGui.SetCursor(0, 0)
    -- self:simple()
    self:showBar()
    self:showUniverseMenu()
    self:showScrollWindow()
    self:showTodo()
    -- ImGui.SetCursor(129, 129)
    -- self:window2()
    -- ImGui.SetCursor(64, 64)
    -- self:window1()
  ImGui.End()
end

function Test:onDraw ()
  if useRenderer then
    self.renderer:start(self.resX, self.resY)
    self.renderer:stop()
    self.renderer:startUI()
    Viewport.Push(0, 0, self.resX, self.resY, true)
    ImGui.Draw()
    Viewport.Pop()
    self.renderer:stopUI()
    self.renderer:present(0, 0, self.resX, self.resY)
  else
    ImGui.Draw()
  end
end

return Test
