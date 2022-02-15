local Test = Application()
local rng = RNG.FromTime()

local useRenderer = true

local todo = {
  {
    name = "Basic Widgets",
    elems = {
      { "Text", true },
      { "Buttons", true },
      { "Checkboxes", true },
      { "Sliders", false },
      { "Radio Groups", false },
      { "Selectable", false },
      { "Tooltips", false },
    },
  },

  {
    name = "Layout",
    elems = {
      { "Deferred Layout Pass", true },
      { "Horizontal Groups", true },
      { "Vertical Groups", true },
      { "Stacked Groups", true },
      { "Group Padding", true },
      { "Group Margins", false },
      { "Child Spacing ", true },
      { "ScrollViews", true },
      { "Windows", true },
    },
  },

  {
    name = "Input",
    elems = {
      { "Clip Groups", true },
      { "Input Clipping", true },
      { "Sticky Drag", false },
      { "Keyboard Navigation", false },
      { "Gamepad Navigation", false },
    },
  },

  {
    name = "Draw",
    elems = {
      { "Draw Layers", true },
      { "Shader-Based Render", true },
      { "Glyph Render", false },
    },
  },

  {
    name = "Technical",
    elems = {
      { "Hash Storage", true },
      { "Hash Storage Invalidation", false },
      { "Deferred Metrics", true },
    },
  },
}

function Test:onInit ()
  -- self.bg = Tex2D.Load('./screenshot/wp2.png')
  self.renderer = Renderer()
end

function Test:onInput () end

local code = [[
static void MemPool_Grow (MemPool* self) {
  uint16 newBlockIndex = self->blockCount++;
  self->capacity += self->blockSize;

  /* Grow the list of pool blocks. */
  self->blocks = (void**)MemRealloc(self->blocks, self->blockCount * sizeof(void*));

  /* Allocate a new block and place at the back of the list. */
  void* newBlock = MemAlloc(self->cellSize * self->blockSize);
  self->blocks[newBlockIndex] = newBlock;

  /* Wire up the free list for this block. Note that we can assume the existing
   * free list is empty if the pool is requesting to grow, hence we overwrite
   * the existing list head. The block's initial freelist is wired sequentially
   * ( 0 -> 1 -> 2 ) for optimal cache locality. */
  void** prev = &self->freeList;
  char* pCurr = (char*)newBlock;
  for (uint32 i = 0; i < self->blockSize; ++i) {
    *prev = (void*)pCurr;
    prev = (void**)pCurr;
    pCurr += self->cellSize;
  }
  *prev = 0;
}
]]

function Test:showSimple ()
  HmGui.BeginWindow('HmGui Test')
    HmGui.BeginGroupX()
      HmGui.Button(" < ") HmGui.SetStretch(0, 1)
      HmGui.Button("Tab1")
      HmGui.Button("Tab2")
      HmGui.Button("Tab3")
      HmGui.Button(" > ") HmGui.SetStretch(0, 1)
    HmGui.EndGroup()
    HmGui.SetStretch(1, 1)

    HmGui.BeginGroupX()
      HmGui.BeginGroupY()
        HmGui.SetPadding(4, 4)
        HmGui.Text("Welcome to...")
        HmGui.SetAlign(0.5, 0.5)

        HmGui.PushTextColor(1.0, 0.0, 0.3, 1.0)
        HmGui.PushFont(Cache.Font("Exo2Bold", 30))
        HmGui.Text("~ Hybrid Mode ~")
        HmGui.PopStyle(2)
        HmGui.SetAlign(0.5, 0.5)

        HmGui.Text("GUI!")
        HmGui.SetAlign(0.5, 0.5)
        HmGui.Button("Not-So-Stretchy")
        HmGui.SetStretch(1, 0)
        HmGui.Button("Stretchy")
        HmGui.SetStretch(1, 1)

        HmGui.BeginGroupX()
        for i = 1, 3 do
          HmGui.BeginGroupY()
          for j = 1, 3 do
            HmGui.Button(":)")
          end
          HmGui.EndGroup()
          HmGui.SetStretch(1, 1)
        end
        HmGui.EndGroup()
        HmGui.SetStretch(1, 1)
      HmGui.EndGroup()
      HmGui.SetAlign(0, 0.0)
      HmGui.SetStretch(1, 1)

      HmGui.BeginGroupY()
        HmGui.SetPadding(4, 4)
        if HmGui.Button("-- OPT 1 --") then print("Opt 1!") end
        HmGui.Button("-- OPT 2 --")
        HmGui.Checkbox("Yas", true)
        HmGui.Checkbox("Nope", false)
        HmGui.Checkbox("Possibly?", false)
        HmGui.Button("DONE")
      HmGui.EndGroup()
      HmGui.SetAlign(0, 1.0)
      HmGui.SetStretch(1, 1)

      HmGui.BeginGroupY()
        HmGui.SetPadding(4, 4)
        for i = 1, 9 do
          HmGui.BeginGroupX()
            for j = 1, i do
              HmGui.Button(format("%d.%d", i, j))
            end
          HmGui.EndGroup()
          HmGui.SetAlign(0.5, 0.5)
        end
      HmGui.EndGroup()
      self:showTodoInner()
    HmGui.EndGroup()
    HmGui.SetStretch(1, 0)

    HmGui.Text("Behold, the codez! \\o/")
    HmGui.BeginGroupX()
      for i = 1, 2 do
        HmGui.BeginScroll(200)
          HmGui.PushTextColor(0.1, 0.5, 1.0, 1.0)
          HmGui.PushFont(Cache.Font('OperatorMono', 10))
          local lines = code:split('\n')
          for _, line in ipairs(lines) do
            HmGui.Text(line)
          end
          HmGui.PopStyle(2)
        HmGui.EndScroll()
      end
    HmGui.EndGroup()
  HmGui.EndWindow()
  HmGui.SetAlign(0.5, 0.5)
end

function Test:showTodoInner ()
  HmGui.BeginScroll(256)
  HmGui.SetSpacing(8)
    for _, group in ipairs(todo) do
      HmGui.TextEx(Cache.Font('Rajdhani', 18), group.name, 1, 1, 1, 1)
      HmGui.BeginGroupY()
        HmGui.SetSpacing(2)
        HmGui.SetPaddingLeft(12)
        for _, v in ipairs(group.elems) do
          v[2] = HmGui.Checkbox(v[1], v[2])
        end
      HmGui.EndGroup()
    end
  HmGui.EndScroll()
end

function Test:showTodo ()
  HmGui.BeginWindow("HmGui Todo List")
    HmGui.TextEx(Cache.Font('Iceland', 20), 'HmGui Todo List', 0.3, 0.4, 0.5, 0.5)
    HmGui.SetAlign(0.5, 0.5)
    self:showTodoInner()
  HmGui.EndWindow()
  HmGui.SetAlign(0.5, 0.5)
end

function Test:showMetrics ()
  HmGui.BeginWindow("Metrics")
    HmGui.Text(format("fps: %.2f", 1.0 / self.dt))
  HmGui.EndWindow()
end

function Test:onUpdate (dt)
  Profiler.Begin('HmGui.Update')
  HmGui.Begin(self.resX, self.resY)
    -- HmGui.Image(self.bg)
    self:showSimple()
    -- self:showMetrics()
    self:showTodo()
  HmGui.End()
  Profiler.End()
end

function Test:onDraw ()
  if useRenderer then
    self.renderer:start(self.resX, self.resY)
    self.renderer:stop()
    self.renderer:startUI()
    Viewport.Push(0, 0, self.resX, self.resY, true)
    HmGui.Draw()
    Viewport.Pop()
    self.renderer:stopUI()
    self.renderer:present(0, 0, self.resX, self.resY)
  else
    HmGui.Draw()
  end
end

return Test
