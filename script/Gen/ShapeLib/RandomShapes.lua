local BasicShapes = require('Gen.ShapeLib.BasicShapes')
local MathUtil    = require('Gen.MathUtil')
local Parametric  = require('Gen.ShapeLib.Parametric')
local Shape       = require('Gen.ShapeLib.Shape')
require('Gen.ShapeLib.Warp')

local RandomShapes = {}

-- RandomTorus (RNG rng, float r [optional])
function RandomShapes.RandomTorus (rng, r)
  r = r or 1
  local st = rng:choose({3, 4, 5, 6, 7, 8, 20, 30, 40})
  local sl = rng:choose({3, 4, 5, 6, 7, 8, 20, 30, 40})
  local thickness = rng:getUniformRange(5, 10)

  return BasicShapes.Torus(
    Parametric.Random(rng), Parametric.Random(rng),
    r, r/thickness, st, sl)
end

-- RandomTorusRadial (RNG rng, float r [optional])
-- only returns a torus with raidal symmetry
function RandomShapes.RandomTorusRadial (rng, r)
  r = r or 1
  local st = rng:choose({3, 4, 5, 6, 7, 8, 20, 30, 40})
  local sl = rng:choose({3, 4, 5, 6, 7, 8, 20, 30, 40})
  local thickness = rng:getUniformRange(5, 10)

  return BasicShapes.Torus(
    Parametric.RandomRadial(rng), Parametric.Random(rng),
    r, r/thickness, st, sl)
end

-- Random (RNG rng)
function RandomShapes.Random (rng)
  local type = rng:getInt(1, 7)

  if type == 1 then
    local res = rng:getInt(2, 10)
    return BasicShapes.Box(res)
  end

  if type == 2 then
    local st = rng:getInt(2, 10)
    local sl = rng:getInt(2, 10)
    return BasicShapes.Prism(st, sl)
  end

  if type == 3 then
    return BasicShapes.Icosahedron()
  end

  if type == 4 then
    local res = rng:choose({3, 4, 5, 6, 7, 8, 20, 30, 40})
    return BasicShapes.Ellipsoid(res)
  end

  if type == 5 then
    return BasicShapes.IrregularPrism(rng)
  end

  if type == 6 then
    return RandomShapes.RandomTorus(rng)
  end

  if type == 7 then
    return BasicShapes.Pyramid()
  end
end

return RandomShapes
