-- objects
local Shape       = require('Gen.ShapeLib.Shape')
-- shapes
local BasicShapes   = require('Gen.ShapeLib.BasicShapes')
local RandomShapes  = require('Gen.ShapeLib.RandomShapes')
local Parametric    = require('Gen.ShapeLib.Parametric')
local Scaffolding   = require('Gen.ShapeLib.Scaffolding')
-- warps
require('Gen.ShapeLib.Warp')

local Style = {}
Style.__index = Style

-- Style
--   favoredShapes: list of Shapes
--   favoredWarps: list of Shape member function*s for warps
--   rng: cached RNG
setmetatable(Style, {
  __call = function(T)
    return setmetatable({
      favoredShapes = {},
      favoredWarps  = {},
      favoredParametric = {},
      favoredParametricSafe = {},
      favoredScaffolding = {},
      rng = nil
    }, Style)
  end
})

-- Mostly for testing purposes,
-- since there are currently no factions personalities
-- being passed to the generators yet
function Style:generateRandom (rng)
  assert(rng)
  self.rng = rng

  -- basic properties
  -- IMPORTANT: many advanced properties require these!
  self.favoredParametric[1] = Parametric.Random(self.rng)
  self.favoredParametricSafe[1] = self:randomParametricSafe()

  -- advanced properties
  self.favoredShapes[1] = self:randomShape()
  self.favoredWarps[1] = self:randomWarp()
  self.favoredScaffolding[1] = self:randomScaffolding()

  return self
end

-- GET FUNCTIONS
-- All have a high chance of returning a favored function
-- & a small chance of returning a completely random function

-- GetShape ()
function Style:getShape ()
  local c = self.rng:getUniform()
  if c < 0.9 then
    return self.rng:choose(self.favoredShapes)
  end
  return self:randomShape()
end

-- GetWarp ()
-- Call with warpFunction(shape, rng)
function Style:getWarp ()
  local c = self.rng:getUniform()
  if c < 0.9 then
    return self.rng:choose(self.favoredWarps)
  end
  return self:randomWarp()
end

-- GetParametric ()
function Style:getParametric ()
  local c = self.rng:getUniform()
  if c < 0.9 then
    return self.rng:choose(self.favoredParametric)
  end
  return Parametric.Random(self.rng)
end

-- GetSafeParametric ()
function Style:getParametricSafe ()
  local c = self.rng:getUniform()
  if c < 0.9 then
    return self.rng:choose(self.favoredParametricSafe)
  end
  return self:randomParametricSafe()
end

-- GetTorus ()
-- @LINDSEY TODO informed by res!!!
function Style:getTorus ()
  local st = self.rng:choose({3, 4, 5, 6, 7, 8, 20, 30, 40})
  local sl = self.rng:choose({3, 4, 5, 6, 7, 8, 20, 30, 40})
  local thickness = self.rng:getUniformRange(5, 10)

  return BasicShapes.Torus(
    self:getParametric(), self:getParametric(),
    1, 1/thickness, st, sl
  )
end

-- GetTorusSafe ()
function Style:getTorusSafe ()
  local st = self.rng:choose({4, 5, 6, 7, 8, 20, 30, 40})
  local sl = self.rng:choose({4, 5, 6, 7, 8, 20, 30, 40})
  local thickness = self.rng:getUniformRange(5, 10)

  return BasicShapes.Torus(
    self:getParametricSafe(), self:getParametricSafe(),
    1, 1/thickness, st, sl
  )
end

-- GetScaffolding ()
function Style:getScaffolding ()
  local c = self.rng:getUniform()
  if c < 0.9 then
    return self.rng:choose(self.favoredScaffolding)
  end
  return self:randomScaffolding()
end

-- RANDOM FUNCTIONS
-- Generate random warps, shapes, etc,
-- that are intelligently informed by the properties
-- of the style

-- @LINDSEY TODO: make this smarter to take style into consideration
-- for ex, Bevel more useful for smooth, round styles
-- & Stellate more useful for aggressive styles
function Style:randomWarp ()
  local warpType = self.rng:getInt(1, 2)

  if warpType == 1 then
    local ex = self.rng:getExp() * 0.5
    return function(shape) return shape:extrude(ex) end
  end

  if warpType == 2 then
    local s = self.rng:getExp() * 0.5
    return function(shape) return shape:stellate(s) end
  end
end

-- @LINDESY TODO: make this more intelligenty informed by more properties
function Style:randomShape ()
  local type = self.rng:getInt(1, 6)

  if type == 1 then
    local res = self.rng:getInt(2, 10)
    return BasicShapes.Box(res)
  end

  if type == 2 then
    local st = self.rng:getInt(2, 10)
    local sl = self.rng:getInt(2, 10)
    return BasicShapes.Prism(st, sl)
  end

  if type == 3 then
    return BasicShapes.Icosahedron()
  end

  if type == 4 then
    local res = self.rng:choose({3, 4, 5, 6, 7, 8, 20, 30, 40})
    return BasicShapes.Ellipsoid(res)
  end

  if type == 5 then
    return BasicShapes.IrregularPrism(self.rng)
  end

  if type == 6 then
    return BasicShapes.Pyramid()
  end
end

-- @LINDESY TODO: make this more intelligenty informed by more properties
function Style:randomParametricSafe ()
  local type = self.rng:getInt(1, 3)

  if type == 1 then
    return Parametric.Circle()
  end

  if type == 2 then
    return Parametric.Ellipse()
  end

  if type == 3 then
    return Parametric.Rectangle()
  end
end

-- will have more scaffolding clusters in the future!
function Style:randomScaffolding()
  return Scaffolding.BasicScaffoldingBlock()
end

return Style
