local Camera = class(function (self)
  self.x = 0
  self.y = 0
  self.sx = 1
  self.sy = 1
  self.pos = Vec3f()
  self.rot = Quat.Identity()
  self.posT = Vec3f()
  self.rotT = Quat.Identity()
  self.posOffset = Vec3f()
  self.rotOffset = Quat.Identity()
  self.zNear = 0.1
  self.zFar = 1e6
  self.mView = Matrix.Identity()
  self.mProj = Matrix.Identity()
  self.mViewInv = Matrix.Identity()
  self.mProjInv = Matrix.Identity()
end)

local stack = {}

function Camera:beginDraw ()
  self:push()
  self:refreshMatrices()
  ShaderVar.PushMatrix('mView', self.mView)
  ShaderVar.PushMatrix('mViewInv', self.mViewInv)
  ShaderVar.PushMatrix('mProj', self.mProj)
  ShaderVar.PushMatrix('mProjInv', self.mProjInv)
  ShaderVar.PushFloat3('eye', self.pos.x, self.pos.y, self.pos.z)
end

function Camera:endDraw ()
  ShaderVar.Pop('mView')
  ShaderVar.Pop('mViewInv')
  ShaderVar.Pop('mProj')
  ShaderVar.Pop('mProjInv')
  ShaderVar.Pop('eye')
  self:pop()
end

function Camera:lerpFrom (pos, rot)
  self.posOffset = pos + self.posT:inverse()
  self.rotOffset = rot * self.rotT:inverse()
end

function Camera:cancelLerp ()
  self.posOffset = Vec3f.Identity()
  self.rotOffset =  Quat.Identity()
end

function Camera:lerp (dt)
  local f = 1.0 - exp(-10.0 * dt)
  self.posOffset:ilerp(Vec3f.Identity(), f)
  self.rotOffset:iLerp( Quat.Identity(), f)
end

-- Fundamental Transformations -------------------------------------------------
-- NOTE : These are all for *positions* not *directions*
-- NOTE : 'window' means the OpenGL window
-- NOTE : 'screen' means the camera widget, which may be offset and resized within the window

function Camera:windowToScreen (wnd)
  local ss = Vec2f()
  ss.x = wnd.x - self.x
  ss.y = wnd.y - self.y
  return ss
end

function Camera:screenToNDC (ss)
  local ndc = Vec3f()
  ndc.x =   2.0 * ss.x / self.sx - 1.0
  ndc.y = -(2.0 * ss.y / self.sy - 1.0)
  ndc.z = -1.0
  return ndc
end

-- BUG : ndc.z = 1 gives NaNs when zNear == 0.1 and zFar == 1e7. Expect 0.1
-- BUG : ndc.z = 1 gives 9,586,980 when zNear == 10 and zFar == 1e7. Expect 10,000,000
function Camera:ndcToView (ndc)
  local vs4 = self.mProjInv:mulVec(Vec4f(ndc.x, ndc.y, ndc.z, 1.0))
  local vs  = vs4:divs(vs4.w):toVec3f()
  return vs
end

function Camera:viewToWorld (vs)
  local ws = self.mViewInv:mulPoint(vs)
  return ws
end

function Camera:worldToView (ws)
  local vs = self.mView:mulPoint(ws)
  return vs
end

function Camera:viewToNDC (vs)
  local ndc4 = self.mProj:mulVec(Vec4f(vs.x, vs.y, vs.z, 1.0))
  local ndc  = ndc4:divs(ndc4.w):toVec3f()
  return ndc, Math.Sign(ndc4.w)
end

function Camera:ndcToScreen (ndc)
  local ss = Vec2f()
  ss.x = self.sx * ( ndc.x + 1.0) / 2.0
  ss.y = self.sy * (-ndc.y + 1.0) / 2.0
  return ss
end

function Camera:screenToWindow (ss)
  local wnd = Vec2f()
  wnd.x = ss.x + self.x
  wnd.y = ss.y + self.y
  return wnd
end

--------------------------------------------------------------------------------

-- Helper Transformations ------------------------------------------------------
-- NOTE : These are all for *positions* not *directions*

-- OPTIMIZE : Creating a table is maybe not so great
function Camera:entityToScreenRect (entity)
  local box = entity:getBoundingBoxLocal()
  local points = {
    Vec3f(box.lowerx, box.lowery, box.lowerz),
    Vec3f(box.upperx, box.lowery, box.lowerz),
    Vec3f(box.lowerx, box.uppery, box.lowerz),
    Vec3f(box.upperx, box.uppery, box.lowerz),
    Vec3f(box.lowerx, box.lowery, box.upperz),
    Vec3f(box.upperx, box.lowery, box.upperz),
    Vec3f(box.lowerx, box.uppery, box.upperz),
    Vec3f(box.upperx, box.uppery, box.upperz),
  }

  local xMin, yMin, xMax, yMax = math.huge, math.huge, -math.huge, -math.huge
  for i = 1, #points do
    local ws  = entity:toWorld(points[i])
    local vs  = self:worldToView(ws)
    local ndc = self:viewToNDC(vs)
    local ss  = self:ndcToScreen(ndc)

    xMin, yMin = min(xMin, ss.x), min(yMin, ss.y)
    xMax, yMax = max(xMax, ss.x), max(yMax, ss.y)
  end

  return xMin, yMin, xMax - xMin, yMax - yMin
end

function Camera:ndcToRay (ndc, length)
  ndc.z = 0.9
  local vs = self:ndcToView(ndc)
  local ws = self:viewToWorld(vs)

  -- NOTE : Calculate dir in View Space to avoid catastrophic cancellation
  ndc.z = 0.99
  local vs_p1 = self:ndcToView(ndc)
  local vs_dir = vs_p1 - vs
  local dir = self.mViewInv:mulDir(vs_dir):normalize()

  return Ray(ws.x, ws.y, ws.z, dir.x, dir.y, dir.z, 0, length)
end

function Camera:mouseToRay (length)
  local mp  = Input.GetMousePosition()
  local ss  = self:windowToScreen(mp)
  local ndc = self:screenToNDC(ss)
  local ray = self:ndcToRay(ndc, length)
  return ray
end

-- NOTE : NDC.z is +/- 1, indicating in front or behind the near plane.
function Camera:worldToNDC (ws)
  local vs  = self:worldToView(ws)
  local ndc, w = self:viewToNDC(vs)
  ndc.z = w
  return ndc
end

--------------------------------------------------------------------------------

function Camera:refreshMatrices ()
  self.mView:free()
  self.mViewInv:free()
  self.mProj:free()
  self.mProjInv:free()

  self.pos = self.posOffset + self.posT
  self.rot = self.rotOffset * self.rotT

  self.mViewInv = Matrix.FromPosRot(self.pos, self.rot)
  self.mView = self.mViewInv:inverse()

  self.mProj = Matrix.Perspective(
    Settings.get('render.fovY'),
    self.sx / self.sy,
    self.zNear,
    self.zFar)
  self.mProjInv = self.mProj:inverse()
end

function Camera:setViewport (x, y, sx, sy)
  self.x = x
  self.y = y
  self.sx = sx
  self.sy = sy
end

function Camera.get ()
  return stack[#stack]
end

function Camera:pop ()
  stack[#stack] = nil
end

function Camera:push ()
  stack[#stack + 1] = self
end

function Camera:warp () end

return Camera
