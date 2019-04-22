local Bindings = ApplicationBindings

local FMODTest = Application()

local SFX = {
  Gun  = 'blaster',
  Hero = 'chewy',
}

local kMoveSpeed = 100.0

function FMODTest:getTitle ()
  return 'FMOD Test'
end

function FMODTest:onInit ()
  Audio.Init()
  Audio.Set3DSettings(1, 10, 2);

  self.emitters = {
    { file = 'cantina', image = 'image/cantinaband', x = 128, y = 100 },
    { file = 'Imperial_March', image = 'image/vader', x = 256, y = 600 },
  }

  self.ambiances = {
    '900years',
    'breath',
    'chewy',
    'chosenone',
    'comeback',
    'dont',
    'jabbalaugh',
    'jedi',
    'nerfherder',
    'thybidding',
    'traintheboy',
    'yesmaster',
    'yodalaugh',
  }

  self.rng = RNG.FromTime()

  do -- Start async preload of effects
    for k, v in pairs(SFX) do
      Sound.LoadAsync(v, false, true)
    end
  end

  Sound.Load('cantina', true, true)

  for i = 1, #self.emitters do
    local e = self.emitters[i]
    e.tex = Tex2D.Load(e.image)
    e.tex:genMipmap()
    e.tex:setMagFilter(TexFilter.Linear)
    e.tex:setMinFilter(TexFilter.LinearMipLinear)

    e.sound = Sound.Load(e.file, true, true)
    e.sound:set3DPos(Vec3f(e.x, 0, e.y), Vec3f(0, 0, 0))
    --e.sound:setPlayPos(e.sound:getDuration() - 10*i)
    e.sound:play()
  end

  self.lastFireTime = 0
  self.pos = Vec3f(256, 0, 256)
  self.vel = Vec3f(0, 0, 0)
  self.ambianceTimer = 1.0 + self.rng:getExp()
  self.particles = {}

  self.onKeyDown = {
    [Key.S] = function () self.vel.z = self.vel.z + kMoveSpeed * self.dt end,
    [Key.W] = function () self.vel.z = self.vel.z - kMoveSpeed * self.dt end,
    [Key.D] = function () self.vel.x = self.vel.x + kMoveSpeed * self.dt end,
    [Key.A] = function () self.vel.x = self.vel.x - kMoveSpeed * self.dt end,
  }

  self.onKeyPress = {
    [Key.N1]    = function () Audio.Prepare(Audio.Load(SFX.Gun, true), true, false):play() end,
    [Key.N2]    = function () Audio.Prepare(Audio.Load(SFX.Hero, true), false, false):play() end,
    [Key.Left]  = function () self.pos = Vec3f( 10,  0,   0) end,
    [Key.Right] = function () self.pos = Vec3f(-10,  0,   0) end,
    [Key.Up]    = function () self.pos = Vec3f(  0,  0, -10) end,
    [Key.Down]  = function () self.pos = Vec3f(  0,  0,  10) end,
    [Key.Space] = function () self.pos = Vec3f(  0,  2,   0) end,
  }
end

function FMODTest:onInput ()
  if Input.GetPressed(Bindings.Exit) then
    self:quit()
  end

  if Input.GetDown(Button.Mouse.Left) then
    if TimeStamp.GetElapsed(self.lastFireTime) > 0.12 then
      self.lastFireTime = self.lastUpdate
      local sound = Sound.Load(SFX.Gun, false, true)
      sound:setFreeOnFinish(true)
      sound:set3DPos(Vec3f(0, 0, 0), Vec3f(0, 0, 0))
      sound:setVolume(Math.Lerp(0.2, 0.6, self.rng:getUniform() ^ 2.0))
      sound:play()
    end
  end

  if Input.GetDown(Button.Mouse.Right) then
    local is = Input.GetState()
    self.pos.x = is.mousePosition.x
    self.pos.z = is.mousePosition.y
  end

  for k, v in pairs(self.onKeyDown) do
    if Input.GetDown(k) then v() end
  end

  for k, v in pairs(self.onKeyPress) do
    if Input.GetPressed(k) then v() end
  end
end

function FMODTest:onDraw ()
  BlendMode.PushAlpha()
  Draw.Clear(0.1, 0.1, 0.1, 1.0)
  for i = 1, #self.emitters do
    Draw.Color(1, 1, 1, 1)
    local e = self.emitters[i]
    local sz = e.tex:getSize()
    e.tex:draw(e.x - 96, e.y - 96, 192, 192)
    local d = Vec3f(e.x, 0, e.y):distance(self.pos)
    local c = Vec3f():lerp(Vec3f(1.0, 0.0, 0.2), exp(-max(0, d / 128 - 1.0)))
    Draw.Color(c.x, c.y, c.z, 1)
    Draw.Border(8, e.x - 96, e.y - 96, 192, 192)
  end

  Draw.PointSize(2.0)
  Draw.SmoothPoints(true)
  for i = 1, #self.particles do
    local p = self.particles[i]
    local alpha = p.life / 5
    Draw.Color(0.25, 1.0, 0.25, alpha * 0.8)
    Draw.Point(p.x, p.y)
  end

  Draw.Color(0.1, 0.6, 1.0, 1.0)
  Draw.Rect(self.pos.x - 4, self.pos.z - 4, 8, 8)
  BlendMode.Pop()
end

function FMODTest:onUpdate (dt)
  self.pos = self.pos + self.vel:scale(dt)
  self.vel:iscale(exp(-dt))

  do -- Play 'ambient' sound effects in a cloud around the listener
    -- WARNING : May cause extreme annoyance, nightmares, and/or euphoria.
    --           Josh hereby absolves himself of all responsibility.
    self.ambianceTimer = self.ambianceTimer - dt
    if self.ambianceTimer <= 0 then
      self.ambianceTimer = self.ambianceTimer + 0.25 * self.rng:getExp()
      local sound = Sound.Load(self.rng:choose(self.ambiances), false, true)
      local dp = self.rng:getDir2():scale(100.0 * (1.0 + self.rng:getExp()))
      sound:setFreeOnFinish(true)
      sound:setPitch(Math.Clamp(1.0 + 0.1 * self.rng:getGaussian(), 0.6, 1.0 / 0.6))
      sound:set3DPos(self.pos + Vec3f(dp.x, 0, dp.y), Vec3f(0, 0, 0))
      sound:setVolume(0.5 + 0.5 * self.rng:getExp())
      sound:play()
      self.particles[#self.particles + 1] = { life = 5, x = self.pos.x + dp.x, y = self.pos.z + dp.y }
    end
  end

  do -- Particle update
    local i = 1
    while i <= #self.particles do
      local p = self.particles[i]
      p.life = p.life - dt
      if p.life < 0 then
        self.particles[i] = self.particles[#self.particles]
        self.particles[#self.particles] = nil
      else i = i + 1 end
    end
  end

  Audio.SetListenerPos(self.pos, self.vel, Vec3f(0, 0, -1), Vec3f(0, 1, 0))
  Audio.Update()

--[[
  for i = 1, #self.emitters do
    local s = self.emitters[i].sound
    --printf("%20s\t%.2f\t%s\t%s", tostring(s:getName()), s:getDuration(), s:isPlaying(), s:isFinished())
    printf("%20s\t%.2f\t%s", tostring(s:getName()), s:getDuration(), s:isFinished())
  end
--]]
end

function FMODTest:onExit ()
  Audio.Free()
end

return FMODTest

-- TODO : Push Audio handling from LTheory up into Appliction?
-- TODO : Where is CoInitialize being called? I don't see a warning from FMOD
-- TODO : Pool of sounds with pitch variation
