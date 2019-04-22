-- objects
local Joint        = require('Gen.ShapeLib.Joint')
local JointField   = require('Gen.ShapeLib.JointField')
local Shape        = require('Gen.ShapeLib.Shape')
local Style        = require('Gen.ShapeLib.Style')
-- shapes
local BasicShapes  = require('Gen.ShapeLib.BasicShapes')
local Cluster      = require('Gen.ShapeLib.Cluster')
local Scaffolding  = require('Gen.ShapeLib.Scaffolding')
local Module       = require('Gen.ShapeLib.Module')
local RandomShapes = require('Gen.ShapeLib.RandomShapes')
-- local ShipWarps    = require('Gen.ShipWarps')
require('Gen.ShapeLib.Warp')
-- util
local MathUtil     = require('Gen.MathUtil')
local Parametric   = require('Gen.ShapeLib.Parametric')

local ShipFighter = {}

-- SETTINGS [

Settings.addBool('genship.override', 'Override Generator', true)

Settings.addEnum('genship.type', 'Ship Type', 1, {
  'Standard',
  'Surreal'
})

Settings.addEnum('genship.global.surface', 'Surface Detail', 5, {
  'Random',
  'None',
  'Spikes',
  'Smooth Corners',
  'Extrude',
  'Greeble',
})

Settings.addFloat('genship.global.surfaceAmt',  'Surface Detail Amount', 0.2, 0.01, 1.0)
Settings.addBool('genship.global.randDetail',   'Add Random Detail', false)
Settings.addFloat('genship.surreal.wingLength', 'Wing Length', 2.0, 0.01, 4)
Settings.addFloat('genship.surreal.wingWidth',  'Wing Width', 1.0, 0.01, 4)
Settings.addFloat('genship.surreal.wingHeight', 'Wing Height', 0.5, 0.01, 4)
Settings.addFloat('genship.surreal.numWings',   'Num Wings', 3, 1, 5)
Settings.addFloat('genship.surreal.hullRes',    'Hull Smoothness', 6, 3, 30)
Settings.addFloat('genship.surreal.hullLength', 'Hull Length', 2.0, 0.5, 4.0)
Settings.addFloat('genship.surreal.hullWidth',  'Hull Width', 1.0, 0.5, 4.0)
Settings.addFloat('genship.surreal.hullHeight', 'Hull Height', 1.0, 0.5, 4.0)
Settings.addEnum('genship.surreal.wingType',    'Wing Type', 1, {
  'Random',
  'Box',
  'Irregular',
  'Prism',
  'Cylinder',
  'Torus',
  'Standard',
  'Tie-Fighter',
})
Settings.addEnum('genship.surreal.bodyType', 'Hull Type', 1, {
  'Random',
  'Prism',
  'Irregular',
  'Sphere',
  'Box',
})

Settings.addEnum( 'genship.standard.hullType',      'Hull Type', 1, {'Random', 'Classic', 'Round',})
Settings.addFloat('genship.standard.hullRes',       'Hull Smoothness', 6, 3, 30)
Settings.addFloat('genship.standard.hullPoint',     'Hull Pointiness', 0.5, 0.05, 2.0)
Settings.addFloat('genship.standard.hullRadius',    'Hull Radius', 1.0, 0.5, 4.0)
Settings.addFloat('genship.standard.hullLength',    'Hull Length', 1.0, 0.5, 4.0)
Settings.addEnum( 'genship.standard.wingType',      'Wing Type', 1, {'Random', 'Classic', 'Tie',})
Settings.addFloat('genship.standard.numWings',      'Num Wings', 2, 0, 8)
Settings.addFloat('genship.standard.wingLength',    'Wing Length', 2.5, 0.5, 5.0)
Settings.addFloat('genship.standard.wingWidth',     'Wing Width', 0.5, 0.05, 5.0)
Settings.addFloat('genship.standard.wingDist',      'Wing Distance', 0.5, 0.0, 5.0)
Settings.addFloat('genship.standard.wingPoint',     'Wing Pointiness', 0.5, 0.05, 2.0)
Settings.addBool( 'genship.standard.doubleTieWing', 'Tie Double Wing', true)
Settings.addEnum( 'genship.standard.tieWingShape',  'Tie Wing Shape', 1, {
  'Random',
  'Prism',
  'Round',
  'Irregular',
  'Triangle',
})

-- ] SETTINGS

-------------------------------------

-- WARPS [

function ShipFighter.SurfaceDetail(rng, shape)
  local type = Settings.get('genship.global.surface')
  if type == 1 or Settings.get('genship.override') == false then
    if rng:chance(0.05) then
      local s = rng:getUniformRange(0.05, 0.3)
      shape:stellate(s)
      if rng:chance(0.5) then
        shape:extrude(0.2)
      end
    elseif rng:chance(0.05) then
      shape:extrude(0.2, Vec3d(
        rng:getUniformRange(0.05, 0.5),
        rng:getUniformRange(0.05, 0.5),
        rng:getUniformRange(0.05, 0.5))
      )
    elseif rng:chance(0.05) then
      shape:greeble(rng,
        1, -- tessellations
        0.01, 0.03 -- low, high size
      )
    else
      -- never bevel other details- looks uggo
      -- but always bevel if no other details applied- sharp corners are bleh
      shape = shape:bevel(rng:getUniformRange(0.1, 1.0))
    end
  else
    local amt = Settings.get('genship.global.surfaceAmt')
    -- 2 = none
    if type == 3 then
      shape:stellate(amt)
    elseif type == 4 then
      shape = shape:bevel(amt)
    elseif type == 5 then
      shape:extrude(amt)
    elseif type == 6 then
      shape:greeble(rng, 1, 0.01, 0.03, amt)
    end
  end
  return shape
end

-- ] WARPS

-------------------------------------

-- PARTS [

function ShipFighter.EngineSingle(rng)
  local res = rng:choose({3, 4, 6, 8, 10, 20})
  local engine = BasicShapes.Prism(2, res)

  local r = rng:getUniformRange(0.1, 0.3)

  engine:scale(r, r, r)
  engine:rotate(0, math.pi/2, 0)

  local aabb = engine:getAABB()
  local z = math.abs(aabb.upper.z - aabb.lower.z)
  engine:center(0, 0, -z/2.0)

  -- extrude forward-facing face so that it looks more 'attached' to the ship
  local pi = engine:getPolyWithNormal(Vec3d(0, 0, 1))
  local t = math.pi*1.05
  local l = 0.1
  r = 0.25
  engine:extrudePoly(pi, l,
            Vec3d(r, r, r),
            Vec3d(0, math.sin(t), -math.cos(t)))

  return engine:finalize()
end

function ShipFighter.TurretSingle(rng)
  local res = rng:choose({3, 4, 6, 8, 10, 20})
  local r = rng:getUniformRange(0.1, 0.3)
  local turret = BasicShapes.Prism(2, res)
  turret:scale(r, r, r)
  turret:rotate(0, math.pi/2, 0)

  -- extrude to create gun shape
  local pi = turret:getPolyWithNormal(Vec3d(0, 0, 1))
  local t = math.pi*1.05
  local l = rng:getUniformRange(0.05, 0.5)
  r = rng:getUniformRange(0.05, 0.5)
  turret:extrudePoly(pi, l,
            Vec3d(r, r, r),
            Vec3d(0, math.sin(t), -math.cos(t)))

  local aabb = turret:getAABB()
  local z = math.abs(aabb.upper.z - aabb.lower.z)
  turret:center(0, 0, -z/2.0)

  -- extrude backward-facing face so that it looks more 'attached' to the ship
  local pi = turret:getPolyWithNormal(Vec3d(0, 0, -1))
  local t = math.pi*1.05
  local l = 0.1
  r = 0.25
  turret:extrudePoly(pi, l,
            Vec3d(r, r, r),
            Vec3d(0, math.sin(t), math.cos(t)))

  turret:center()
  return turret:finalize()
end

function ShipFighter.WingMounts(rng, bodyAABB, res)
  local mount = BasicShapes.Prism(2, res)
  mount:rotate(0, math.pi/2, 0)
  local r = Math.Clamp(rng:getExp()*0.2 + 0.5, 0.2, 1)
  local l = rng:getUniformRange(0.2, math.abs(bodyAABB.upper.z - bodyAABB.lower.z))
  local gunScale = Vec3d(r, r, l)
  mount:scale(gunScale.x, gunScale.y, gunScale.z)

  local xPos
  if Settings.get('genship.override') then
    xPos = Settings.get('genship.standard.wingDist')
  else
    xPos = bodyAABB.lower.x
  end
  mount:translate(xPos, 0, 0)

  mount = ShipFighter.SurfaceDetail(rng, mount)

  local mount2 = mount:clone()
  mount2:mirror(true, false, false)
  mount:add(mount2)

  return mount
end

function ShipFighter.HullStandard(rng)
  -- settings
  local length, cxy, r, res
  if Settings.get('genship.override') then
    r = Settings.get('genship.standard.hullRadius')
    length = Settings.get('genship.standard.hullLength')
    local c = Settings.get('genship.standard.hullPoint')
    cxy = {c, c}
    res = math.floor(Settings.get('genship.standard.hullRes'))
  else
    r = 1
    length = rng:getUniformRange(0.5, 3)
    cxy = {rng:getUniformRange(0.1, 0.5), rng:getUniformRange(0.1, 0.5)}
    res = rng:choose({3, 4, 5, 6, 8, 10, 20, 24, 28, 30})
  end

  -- basic shape
  local shape, type

  local type = Settings.get('genship.standard.hullType')
  if type == 1 or Settings.get('genship.override') == false then
    local dist = Distribution()
    dist:add(2, 0.85) -- standard prism
    dist:add(3, 0.15) -- sphere
    type = dist:sample(rng)
  end

  if type == 2 then -- standard prism
    shape = BasicShapes.Prism(2, res)
    shape:rotate(0, math.pi * 0.5, 0)
    if res % 2 ~= 0 then
      shape:rotate(0, 0, math.pi * 0.5) -- for bilateral symmetry
    end

    local pi = shape:getPolyWithNormal(Vec3d(0, 0, 1))
    local t = math.pi
    shape:extrudePoly(pi, length,
              Vec3d(cxy[1], cxy[2], 1.0),
              Vec3d(0, math.sin(t), -math.cos(t)))

    local back = shape:getPolyWithNormal(Vec3d(0, 0, -1))
    shape:extrudePoly(back, 0.3, Vec3d(0.5, 0.5, 0.5), Vec3d(0, math.sin(t), math.cos(t)))
  elseif type == 3 then -- sphere
    shape = BasicShapes.Ellipsoid(res)
    if res % 2 ~= 0 then
      shape:rotate(math.pi*0.5, 0, 0)
    end
    shape:scale(1, 1, length)
  end

  -- scaling & detail
  shape:scale(r, r, 1)

  if Settings['genship.override'] then
    shape = ShipFighter.SurfaceDetail(rng, shape)
  end

  return shape
end

function ShipFighter.HullSurreal(rng, res)
  local shape

  local hullSize
  if Settings.get('genship.override') then
    res = math.floor(Settings.get('genship.surreal.hullRes'))

    hullSize = Vec3d(
      Settings.get('genship.surreal.hullWidth'),
      Settings.get('genship.surreal.hullHeight'),
      Settings.get('genship.surreal.hullLength')
    )
  else
    hullSize = Vec3d(
      Math.Clamp(rng:getGaussian()*0.8 + 1.2, 0.5, 4.0),
      Math.Clamp(rng:getGaussian()*0.2 + 1.0, 0.5, 3.0),
      rng:getUniformRange(0.5, 3)
    )
  end

  -- basic shape type
  local bodyType = Settings.get('genship.surreal.bodyType')
  if bodyType == 1 or Settings.get('genship.override') == false then
    local dist = Distribution()
    dist:add(2, 0.25)
    dist:add(3, 0.25)
    dist:add(4, 0.25)
    dist:add(5, 0.25)
    bodyType = dist:sample(rng)
  end

  if bodyType == 2 then
    shape = BasicShapes.Prism(2, res)
    -- extrude to make hull shape
    shape:rotate(0, math.pi/2, 0)
    if res == 3 then
      shape:rotate(0, 0, math.pi*0.5)
    end
    local pi = shape:getPolyWithNormal(Vec3d(0, 0, 1))
    shape:extrudePoly(pi, hullSize.z,
              Vec3d(rng:getUniformRange(0.1, 1.0),
                  rng:getUniformRange(0.1, 1.0),
                  rng:getUniformRange(0.1, 0.5)),
              Vec3d(0, 0, 1))
    -- create 'back' portion
    local back = shape:getPolyWithNormal(Vec3d(0, 0, -1))
    shape:extrudePoly(back, 0.3, Vec3d(0.5, 0.5, 0.5), Vec3d(0, 0, -1))
  elseif bodyType == 3 then
    shape = BasicShapes.IrregularPrism(rng)
    shape:rotate(math.pi/2, math.pi/2, 0)
    -- scale to make hull shape
    shape:scale(1, 1, hullSize.z)
  elseif bodyType == 4 then
    shape = BasicShapes.Ellipsoid(res)
  else
    shape = BasicShapes.Box()
  end

  -- warps
  shape:scale(hullSize.x, hullSize.y, 1.0)

  if rng:chance(0.5) then
    local yAmt = rng:getUniformRange(0.2, 2.0)
    shape:warp(
      function(v)
        v.y = v.y + v.y*v.y*yAmt
      end
    )
  end

  shape = ShipFighter.SurfaceDetail(rng, shape)

  return shape
end

function ShipFighter.WingsSurreal(rng, bodyAABB, ship)
  local wings = Shape()

  local n
  if Settings.get('genship.override') then
    n = math.floor(Settings.get('genship.surreal.numWings'))
  else
    n = rng:getInt(1, 5)
  end

  for i = 1, n do
    -- wing shape type
    local baseWing

    -- shape type
    local type = Settings.get('genship.surreal.wingType')
    if type == 1 or Settings.get('genship.override') == false then
      local dist = Distribution()
      dist:add(2, 1)
      dist:add(3, 1)
      dist:add(4, 1)
      dist:add(5, 1)
      dist:add(6, 0.5)
      dist:add(7, 0.5)
      dist:add(8, 0.5)
      type = dist:sample(rng)
    end

    if type == 2 then
      baseWing = BasicShapes.Box(0)
      baseWing:scale(0.1, 0.2, 0.5)
    elseif type == 3 then
      baseWing = BasicShapes.IrregularPrism(rng)
      baseWing:scale(1.5, 1, 1.5)
    elseif type == 4 then
      baseWing = BasicShapes.Prism(2, rng:choose({5,6,7,8,10}))
    elseif type == 5 then
      baseWing = BasicShapes.Prism(2, 20)
    elseif type == 6 then
      baseWing = RandomShapes.RandomTorus(rng)
    elseif type == 7 then
      baseWing = ShipFighter.WingsStandard(rng, bodyAABB)
    elseif type == 8 then
      baseWing = ShipFighter.WingsTie(rng)
    end

    if type == 7 or type == 8 then
      wings:add(baseWing)
      break
    end

    local l, w, h
    if Settings.get('genship.override') then
      l = Settings.get('genship.surreal.wingLength')
      w = Settings.get('genship.surreal.wingWidth')
      h = Settings.get('genship.surreal.wingHeight')
    else
      l = rng:getUniformRange(0.5, 3.0)
      w = Math.Clamp(rng:getExp() + 1, 0.1, 3)
      h = Math.Clamp(rng:getExp()*0.2 + 0.8, 0.1, 2)
    end

    -- extrude (x) to make wing shape
    local pi1 = baseWing:getPolyWithNormal(Vec3d(1, 0, 0))
    baseWing:extrudePoly(pi1, l, Vec3d(1, rng:getUniformRange(0.1, 0.5), 1))

    -- random scaling (y, z)
    baseWing:scale(1, h, w)
    baseWing:tessellate(rng:getInt(0,2))

    -- clone BEFORE adding decoration to preserve bilateral symmetry
    local wing1 = baseWing:clone()

    -- decoration
    if Settings.get('genship.override') == false or
       (Settings.get('genship.override') and Settings.get('genship.global.randDetail')) then
      local n = rng:getInt(0, 3)
      for i = 0, n do
        local ind = rng:getInt(1, #wing1.polys)
        wing1:extrudePoly(ind, rng:getUniformRange(0.2, 1.0))
      end
    end

    if type ~= 6 then -- often crash or look super uggo on torus
      wing1 = ShipFighter.SurfaceDetail(rng, wing1)
    end

    -- rotate
    local roll = rng:getUniformRange(math.pi* -0.5, math.pi * 0.5)
    local yaw = rng:getUniformRange(0.0, math.pi*0.5)
    wing1:rotate(yaw, 0, roll)

    -- translate
    local posShip = ship.verts[ship:getRandomPoly(rng)[1]]
    local posWing = wing1.verts[wing1:getRandomPoly(rng)[1]]
    if posWing == nil then
      print("ShipFighter.WingsSurreal: bad poly on wing")
      posWing = Vec3d(0, 0, 0)
    end
    if posShip == nil then
      print("ShipFighter.WingsSurreal: bad poly on ship")
      posShip = Vec3d(0, 0, 0)
    end
    local x = posShip.x - posWing.x
    local y = posShip.y - posWing.y
    local z = posShip.z - posWing.z
    wing1:translate(x, y, z)

    -- choose number of wings in this set
    local numWings
    if type ~= 6 then
      local dist = Distribution()
      dist:add(2, 0.50)
      dist:add(3, 0.25)
      dist:add(4, 0.25)
      numWings = dist:sample(rng)
    else
      -- tori (type 6) don't look good in odd groups
      -- bc of no guaruntee for bilateral symmetery
      local dist = Distribution()
      dist:add(2, 0.65)
      dist:add(4, 0.35)
      numWings = dist:sample(rng)
    end

    -- clone to create second wing
    local wing2 = wing1:clone()
    wing2:mirror(true, false, false)

    if numWings == 2 then
      wings:add(wing1):add(wing2)
    elseif numWings == 4 then
      wings:add(wing1):add(wing2)
      local pair2 = wings:clone()
      pair2:mirror(false, true, false)
      wings:add(pair2)
    elseif numWings == 3 then
      local wing3 = baseWing:clone()
      local dir = rng:choose({1, -1})
      wing3:rotate(0, 0, dir*math.pi*0.5)
      wing3:translate(0, y, z)
      wings:add(wing1):add(wing2):add(wing3)
    end
  end

  return wings
end

function ShipFighter.WingsStandard(rng, bodyAABB)
  local shape = Shape()

  local n
  if Settings.get('genship.override') then
    n = math.floor(Settings.get('genship.standard.numWings'))
  else
    n = rng:getUniformRange(1, 3)
  end

  for i = 1, n do
    local wing1 = BasicShapes.Box(0)

    local l, w, point
    if Settings.get('genship.override') then
      l = Settings.get('genship.standard.wingLength')
      w = Settings.get('genship.standard.wingWidth')
      point = Settings.get('genship.standard.wingPoint')
    else
      l = rng:getUniformRange(0.5, 3.0)
      w = rng:getUniformRange(0.5, 3.0)
      point = rng:getUniformRange(0.05, 1.0)
    end

    -- scale & extrude to create shape
    wing1:scale(0.1, 0.2, w)
    local pi1 = wing1:getPolyWithNormal(Vec3d(1, 0, 0))
    wing1:extrudePoly(pi1, l, Vec3d(1.0,
      rng:getUniformRange(0.05, 0.5), -- thin-ness
      point)
    )

    -- make tips pointy
    pi1 = wing1:getPolyWithNormal(Vec3d(1, 0, 0))
    wing1:extrudePoly(pi1, 0.2, Vec3d(1, 0.1, 1))

    -- winglets
    if rng:chance(0.5) then
      local winglet = wing1:clone():scale(0.5, 0.5, 0.5)
      local wingAABB = wing1:getAABB()
      winglet:rotate(0, 0, rng:getUniformRange(0, math.pi))
      winglet:center(wingAABB.upper.x, 0, 0)
      wing1:add(winglet)
    end

    if Settings.get('genship.override') then
      wing1 = ShipFighter.SurfaceDetail(rng, wing1)
    end

    -- rotate & position
    local xPos
    if Settings.get('genship.override') then
      xPos = Settings.get('genship.standard.wingDist')
    else
      xPos = bodyAABB.upper.x
    end

    local roll = rng:getUniformRange(math.pi* -0.5, math.pi * 0.5)
    local yaw = rng:getUniformRange(0.0, math.pi*0.5)
    wing1:rotate(yaw, 0, roll)
    wing1:translate(xPos, 0, 0)

    -- decoration
    wing1:tessellate(rng:getInt(0,2))
    if Settings.get('genship.override') == false or
       (Settings.get('genship.override') and Settings.get('genship.global.randDetail')) then
      wing1:extrudePoly(rng:getInt(1, #wing1.polys), rng:getUniformRange(0.2, 1.0))
    end

    local wing2 = wing1:clone()
    wing2:mirror(true, false, false)

    shape:add(wing1)
    shape:add(wing2)
  end

  return shape
end

function ShipFighter.WingsTie (rng)
  local shape = Shape()

  -- base shape
  local type = Settings.get('genship.standard.tieWingShape')
  if type == 1 or Settings.get('genship.override') == false then
    type = rng:choose({2, 3, 4, 5})
  end

  local wing
  if type == 2 then
    wing = BasicShapes.Prism(2, rng:choose({4,5,6,8}))
  elseif type == 3 then
    wing = BasicShapes.Prism(2, 30)
  elseif type == 4 then
    wing = BasicShapes.IrregularPrism(rng)
    wing:scale(1.5, 1, 1.5)
  elseif type == 5 then
    wing = BasicShapes.IrregularPrism(rng, 2, 3)
  end

  -- make wide, flat shape
  local r, split, dist
  if Settings.get('genship.override') then
    r = Settings.get('genship.standard.wingLength')
    dist = Settings.get('genship.standard.wingDist')
    split = Settings.get('genship.standard.doubleTieWing')
  else
    r = rng:getUniformRange(0.5, 3.0)
    dist = rng:getExp()*0.25 + 1.5
    split = type == 5 -- by default, only split triangle shape
  end
  wing:scale(r, 0.1, r)

  -- decoration
  if Settings.get('genship.override') == false or
       (Settings.get('genship.override') and Settings.get('genship.global.randDetail')) then
    local ndist = Distribution()
    ndist:add(0, 0.30)
    ndist:add(1, 0.20)
    ndist:add(2, 0.20)
    ndist:add(3, 0.20)
    ndist:add(10, 0.10)
    local n = ndist:sample(rng)
    for i = 0, n do
      local ind = rng:getInt(1, #wing.polys)
      local length = 0.5
      local norm = wing:getFaceNormal(wing.polys[ind])
      if norm.y ~= 1 and norm.y ~= -1 then
        -- don't increase width of wing
        length = rng:getUniformRange(0.1, 1.0)
      end
      wing:extrudePoly(ind, length)
    end
  end

  -- double wing
  if split then
    local wingHalf = wing:clone()
    wingHalf:mirror(false, false, true)
    local gap = r*0.5 + rng:getUniformRange(0.1, 0.5)
    wingHalf:translate(0, 0, -gap)
    wing:add(wingHalf)
    -- add connector between the two wings
    wing:center()
    local bar = BasicShapes.Box()
    bar:scale(rng:getUniformRange(0.05, 0.5), 0.05, gap*0.5)
    wing:add(bar)
  end

  -- rotate
  wing:rotate(math.pi*0.5, 0, math.pi*0.5)
  -- place
  wing:translate(dist, 0, 0)

  -- add connection
  local connector = BasicShapes.Prism(2, 6)
  connector:rotate(0, 0, math.pi*0.5)
  local cr = 1.0
  connector:scale(0.1, cr, cr)
  local pi = connector:getPolyWithNormal(Vec3d(1, 0, 0))
  connector:extrudePoly(pi, dist, Vec3d(1, 0.5, 0.5))
  wing:add(connector)

  -- wing decoration
  wing = ShipFighter.SurfaceDetail(rng, wing)

  -- wing warping
  local wingAABB = wing:getAABB()
  local yMin = wingAABB.lower.y
  local yMax = wingAABB.upper.y
  if rng:chance(0.5) then
    local dir = rng:choose({1, -1})
    local amt = rng:getUniformRange(0.1, 0.5)
    wing:warp(
      function(v)
        local y = (v.y - yMin)/(yMax - yMin)
        y = Math.Lerp(0, math.pi, y)
        v.x = v.x + math.sin(y)*dir*amt
      end
    )
  end

  -- add second wing
  local wing2 = wing:clone()
  wing2:mirror(true, false, false)
  shape:add(wing):add(wing2)
  return shape
end


-- ] PARTS

-------------------------------------

-- SHIPS [

function ShipFighter.Surreal (rng)
  local res = rng:choose({3, 4, 6, 8, 10, 20})
  local shape = ShipFighter.HullSurreal(rng, res)

  -- other parts
  local bodyAABB = shape:getAABB()
  shape:add(ShipFighter.WingsSurreal(rng, bodyAABB, shape))

  -- shape = ShipWarps.CurveWarps(rng, shape)
  local rcpRadius = 1.0 / shape:getRadius()
  shape:scale(rcpRadius, rcpRadius, rcpRadius)

  return shape:finalize()
end

function ShipFighter.Standard (rng)
  -- hull
  local res = rng:choose({3, 4, 6, 8, 10, 20})
  local shape = ShipFighter.HullStandard(rng)

  local bodyAABB = shape:getAABB()

  -- wings
  local wingType = Settings.get('genship.standard.wingType')
  if wingType == 1 or Settings.get('genship.override') == false then
    local dist = Distribution()
    dist:add(2, 0.75) -- standard
    dist:add(3, 0.25) -- tie
    wingType = dist:sample(rng)
  end
  if wingType == 2 then
    shape:add(ShipFighter.WingsStandard(rng, bodyAABB))
  elseif wingType == 3 then
    shape:add(ShipFighter.WingsTie(rng, bodyAABB))
  end

  -- other parts
  shape:add(ShipFighter.WingMounts(rng, bodyAABB, res))

  -- final warps
  -- shape = ShipWarps.CurveWarps(rng, shape)
  shape = shape:bevel(rng:getUniformRange(0.1, 0.8))
  local rcpRadius = 3.0 / shape:getRadius()
  shape:scale(rcpRadius, rcpRadius, rcpRadius)

  return shape:finalize()
end

-- ] SHIPS

return ShipFighter
