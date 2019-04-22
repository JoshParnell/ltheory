local GameView = {}
GameView.__index  = GameView
setmetatable(GameView, UI.Container)

GameView.name = 'Game View'

local ssTable = { 1, 2, 4 }

function GameView:draw (focus, active)
  self.camera:push()

  local ss = ssTable[Settings.get('render.superSample')]
  local x, y, sx, sy = self:getRectGlobal()
  ClipRect.PushDisabled()
  RenderState.PushAllDefaults()
  self.camera:setViewport(x, y, sx, sy)
  self.camera:beginDraw()

  local world = self.player:getRoot()
  local eye = self.camera.pos
  world:beginRender()

  do -- Opaque Pass
    Profiler.Begin('Render.Opaque')
    self.renderer:start(self.sx, self.sy, ss)
    world:render(Event.Render(BlendMode.Disabled, eye))
    self.renderer:stop()
    Profiler.End()
  end

  do -- Lighting
    -- Gather light sources
    local lights = {}
    for i, v in world:iterChildren() do
      if v:hasLight() then
        insert(lights, { pos = v:getPos(), color = v:getLight() })
      end
    end

    do -- Global lighting (environment)
      self.renderer.buffer2:push()
      Draw.Clear(0, 0, 0, 0)
      local shader = Cache.Shader('worldray', 'light/global')
      shader:start()
      Shader.SetTex2D('texDepth', self.renderer.zBufferL)
      Shader.SetTex2D('texNormalMat', self.renderer.buffer1)
      Draw.Rect(-1, -1, 2, 2)
      shader:stop()
      self.renderer.buffer2:pop()
    end

    do -- Local lighting
      self.renderer.buffer2:push()
      BlendMode.PushAdditive()
      local shader = Cache.Shader('worldray', 'light/point')
      shader:start()
      for i, v in ipairs(lights) do
        -- TODO : Batching
        Shader.SetFloat3('lightColor', v.color.x, v.color.y, v.color.z)
        Shader.SetFloat3('lightPos', v.pos.x, v.pos.y + 5, v.pos.z)
        Shader.SetTex2D('texDepth', self.renderer.zBufferL)
        Shader.SetTex2D('texNormalMat', self.renderer.buffer1)
        Draw.Rect(-1, -1, 2, 2)
      end
      shader:stop()
      BlendMode.Pop()
      self.renderer.buffer2:pop()
    end

    do -- Composite albedo & accumulated light buffer
      self.renderer.buffer1:push()
      local shader = Cache.Shader('worldray', 'light/composite')
      shader:start()
      Shader.SetTex2D('texAlbedo', self.renderer.buffer0)
      Shader.SetTex2D('texDepth', self.renderer.zBufferL)
      Shader.SetTex2D('texLighting', self.renderer.buffer2)
      Draw.Rect(-1, -1, 2, 2)
      shader:stop()
      self.renderer.buffer1:pop()
    end

    self.renderer.buffer0, self.renderer.buffer1 = self.renderer.buffer1, self.renderer.buffer0
  end

  if true then -- Alpha (Additive) Pass
    self.renderer:startAlpha(BlendMode.Additive)
      world:render(Event.Render(BlendMode.Additive, eye))
    self.renderer:stopAlpha()
  end

  if true then -- Alpha Pass
    self.renderer:startAlpha(BlendMode.Alpha)
      world:render(Event.Render(BlendMode.Alpha, eye))

      -- TODO : This should be moved into a render pass
      if Config.debug.physics.drawBoundingBoxesLocal or
         Config.debug.physics.drawBoundingBoxesWorld or
         Config.debug.physics.drawWireframes or
         Config.debug.physics.drawTriggers
      then
        local mat = Material.DebugColorA()
        mat:start()
        if Config.debug.physics.drawBoundingBoxesLocal then
          Shader.SetFloat4('color', 0, 0, 1, 0.5)
          world.physics:drawBoundingBoxesLocal()
        end
        if Config.debug.physics.drawBoundingBoxesWorld then
          Shader.SetMatrix ('mWorld',   Matrix.Identity())
          Shader.SetMatrixT('mWorldIT', Matrix.Identity())
          Shader.SetFloat('scale', 1)
          Shader.SetFloat4('color', 1, 0, 0, 0.5)
          world.physics:drawBoundingBoxesWorld()
        end
        if Config.debug.physics.drawTriggers then
          Shader.SetMatrix ('mWorld',   Matrix.Identity())
          Shader.SetMatrixT('mWorldIT', Matrix.Identity())
          Shader.SetFloat('scale', 1)
          Shader.SetFloat4('color', 1, 0.5, 0, 0.5)
          world.physics:drawTriggers()
        end
        if Config.debug.physics.drawWireframes then
          Shader.SetMatrix ('mWorld',   Matrix.Identity())
          Shader.SetMatrixT('mWorldIT', Matrix.Identity())
          Shader.SetFloat('scale', 1)
          Shader.SetFloat4('color', 0, 1, 0, 0.5)
          world.physics:drawWireframes()
        end
        mat:stop()
      end
    self.renderer:stopAlpha()
  end

  world:endRender()
  self.camera:endDraw()

  if true then -- Composited UI Pass
    self.renderer:startUI()
      Viewport.Push(0, 0, ss * self.sx, ss * self.sy, true)
      ClipRect.PushTransform(0, 0, ss, ss)
        GLMatrix.ModeWV()
        GLMatrix.Push()
        GLMatrix.Scale(ss, ss, 1.0)
          for i = 1, #self.children do self.children[i]:draw(focus, active) end
        GLMatrix.ModeWV()
        GLMatrix.Pop()
      ClipRect.PopTransform()
      Viewport.Pop()
    self.renderer:stopUI()
  end

  if false or Settings.get('render.showBuffers') then
    self.renderer:presentAll(x, y, sx, sy)
  else
    self.renderer:startPostEffects()
    if Settings.get('postfx.bloom.enable') then self.renderer:bloom(Settings.get('postfx.bloom.radius')) end
    if Settings.get('postfx.tonemap.enable') then self.renderer:tonemap() end
    if Settings.get('postfx.aberration.enable') then
      self.renderer:applyFilter('aberration', function ()
        Shader.SetFloat('strength', Settings.get('postfx.aberration.strength'))
      end)
    end
    if Settings.get('postfx.radialblur.enable') then
      self.renderer:applyFilter('radialblur', function ()
        Shader.SetFloat('strength', Settings.get('postfx.radialblur.strength'))
      end)
    end
    if Settings.get('postfx.sharpen.enable') then
      self.renderer:sharpen(2, 1, 1)
    end
    self.renderer:present(x, y, sx, sy, ss > 2)
  end

  if GUI.DrawHmGui then
    GUI.DrawHmGui(self.sx, self.sy)
  end

  RenderState.PopAll()
  ClipRect.Pop()
  self.camera:pop()
end

function GameView:onInputChildren (state)
  self.camera:push()
  for i = 1, #self.children do
    local child = self.children[i]
    if not child.removed then child:input(state) end
  end
  self.camera:pop()
end

function GameView:onUpdate (state)
  --[[ TODO : This may be one frame delayed since onUpdateChildren happens later
              and one of them is responsible for updating the camera position.
              Further reason to invert the current Camera-Control relationship. ]]
  self.camera:onUpdate(state.dt)

  do -- Compute Eye Velocity EMA
    local eye = self.camera.pos
    local v = (eye - self.eyeLast):scale(1.0 / max(1e-10, state.dt))
    self.eyeVel:setv(self.player:getControlling():getVelocity())
    self.eyeLast:setv(eye)
  end

  Audio.SetListenerPos(
    self.camera.pos,
    self.eyeVel,
    self.camera.rot:getForward(),
    self.camera.rot:getUp())
  Audio.Update()

  self.camera:pop()
end

function GameView:onUpdateChildren (state)
  self.camera:push()
  for i = 1, #self.children do
    local child = self.children[i]
    if not child.removed then child:update(state) end
  end
  self.camera:pop()
end

function GameView:onLayoutSizeChildren ()
  self.camera:push()
  for i = 1, #self.children do self.children[i]:layoutSize() end
  self.camera:pop()
end

function GameView:setOrbit (orbit)
  local lastCamera = self.camera

  self.orbit = orbit
  self.camera = self.orbit and self.cameraOrbit or self.cameraChase
  self.camera:setTarget(self.player:getControlling())

  -- NOTE : We're assuming that no one else could have pushed a camera
  local camera = Camera.get()
  if camera and camera == lastCamera then
    lastCamera:pop()
    self.camera:push()
  end
end

function GameView.Create (player)
  -- TODO : Should Audio be handled in App/LTheory??
  Audio.Init()
  Audio.Set3DSettings(0.0, 10, 2);

  local self = setmetatable({
    player      = player,
    renderer    = Renderer(),
    cameraChase = CameraChase(),
    cameraOrbit = CameraOrbit(),
    camera      = nil,
    eyeLast     = nil,
    eyeVel      = nil,
    children    = List(),
  }, GameView)

  self:setOrbit(false)
  self.eyeLast = self.camera.pos:clone()
  self.eyeVel  = self.player:getControlling():getVelocity():clone()
  return self
end

return GameView
