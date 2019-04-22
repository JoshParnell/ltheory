local BSPTest = Application()

local alphaModes = { 0.7, 0.065 }
local cullModes  = { CullFace.Back, CullFace.Front, CullFace.None }
local depthModes = { true, false }
local viewModes = {
  { CullFace.None, true },
  { CullFace.Back, false },
}

local sphereProf = IntersectSphereProfiling()
local leafIndex = 0
local leafNodeRef = BSPNodeRef()
leafNodeRef.index = 1

local State = {
  gen = {
    font      = nil,
    cameraP   = Vec3d(1.5, math.pi/2, .9 * math.pi/2),
    alphaMode = alphaModes[1],
    cullMode  = cullModes[1],
    depthMode = depthModes[1],
    viewMode  = viewModes[1],
  },

  obj = {
    fileName        = nil,
    binary          = nil,
    mesh            = nil,
    invert          = nil,
    scale           = nil,
    center          = nil,
    testPoint       = nil,
    testLineSegment = nil,
    testMin         = nil,
    testMax         = nil,
  },

  bsp = {
    bsp        = nil,
    curNode    = ffi.new('BSPNodeRef'),
    planeBasis = {
      right    = nil,
      up       = nil,
      forward  = nil,
    },
    testNumber = nil,
    seed       = nil,
  },
}

local function Assert (condition)
  if not condition then error() end
end

local function DrawMesh (mesh, cullMode, depthMode, alphaMode)
  RenderState.PushCullFace(cullMode)
  RenderState.PushDepthTest(depthMode)

  Draw.Color(0.2, 0.2, 0.2, alphaMode)
  mesh:draw()

  RenderState.PushWireframe(true)
  Draw.Color(1.0, 1.0, 1.0, 0.1)
  mesh:draw()
  RenderState.PopWireframe()

  RenderState.PopDepthTest()
  RenderState.PopCullFace()
end

function BSPTest:onInit ()
  local s   = State
  local gen = State.gen
  local obj = State.obj
  local bsp = State.bsp

  gen.font = Font.Load('DejaVuSans', 22)
  Assert(gen.font)

  obj.binary = false
  --[[
  obj.fileName        = 'cube'
  obj.scale           = 1.0
  obj.testMin         = Vec3f(-0.5, -0.5, -0.5)
  obj.testMax         = Vec3f( 1.5,  1.5,  1.5)
  --]]

  --[[
  obj.fileName        = 'cube_kevin'
  obj.scale           = 0.1
  obj.testMin         = Vec3f(-1.0, -1.0, -1.0)
  obj.testMax         = Vec3f( 1.0,  1.0,  1.0)
  --obj.testP0        = Vec3f(0.0, 0.2,  2.0)
  --obj.testP1        = Vec3f(0.0, 0.2, -2.0)
  obj.testLineSegment = LineSegment(-1.5216, -0.7786,  1.1656,
                                    -0.0078,  0.1533, -0.0462)
  --]]

  ---[[
  obj.fileName        = 'icosahedron'
  obj.scale           = 1.0
  obj.testMin         = Vec3f(-1.0, -1.0, -1.0)
  obj.testMax         = Vec3f( 1.0,  1.0,  1.0)
  obj.testLineSegment = LineSegment(0.1121, 1.9333, -0.9644,
                                    0.0280, 0.0141, -0.0262)
  --]]

  --[[
  obj.fileName        = 'torus'
  obj.scale           = 1.0
  obj.center          = true
  obj.testMin         = Vec3f(-0.7, -0.3, -0.8)
  obj.testMax         = Vec3f( 1.3,  0.3,  0.8)
  --]]

  --[[
  obj.fileName        = 'torus2'
  obj.scale           = 0.6
  obj.center          = true
  obj.testMin         = Vec3f(-0.8, -0.3, -0.8)
  obj.testMax         = Vec3f( 0.8,  0.3,  0.8)
  --]]

  -- TODO : This has a few false negatives. Maybe 1 in 1000.
  --[[
  obj.fileName        = 'luffa'
  obj.scale           = 1.0
  obj.testMin         = Vec3f(-1.4, -1.4, -1.4)
  obj.testMax         = Vec3f( 1.4,  1.4,  1.4)
  obj.testLineSegment = LineSegment(-4.1737, -2.0637, -3.7198,
                                     0.0862,  0.0758,  0.0254)
  --]]

  --[[
  -- NOTE : This is not a surface representation!
  obj.fileName        = 'teapot'
  obj.invert          = true
  obj.scale           = 0.02
  obj.testPoint       = Vec3f(43.2935028, -10.0955286, -29.6540623)
  obj.testMin         = Vec3f(-1.8, -1.0, -1.2)
  obj.testMax         = Vec3f( 2.1,  1.1,  1.2)
  --]]

  --[[
  obj.fileName        = 'teapot2'
  obj.scale           = 0.03
  obj.center          = true
  obj.testMin         = Vec3f(-2.0, -2.0, -2.0)
  obj.testMax         = Vec3f( 2.0,  2.0,  2.0)
  --]]

  --[[
  -- NOTE : This is not a surface representation!
  obj.fileName        = 'teapot3'
  obj.scale           = 0.05
  obj.center          = true
  obj.testPoint       = Vec3f(-0.620258749, 0.482370466, -0.711474657)
  obj.testMin         = Vec3f(-2.0, -2.0, -2.0)
  obj.testMax         = Vec3f( 2.0,  2.0,  2.0)
  --]]

  --[[
  -- NOTE : This is not a surface representation!
  obj.fileName        = 'alfa147'
  obj.scale           = 0.02
  obj.testMin         = Vec3f(-1.0, -1.0, -1.0)
  obj.testMax         = Vec3f( 1.0,  1.0,  1.0)
  --]]

  --[[
  -- NOTE : This is not a surface representation!
  -- NOTE : The bottom of the car is 'inverted' (polys are facing the wrong way).
  obj.fileName        = 'minicooper'
  obj.scale           = 0.02
  obj.center          = true
  obj.testMin         = Vec3f(-1.0, -2.00, -0.25)
  obj.testMax         = Vec3f( 1.0,  1.25,  1.50)
  --]]

  --[[
  -- NOTE : This is not a surface representation!
  -- NOTE : 2,613,586 vertices, 871,195 triangles
  obj.fileName        = 'dragon'
  obj.scale           = 1.5
  obj.testMin         = Vec3f(-1.0, -1.0, -1.0)
  obj.testMax         = Vec3f( 1.0,  1.0,  1.0)
  --]]

  --[[
  obj.fileName        = 'asteroid'
  obj.scale           = 1.0
  obj.testMin         = Vec3f(-1.0, -1.0, -1.0)
  obj.testMax         = Vec3f( 1.0,  1.0,  1.0)
  obj.binary          = true
  --]]

  --[[
  obj.fileName        = 'station'
  obj.scale           = 0.25
  obj.testMin         = Vec3f(-1.0, -1.0, -1.0)
  obj.testMax         = Vec3f( 1.0,  1.0,  1.0)
  obj.binary          = true
  --]]

  if obj.binary then
    local bytes = Bytes.Load(obj.fileName)
    obj.mesh = Mesh.FromBytes(bytes)
    Bytes.Free(bytes)
  else
    --local objData = Resource.LoadCstr(ResourceType.Mesh, 'test/mesh/' .. obj.fileName)
    local objData = Resource.LoadCstr(ResourceType.Mesh, obj.fileName)
    Assert(objData ~= nil)

    obj.mesh = Mesh.FromObj(objData)
    -- LEAK : StrFree isn't exported
    --StrFree(objData)
  end

  if obj.center then obj.mesh:center() end
  if obj.invert then obj.mesh:invert() end
  obj.mesh:scaleUniform(obj.scale)

  --int32 triCount = Mesh.GetIndexCount(obj.mesh) / 3
  --Warn('triCount: %i', triCount)

  bsp.bsp        = BSP.Create(obj.mesh)
  bsp.testNumber = 5
  bsp.seed       = 1234

  -- Perf test
  if false then
    --printf('Ray\n')
    local rng = RNG.Create(2092)

    local timer = Timer.Create()
    --bspTimer = Timer.Create()
    --bspFile = File.Create('ray.txt')
    for i = 0, 300000 do
      local p0 = Vec3f()
      rng:getDir3(p0)
      p0:imuls(2.0*(1.0 + rng:getExp()))

      local p1 = rng:getVec3(-0.1, 0.1)
      p1:imuls(1.0*(1.0 + rng:getExp()))

      local lineSegment = LineSegment(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z)
      BSPDebug.DrawLineSegment(bsp.bsp, lineSegment)
    end
    local t = Timer.GetElapsed(timer)
    timer:free()
    --bspTimer:free() bspTimer = 0
    --bspFile:close() bspFile = 0

    rng:free()
    BSPDebug.PrintRayProfilingData(bsp.bsp, t)
  end

  if false then
    --printf('Sphere\n')
    local rng = RNG.Create(2092)

    local timer = Timer.Create()
    --bspTimer = Timer.Create()
    --bspFile = File.Create('sphere.txt')
    for i = 0, 300000 do
      local sphere = ffi.new('Sphere')
      local p = rng:getVec3(-1.25, 1.25)
      sphere.px, sphere.py, sphere.pz = p.x, p.y, p.z
      sphere.r = rng:getUniformRange(0.05, 0.30)

      local pHit = Vec3f()
      bsp.bsp:intersectSphere(sphere, pHit)
    end
    local t = Timer.GetElapsed(timer)
    timer:free()
    --bspTimer:free() bspTimer = 0
    --bspFile:close() bspFile = 0

    rng:gree()
    BSPDebug.PrintSphereProfilingData(bsp.bsp, t)
  end
end

function BSPTest:onUpdate (dt)
  local s   = State
  local gen = State.gen
  local obj = State.obj
  local bsp = State.bsp

  do -- Input
    if Input.GetPressed(Button.Keyboard.N1) then bsp.testNumber = 1 end
    if Input.GetPressed(Button.Keyboard.N2) then bsp.testNumber = 2 end
    if Input.GetPressed(Button.Keyboard.N3) then bsp.testNumber = 3 end
    if Input.GetPressed(Button.Keyboard.N4) then bsp.testNumber = 4 end
    if Input.GetPressed(Button.Keyboard.N5) then bsp.testNumber = 5 end
    if Input.GetPressed(Button.Keyboard.N6) then bsp.testNumber = 6 end

    if Input.GetPressed(Button.Keyboard.F1) then gen.alphaMode = List.getNext(alphaModes, gen.alphaMode) end
    if Input.GetPressed(Button.Keyboard.F2) then gen.cullMode  = List.getNext(cullModes,  gen.cullMode)  end
    if Input.GetPressed(Button.Keyboard.F3) then gen.depthMode = List.getNext(depthModes, gen.depthMode) end
    if Input.GetPressed(Button.Keyboard.F4) then gen.viewMode  = List.getNext(viewModes,  gen.viewMode)  end

    if Input.GetDown(Button.Mouse.Left) then
      local mouseDelta = Input.GetMouseDelta()
      gen.cameraP.y = gen.cameraP.y + 0.005*mouseDelta.x

      local epsilon = 0.0001
      gen.cameraP.z = gen.cameraP.z + -0.005 * mouseDelta.y
      gen.cameraP.z = Math.Clamp(gen.cameraP.z, epsilon, math.pi - epsilon)
    end

    gen.cameraP.x = gen.cameraP.x * (1 - .05 * Input.GetValue(Button.Mouse.ScrollY))
    gen.cameraP.x = Math.Clamp(gen.cameraP.x, 0.2, 2000.0)
  end
end

function BSPTest:onDraw ()
  local s   = State
  local gen = State.gen
  local obj = State.obj
  local bsp = State.bsp

  do -- Preamble
    Draw.Clear(0.1, 0.1, 0.1, 1.0)
    Draw.ClearDepth(1)

    GLMatrix.ModeP()
    GLMatrix.PushClear()
    GLMatrix.Perspective(60, Viewport.GetAspect(), 0.1, 10000.0)

    GLMatrix.ModeWV()
    GLMatrix.Push()

    local cameraP_Euc = Vec3d()
    cameraP_Euc.x = gen.cameraP.x * sin(gen.cameraP.z) * cos(gen.cameraP.y)
    cameraP_Euc.y = gen.cameraP.x * cos(gen.cameraP.z)
    cameraP_Euc.z = gen.cameraP.x * sin(gen.cameraP.z) * sin(gen.cameraP.y)

    local origin = Vec3d()
    local up     = Vec3d(0.0, 1.0, 0.0)
    GLMatrix.LookAt(cameraP_Euc, origin, up)

    RenderState.PushBlendMode(BlendMode.Alpha)
    RenderState.PushDepthTest(true)
    RenderState.PushCullFace(gen.viewMode[1])
    RenderState.PushWireframe(gen.viewMode[2])
  end

  do -- Draw (world space)
    Draw.LineWidth(1.0)
    RenderState.PushBlendMode(BlendMode.Alpha)
    RenderState.PushCullFace(CullFace.Back)
    RenderState.PushDepthTest(true)

    --Draw mesh 'inverted' so anything drawn behind
    --it gets culled (but not things inside it)
    --if (depthMode) {
    --  RenderState.PushCullFace(CullFace.Front)
    --  Draw.Color(1.0, 1.0, 1.0, 0.0)
    --  Mesh.Draw(obj.mesh)
    --  RenderState.PopCullFace()
    --}

    --No test, draw mesh
    if bsp.testNumber == 1 then
      local zero = Vec3f()
      local p
      Draw.Color(1.0, 0.0, 0.0, 1.0) p = Vec3f(1.0, 0.0, 0.0) Draw.Line3(zero, p)
      Draw.Color(0.0, 1.0, 0.0, 1.0) p = Vec3f(0.0, 1.0, 0.0) Draw.Line3(zero, p)
      Draw.Color(0.0, 0.0, 1.0, 1.0) p = Vec3f(0.0, 0.0, 1.0) Draw.Line3(zero, p)

      DrawMesh(obj.mesh, gen.cullMode, gen.depthMode, gen.alphaMode)

      if Input.GetPressed(Button.Keyboard.Right) then
        leafIndex = leafIndex + 1
        leafNodeRef = BSPDebug.GetLeaf(bsp.bsp, leafIndex)
      end
      if Input.GetPressed(Button.Keyboard.Left) then
        leafIndex = leafIndex - 1
        leafNodeRef = BSPDebug.GetLeaf(bsp.bsp, leafIndex)
      end

      RenderState.PushWireframe(false)
      RenderState.PushDepthTest(false)
      RenderState.PushCullFace(CullFace.None)
      Draw.Color(1, 1, 1, 0.75)
      BSPDebug.DrawNode(bsp.bsp, leafNodeRef)
      RenderState.PopCullFace()
      RenderState.PopDepthTest()
      RenderState.PopWireframe()
    end

    -- TEST : Test regular line segments against the BSP tree
    if bsp.testNumber == 2 then
      local num = 50
      for i = 0, num do
        for j = 0, num do
          local p0 = Vec3f(
            Math.Lerp(obj.testMin.x, obj.testMax.x, i / num),
            Math.Lerp(obj.testMin.y, obj.testMax.y, j / num),
            2.0
          )

          local p1 = Vec3f(p0.x, p0.y, -2.0)
          local lineSegment = LineSegment(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z)
          BSPDebug.DrawLineSegment(bsp.bsp, lineSegment)
        end
      end
    end

    -- TEST : Test random line segments against the BSP tree
    if bsp.testNumber == 3 then
      if not gen.depthMode then
        DrawMesh(obj.mesh, gen.cullMode, gen.depthMode, gen.alphaMode)
      end

      if Input.GetPressed(Button.Keyboard.Right) then bsp.seed = bsp.seed + 1 end
      if Input.GetPressed(Button.Keyboard.Left)  then bsp.seed = bsp.seed - 1 end
      if Input.GetPressed(Button.Keyboard.Up)    then bsp.seed = 0 end

      local mul = 11
      if Input.GetPressed(Button.Keyboard.PageDown) then mul = mul - 1 end
      if Input.GetPressed(Button.Keyboard.PageUp)   then mul = mul + 1 end
      --RAY_INTERSECTION_EPSILON = mul * PLANE_THICKNESS_EPSILON

      local rng = RNG.Create(bsp.seed ~= 0 and bsp.seed or rand())
      for i = 0, 200 do
        local p0 = Vec3f()
        rng:getDir3(p0)
        p0:imuls(2.0*(1.0 + rng:getExp()))

        local p1 = rng:getVec3(-0.1, 0.1)
        p1:imuls(1.0*(1.0 + rng:getExp()))

        local lineSegment = LineSegment(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z)
        BSPDebug.DrawLineSegment(bsp.bsp, lineSegment)
      end

      rng:free()

      if gen.depthMode then
        DrawMesh(obj.mesh, gen.cullMode, gen.depthMode, gen.alphaMode)
      end
    end

    -- TEST : Check a single line segment (like a known false negative)
    if bsp.testNumber == 4 then
      if not gen.depthMode then
        DrawMesh(obj.mesh, gen.cullMode, gen.depthMode, gen.alphaMode)
      end

      BSPDebug.DrawLineSegment(bsp.bsp, obj.testLineSegment)

      if gen.depthMode then
        DrawMesh(obj.mesh, gen.cullMode, gen.depthMode, gen.alphaMode)
      end
    end

    -- TEST : Test random sphere against the BSP tree
    if bsp.testNumber == 5 then
      local previousSeed = bsp.seed
      if Input.GetPressed(Button.Keyboard.Right) then bsp.seed = bsp.seed + 1 end
      if Input.GetPressed(Button.Keyboard.Left)  then bsp.seed = bsp.seed - 1 end
      if Input.GetPressed(Button.Keyboard.Up)    then bsp.seed = 0 end

      if bsp.seed ~= previousSeed then
        sphereProf.triangleTests_size = 0
        sphereProf.nodes = 0
        sphereProf.leaves = 0
        sphereProf.triangles = 0

        local rng = RNG.Create(bsp.seed ~= 0 and bsp.seed or rand())
        local sphere = ffi.new('Sphere')
        local p = rng:getVec3(-1.25, 1.25)
        sphere.px, sphere.py, sphere.pz = p.x, p.y, p.z
        sphere.r = rng:getUniformRange(0.05, 0.30)
        bsp.bsp:getIntersectSphereTriangles(sphere, sphereProf)
        rng:free()
      end

      local mul = 11
      if Input.GetPressed(Button.Keyboard.PageDown)  then mul = mul - 1 end
      if Input.GetPressed(Button.Keyboard.PageUp)    then mul = mul + 1 end
      --RAY_INTERSECTION_EPSILON = mul * PLANE_THICKNESS_EPSILON

      RenderState.PushWireframe(false)
      Draw.Color(0.2, 0.2, 0.2, 1.0)
      obj.mesh:draw()
      RenderState.PopWireframe()

      Draw.Color(1.0, 1.0, 1.0, 0.1)
      obj.mesh:draw()

      local rng = RNG.Create(bsp.seed ~= 0 and bsp.seed or rand())
      local sphere = ffi.new('Sphere')
      local p = rng:getVec3(-1.25, 1.25)
      sphere.px, sphere.py, sphere.pz = p.x, p.y, p.z
      sphere.r = rng:getUniformRange(0.05, 0.30)
      BSPDebug.DrawSphere(bsp.bsp, sphere)
      rng:free()

      RenderState.PushWireframe(false)
      RenderState.PushDepthTest(false)
      --[[ ArrayList :(
      ArrayList.ForEach(sphereProf.triangleTests, TriangleTest, t) {
        if (t->hit) Draw.Color(1, 0, 0, 1.0)
        else        Draw.Color(0, 1, 0, 0.2)

        Vec3f* v = t->triangle->vertices
        Draw.Tri3(v + 0, v + 1, v + 2)
      }
      --]]
      RenderState.PopDepthTest()
      RenderState.PopWireframe()
    end

    -- TEST : Visualize the optimized BSP tree
    if bsp.testNumber == 6 then
      if bsp.curNode.index == 0 then
        bsp.curNode = BSPDebug.GetNode(bsp.bsp, bsp.curNode, BSPNodeRel.Parent)
      end
      if Input.GetPressed(Button.Keyboard.Up) then
        bsp.curNode = BSPDebug.GetNode(bsp.bsp, bsp.curNode, BSPNodeRel.Parent)
      end
      if Input.GetPressed(Button.Keyboard.Left) then
        bsp.curNode = BSPDebug.GetNode(bsp.bsp, bsp.curNode, BSPNodeRel.Back)
      end
      if Input.GetPressed(Button.Keyboard.Right) then
        bsp.curNode = BSPDebug.GetNode(bsp.bsp, bsp.curNode, BSPNodeRel.Front)
      end

      BSPDebug.DrawNodeSplit(bsp.bsp, bsp.curNode)

      local rng = RNG.Create(bsp.seed ~= 0 and bsp.seed or rand())
      local sphere = ffi.new('Sphere')
      local p = rng:getVec3(-1.25, 1.25)
      sphere.px, sphere.py, sphere.pz = p.x, p.y, p.z
      sphere.r = rng:getUniformRange(0.05, 0.30)
      BSPDebug.DrawSphere(bsp.bsp, sphere)
      rng:free()
    end

    RenderState.PopDepthTest()
    RenderState.PopCullFace()
    RenderState.PopBlendMode()
  end

  do -- Draw (screen space)
    GLMatrix.ModeWV()
    GLMatrix.PushClear()
    GLMatrix.ModeP()
    GLMatrix.PushClear()

    local res = Vec2i()
    Viewport.GetSize(res)
    GLMatrix.Translate(-1.0, 1.0, 0.0)
    GLMatrix.Scale(2.0 / res.x, -2.0 / res.y, 1.0)

    RenderState.PushBlendMode(BlendMode.Alpha)
    Draw.ClearDepth(1)

    local padding = 10
    local size = 22
    local line = res.y - size - padding
    local buffer

    --cstr depthModeStr = depthModes[gen.depthMode] ? "True" : "False"
    --snprintf(buffer, (size_t) Array_GetSize(buffer), "Depth Test: %s", depthModeStr)
    buffer = format('Nodes: %i', sphereProf.nodes)
    gen.font:draw(buffer,
      2.0 * padding, line,
      1, 1, 1, 1
    )
    line = line - (size + padding)

    --cstr cullModeStr = ""
    --switch(cullModes[gen.cullMode]) {
    --  case CullFace.None:  cullModeStr = "CullFace.None"  break
    --  case CullFace.Back:  cullModeStr = "CullFace.Back"  break
    --  case CullFace.Front: cullModeStr = "CullFace.Front" break
    --}
    --snprintf(buffer, (size_t) Array_GetSize(buffer), "Culling: %s", cullModeStr)
    buffer = format('Leaves: %i', sphereProf.leaves)
    gen.font:draw(buffer,
      2.0 * padding, line,
      1, 1, 1, 1
    )
    line = line - (size + padding)

    --snprintf(buffer, (size_t) Array_GetSize(buffer), "Alpha: %.2f", alphaModes[gen.alphaMode])
    buffer = format('Triangles: %i', sphereProf.triangles)
    gen.font:draw(buffer,
      2.0 * padding, line,
      1, 1, 1, 1
    )
    line = line - (size + padding)

    -- TODO : Draw coordinate system. Need a coordinate transform
    --Draw.Axes(
    --  &Vec3( {res.x - 120 - 40, res.y - 120 - 40, 0.0} ),
    --  &Vec3f( {1.0, 0.0, 0.0} ),
    --  &Vec3f( {0.0, 1.0, 0.0} ),
    --  &Vec3f( {0.0, 0.0, 1.0} ),
    --  120.0, 1.0
    --)

    GLMatrix.ModeP()
    GLMatrix.Pop()
    GLMatrix.ModeWV()
    GLMatrix.Pop()
    RenderState.PopBlendMode()
  end

  RenderState.PopWireframe()
  RenderState.PopCullFace()
  RenderState.PopDepthTest()
  RenderState.PopBlendMode()

  GLMatrix.ModeWV()
  GLMatrix.Pop()
  GLMatrix.ModeP()
  GLMatrix.Pop()
end

function BSPTest:onExit ()
  local s   = State
  local gen = State.gen
  local obj = State.obj
  local bsp = State.bsp

  obj.mesh:free()
  bsp.bsp:free()
  gen.font:free()
end

return BSPTest
