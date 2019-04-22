local CoordTest = Application()

local r2 = sqrt(2)/2
local bases = {
  -- Positive rotation is always right when looking down the positive direction of the axis (from the origin)

  -- NOTE : Euler angles are wrong. They were written before math was fixed.

  -- Rotate Around X (y chases z)
  { z = Vec3f(0,  0,  1),   y = Vec3f(0,  1,  0),   x = Vec3f(1, 0, 0),         --[[ ex =   0, ]] axis = Vec3f(1, 0, 0) },
  { z = Vec3f(0, -1,  0),   y = Vec3f(0,  0,  1),   x = Vec3f(1, 0, 0),         --[[ ex =  90, ]] axis = Vec3f(1, 0, 0) },
  { z = Vec3f(0,  0, -1),   y = Vec3f(0, -1,  0),   x = Vec3f(1, 0, 0),         --[[ ex = 180, ]] axis = Vec3f(1, 0, 0) },
  { z = Vec3f(0,  1,  0),   y = Vec3f(0,  0, -1),   x = Vec3f(1, 0, 0),         --[[ ex = 270, ]] axis = Vec3f(1, 0, 0) },

  { z = Vec3f(0, -r2,  r2), y = Vec3f(0,  r2,  r2), x = Vec3f(1, 0, 0),         --[[ ex =  45, ]] axis = Vec3f(1, 0, 0) },
  { z = Vec3f(0, -r2, -r2), y = Vec3f(0, -r2,  r2), x = Vec3f(1, 0, 0),         --[[ ex = 135, ]] axis = Vec3f(1, 0, 0) },
  { z = Vec3f(0,  r2, -r2), y = Vec3f(0, -r2, -r2), x = Vec3f(1, 0, 0),         --[[ ex = 225, ]] axis = Vec3f(1, 0, 0) },
  { z = Vec3f(0,  r2,  r2), y = Vec3f(0,  r2, -r2), x = Vec3f(1, 0, 0),         --[[ ex = 315, ]] axis = Vec3f(1, 0, 0) },


  -- Rotate Around Y (z chases x)
  { z = Vec3f( 0, 0,  1),   x = Vec3f( 1, 0,  0),   y = Vec3f(0, 1, 0),         --[[ ey =   0, ]] axis = Vec3f(0, 1, 0) },
  { z = Vec3f(-1, 0,  0),   x = Vec3f( 0, 0,  1),   y = Vec3f(0, 1, 0),         --[[ ey =  90, ]] axis = Vec3f(0, 1, 0) },
  { z = Vec3f( 0, 0, -1),   x = Vec3f(-1, 0,  0),   y = Vec3f(0, 1, 0),         --[[ ey = 180, ]] axis = Vec3f(0, 1, 0) },
  { z = Vec3f( 1, 0,  0),   x = Vec3f( 0, 0, -1),   y = Vec3f(0, 1, 0),         --[[ ey = 270, ]] axis = Vec3f(0, 1, 0) },

  { z = Vec3f(-r2, 0,  r2), x = Vec3f( r2, 0,  r2), y = Vec3f(0, 1, 0),         --[[ ey =  45, ]] axis = Vec3f(0, 1, 0) },
  { z = Vec3f(-r2, 0, -r2), x = Vec3f(-r2, 0,  r2), y = Vec3f(0, 1, 0),         --[[ ey = 135, ]] axis = Vec3f(0, 1, 0) },
  { z = Vec3f( r2, 0, -r2), x = Vec3f(-r2, 0, -r2), y = Vec3f(0, 1, 0),         --[[ ey = 225, ]] axis = Vec3f(0, 1, 0) },
  { z = Vec3f( r2, 0,  r2), x = Vec3f( r2, 0, -r2), y = Vec3f(0, 1, 0),         --[[ ey = 315, ]] axis = Vec3f(0, 1, 0) },


  -- Rotate Around Z (x chases y)
  { y = Vec3f( 0,  1, 0),   x = Vec3f( 1,  0, 0),   z = Vec3f(0, 0, 1),         --[[ ez =   0, ]] axis = Vec3f(0, 0, 1) },
  { y = Vec3f(-1,  0, 0),   x = Vec3f( 0,  1, 0),   z = Vec3f(0, 0, 1),         --[[ ez =  90, ]] axis = Vec3f(0, 0, 1) },
  { y = Vec3f( 0, -1, 0),   x = Vec3f(-1,  0, 0),   z = Vec3f(0, 0, 1),         --[[ ez = 180, ]] axis = Vec3f(0, 0, 1) },
  { y = Vec3f( 1,  0, 0),   x = Vec3f( 0, -1, 0),   z = Vec3f(0, 0, 1),         --[[ ez = 270, ]] axis = Vec3f(0, 0, 1) },

  { y = Vec3f(-r2,  r2, 0), x = Vec3f( r2,  r2, 0), z = Vec3f(0, 0, 1),         --[[ ez =  45, ]] axis = Vec3f(0, 0, 1) },
  { y = Vec3f(-r2, -r2, 0), x = Vec3f(-r2,  r2, 0), z = Vec3f(0, 0, 1),         --[[ ez = 135, ]] axis = Vec3f(0, 0, 1) },
  { y = Vec3f( r2, -r2, 0), x = Vec3f(-r2, -r2, 0), z = Vec3f(0, 0, 1),         --[[ ez = 225, ]] axis = Vec3f(0, 0, 1) },
  { y = Vec3f( r2,  r2, 0), x = Vec3f( r2, -r2, 0), z = Vec3f(0, 0, 1),         --[[ ez = 315, ]] axis = Vec3f(0, 0, 1) },
}
for i = 1, #bases do
  local b = bases[i]
  assert(b.x:approximatelyEqual(b.y:cross(b.z)))
end

local function printResult (name, result, expected, actual)
  if result then
    printf('%s Passed', name)
  else
    printf('%s FAILED!', name)
    printf('\tExpected: %s', expected)
    printf('\tActual:   %s', actual)
    print()
  end
end

local function test_quat_identity ()
  local name = 'test_quat_identity'
  local qExpected = Quat(0, 0, 0, 1)

  local l      = Vec3f(0, 0, -1)
  local u      = Vec3f(0, 1, 0)
  local q      = Quat.FromLookUp(l, u)
  local result = q:equal(qExpected)
  printResult(name, result, qExpected, q)

  local axis   = Vec3f(0, 1, 0)
  local angle  = 0
  local q      = Quat.FromAxisAngle(axis, angle)
  local result = q:equal(qExpected)
  printResult(name, result, qExpected, q)

  local x      = Vec3f(1, 0, 0)
  local y      = Vec3f(0, 1, 0)
  local z      = Vec3f(0, 0, 1)
  local q      = Quat.FromBasis(x, y, z)
  local result = q:equal(qExpected)
  printResult(name, result, qExpected, q)

  local v      = Vec3f(0, 0, -1)
  local q      = Quat.FromRotateTo(v, v)
  local result = q:equal(qExpected)
  printResult(name, result, qExpected, q)
end

local function test_quat_180 ()
  local name = 'test_quat_180'
  local qExpected = Quat(0, 1, 0, 0)

  local l      = Vec3f(0, 0, 1)
  local u      = Vec3f(0, 1, 0)
  local q      = Quat.FromLookUp(l, u)
  local result = q:equal(qExpected)
  printResult(name, result, qExpected, q)

  local axis   = Vec3f(0, 1, 0)
  local angle  = Math.Pi
  local q      = Quat.FromAxisAngle(axis, angle)
  local result = q:approximatelyEqual(qExpected)
  printResult(name, result, qExpected, q)

  local x      = Vec3f(-1, 0, 0)
  local y      = Vec3f(0, 1, 0)
  local z      = Vec3f(0, 0, -1)
  local q      = Quat.FromBasis(x, y, z)
  local result = q:equal(qExpected)
  printResult(name, result, qExpected, q)

  local f      = Vec3f(0, 0, -1)
  local i      = Vec3f(1, 0, 0)
  local t      = Vec3f(0, 0, 1)
  local q1     = Quat.FromRotateTo(f, i)
  local q2     = Quat.FromRotateTo(i, t)
  local q      = q1 * q2
  local result = q:approximatelyEqual(qExpected)
  printResult(name, result, qExpected, q)
end

local function test_quat_lookup ()
  local name = 'test_quat_lookup'

  local l = Vec3f(0, 0, 1)
  local u = Vec3f(0, 1, 0)
  local q  = Quat.FromLookUp(l, u)

  local qx         = q:getAxisX()
  local qy         = q:getAxisY()
  local qz         = q:getAxisZ()
  local qxExpected = l:cross(u)
  local qyExpected = u
  local qzExpected = l:inverse()
  local result     = qx:equal(qxExpected) and qy:equal(qyExpected) and qz:equal(qzExpected)
  printResult(name, result,
    string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', qxExpected, qyExpected, qzExpected),
    string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', qx, qy, qz)
  )
end

local function test_matrix_lookup ()
  local name = 'test_matrix_lookup'

  local l          = Vec3f(0, 0, 1)
  local u          = Vec3f(0, 1, 0)
  local m          = Matrix.LookUp(Vec3f(), l, u)
  local mx         = Vec3f(m.m[0], m.m[4], m.m[8])
  local my         = Vec3f(m.m[1], m.m[5], m.m[9])
  local mz         = Vec3f(m.m[2], m.m[6], m.m[10])
  local mxExpected = l:cross(u)
  local myExpected = u
  local mzExpected = l:inverse()
  local result     = mx:equal(mxExpected) and my:equal(myExpected) and mz:equal(mzExpected)
  printResult(name, result,
    string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', mxExpected, myExpected, mzExpected),
    string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', mx, my, mz)
  )

  local mx     = m:getRight()
  local my     = m:getUp()
  local mz     = m:getForward():inverse()
  local result = mx:equal(mxExpected) and my:equal(myExpected) and mz:equal(mzExpected)
  printResult(name, result,
    string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', mxExpected, myExpected, mzExpected),
    string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', mx, my, mz)
  )
end

local function test_quat_lookup_axes_equal_matrix_lookup_columns ()
  local name = 'test_quat_lookup_axes_equal_matrix_lookup_columns'

  local l      = Vec3f(0, 0, 1)
  local u      = Vec3f(0, 1, 0)
  local q      = Quat.FromLookUp(l, u)
  local qx     = q:getAxisX()
  local qy     = q:getAxisY()
  local qz     = q:getAxisZ()
  local m      = Matrix.LookUp(Vec3f(), l, u)
  local mx     = Vec3f(m.m[0], m.m[4], m.m[8])
  local my     = Vec3f(m.m[1], m.m[5], m.m[9])
  local mz     = Vec3f(m.m[2], m.m[6], m.m[10])
  local result = mx:equal(qx) and my:equal(qy) and mz:equal(qz)
  printResult(name, result,
    string.format('[Quat]  \n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', qx, qy, qz),
    string.format('[Matrix]\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', mx, my, mz)
  )

  local mx     = m:getRight()
  local my     = m:getUp()
  local mz     = m:getForward():inverse()
  local result = mx:equal(qx) and my:equal(qy) and mz:equal(qz)
  printResult(name, result,
    string.format('[Quat]  \n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', qx, qy, qz),
    string.format('[Matrix]\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', mx, my, mz)
  )

  local qr     = q:getRight()
  local qu     = q:getUp()
  local qf     = q:getForward()
  local mr     = m:getRight()
  local mu     = m:getUp()
  local mf     = m:getForward()
  local result = mr:equal(qr) and mu:equal(qu) and mf:equal(qf)
  printResult(name, result,
    string.format('[Quat]  \n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', qr, qu, qf),
    string.format('[Matrix]\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', mr, mu, mf)
  )
end

local function test_quat_getaxis ()
  local name = 'test_quat_getaxis'

  for i = 1, #bases do
    local b = bases[i]

    local q      = Quat.FromBasis(b.x, b.y, b.z)
    local qx     = q:getAxisX()
    local qy     = q:getAxisY()
    local qz     = q:getAxisZ()
    local result = qx:approximatelyEqual(b.x) and qy:approximatelyEqual(b.y) and qz:approximatelyEqual(b.z)
    printResult(name, result,
      string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', b.x, b.y, b.z),
      string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', qx, qy, qz)
    )
  end
end

local function test_quat_getdir ()
  local name = 'test_quat_getdir'

  for i = 1, #bases do
    local b = bases[i]

    local q         = Quat.FromBasis(b.x, b.y, b.z)
    local r         = q:getRight()
    local u         = q:getUp()
    local f         = q:getForward()
    local rExpected = b.x
    local uExpected = b.y
    local fExpected = b.z:inverse()
    local result    = r:approximatelyEqual(rExpected) and u:approximatelyEqual(uExpected) and f:approximatelyEqual(fExpected)
    printResult(name, result,
      string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', rExpected, uExpected, fExpected),
      string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', r, u, f)
    )
  end
end

local function test_matrix_getdir ()
  local name = 'test_matrix_getdir'

  for i = 1, #bases do
    local b = bases[i]

    local m         = Matrix.FromBasis(b.x, b.y, b.z)
    local r         = m:getRight()
    local u         = m:getUp()
    local f         = m:getForward()
    local rExpected = b.x
    local uExpected = b.y
    local fExpected = b.z:inverse()
    local result    = r:approximatelyEqual(rExpected) and u:approximatelyEqual(uExpected) and f:approximatelyEqual(fExpected)
    printResult(name, result,
      string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', rExpected, uExpected, fExpected),
      string.format('\n\t\tx: %s\n\t\ty: %s\n\t\tz: %s', r, u, f)
    )
  end
end

local function test_quat_frombasis_equal_matrix_frombasis_toquat ()
  local name = 'test_quat_frombasis_equal_matrix_frombasis_toquat'

  for i = 1, #bases do
    local b = bases[i]

    local q  = Quat.FromBasis(b.x, b.y, b.z)
    local m  = Matrix.FromBasis(b.x, b.y, b.z)
    local mq = m:toQuat()
    local result = q:approximatelyEqual(mq)
    printResult(name, result, q, mq)
  end
end

function CoordTest:onInit ()
  test_quat_identity()
  test_quat_180()
  test_quat_lookup()
  test_matrix_lookup()
  test_quat_lookup_axes_equal_matrix_lookup_columns()
  test_quat_getaxis()
  test_quat_getdir()
  test_matrix_getdir()
  test_quat_frombasis_equal_matrix_frombasis_toquat()
  self:quit()

  self.radius = 50
  self.theta  = -Math.Pi/2
  self.phi    = Math.Pi/2

  self.pos = Vec3f(0, 0, 0)
  --self.rot = Quat(0, 0, 0, 1)

  self.mView    = Matrix.Identity()
  self.mProj    = Matrix.Identity()
  self.mViewInv = Matrix.Identity()
  self.mProjInv = Matrix.Identity()

  self.renderer = Renderer()
end

function CoordTest:onUpdate (dt)
  if Input.GetDown(Button.Mouse.Left) then
    local mouseDelta = Input.GetMouseDelta()
    self.theta = self.theta + 0.005*mouseDelta.x

    local epsilon = 0.0001
    self.phi = self.phi + -0.005*mouseDelta.y
    self.phi = Math.Clamp(self.phi, epsilon, Math.Pi - epsilon)
  end

  self.radius = self.radius * (1 - .05 * Input.GetValue(Button.Mouse.ScrollY))
  self.radius = Math.Clamp(self.radius, 0.2, 2000.0)

  self.pos.x = self.radius * sin(self.phi) * cos(self.theta)
  self.pos.y = self.radius * cos(self.phi)
  self.pos.z = self.radius * sin(self.phi) * sin(self.theta)

  self.look = Vec3f(0, 0, 0) - self.pos
  self.up   = Vec3f(0, 1, 0)

  self.z = self.look:normalize()
  self.x = self.up:cross(self.z):normalize()
  self.y = self.z:cross(self.x)
  --self.rot  = Quat.FromLookUp(self.look, self.up)
end

function CoordTest:onDraw ()
  ClipRect.PushDisabled()
  RenderState.PushAllDefaults()

  self.mViewInv:free()
  self.mView:free()
  --self.mViewInv = Matrix.FromPosRot(self.pos, self.rot)
  --self.mView = self.mViewInv:inverse()
  self.mViewInv = Matrix.FromPosBasis(self.pos, self.x, self.y, self.z)
  self.mView = self.mViewInv:inverse()

  self.mProj:free()
  self.mProjInv:free()
  self.mProj = Matrix.Perspective(
    60,
    self.resX / self.resY,
    pow(10.0, -1),
    pow(10.0, 7)
  )
  self.mProjInv = self.mProj:inverse()

  ShaderVar.PushMatrix('mView', self.mView)
  ShaderVar.PushMatrix('mProj', self.mProj)
  ShaderVar.PushFloat3('eye', self.pos.x, self.pos.y, self.pos.z)
  self.renderer:start(self.resX, self.resY, 1)

  do -- Draw
    --Ship.Render()

    GLMatrix.ModeWV() GLMatrix.Push() GLMatrix.Load(self.mView)
    GLMatrix.ModeP()  GLMatrix.Push() GLMatrix.Load(self.mProj)

      -- Origin
      Draw.Color(1, 1, 1, 1)
      Draw.Sphere(Vec3f(0, 0, 0), 2)

      -- Positive Z
      RenderState.PushWireframe(false)
      Draw.Color(0, 0, 1, 1)
      Draw.Sphere(Vec3f(0, 0, 10), 2)
      RenderState.PopWireframe()

      -- Negative Z
      RenderState.PushWireframe(true)
      Draw.Sphere(Vec3f(0, 0, -10), 2)
      RenderState.PopWireframe()

      Draw.Axes(Vec3f(0, 0, 0), Vec3f(1, 0, 0), Vec3f(0, 1, 0), Vec3f(0, 0, 1), 10, 1)

    GLMatrix.ModeP()  GLMatrix.Pop()
    GLMatrix.ModeWV() GLMatrix.Pop()
  end

  self.renderer:stop()
  ShaderVar.Pop('mView')
  ShaderVar.Pop('mProj')
  ShaderVar.Pop('eye')
  self.renderer:present(0, 0, self.resX, self.resY, false)

  RenderState.PopAll()
  ClipRect.Pop()
end

return CoordTest
