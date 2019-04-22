local Shape       = require('Gen.ShapeLib.Shape')
local BasicShapes = require('Gen.ShapeLib.BasicShapes')
require('Gen.ShapeLib.Warp')
local Scaffolding = {}

-- BasicScaffoldingBlock (int resolution [optional],
--                        float bar width [optional])
function Scaffolding.BasicScaffoldingBlock (res, bar)
  res = res or 0
  bar = bar or 0.05
  local side = 0.5
  local hs = side --/ 2.0 -- half side length
  local hyp = sqrt(side*side + side*side) -- hypotenuse
  local rot = math.pi/4.0 -- rotation

  local self = Shape()

  self:add(
    -- Box frame
    -- vertical frame
    -- (adding bar width to length of bar fills in gaps in corners)
    BasicShapes.Box(res):scale(bar, side + bar, bar):translate(hs, 0, hs),
    BasicShapes.Box(res):scale(bar, side + bar, bar):translate(hs, 0, -hs),
    BasicShapes.Box(res):scale(bar, side + bar, bar):translate(-hs, 0, -hs),
    BasicShapes.Box(res):scale(bar, side + bar, bar):translate(-hs, 0, hs),
    -- bottom frame
    BasicShapes.Box(res):scale(bar, bar, side):translate(hs, -hs, 0),
    BasicShapes.Box(res):scale(side, bar, bar):translate(0, -hs, hs),
    BasicShapes.Box(res):scale(side, bar, bar):translate(0, -hs, -hs),
    BasicShapes.Box(res):scale(bar, bar, side):translate(-hs, -hs, 0),
    -- top frame
    BasicShapes.Box(res):scale(bar, bar, side):translate(hs, hs, 0),
    BasicShapes.Box(res):scale(side, bar, bar):translate(0, hs, hs),
    BasicShapes.Box(res):scale(side, bar, bar):translate(0, hs, -hs),
    BasicShapes.Box(res):scale(bar, bar, side):translate(-hs, hs, 0),
    -- Xs
    -- side face 1
    BasicShapes.Box(res):scale(bar, hyp, bar):rotate(0,rot,0):translate(hs, 0, 0),
    BasicShapes.Box(res):scale(bar, hyp, bar):rotate(0,-rot,0):translate(hs, 0, 0),
    -- side face 2
    BasicShapes.Box(res):scale(bar, hyp, bar):rotate(0,rot,0):translate(-hs, 0, 0),
    BasicShapes.Box(res):scale(bar, hyp, bar):rotate(0,-rot,0):translate(-hs, 0, 0),
    -- side face 3
    BasicShapes.Box(res):scale(bar, hyp, bar):rotate(0,0,rot):translate(0, 0, -hs),
    BasicShapes.Box(res):scale(bar, hyp, bar):rotate(0,0,-rot):translate(0, 0, -hs),
    -- side face 4
    BasicShapes.Box(res):scale(bar, hyp, bar):rotate(0,0,rot):translate(0, 0, hs),
    BasicShapes.Box(res):scale(bar, hyp, bar):rotate(0,0,-rot):translate(0, 0, hs),
    -- top face
    BasicShapes.Box(res):scale(hyp, bar, bar):rotate(rot,0,0):translate(0, hs, 0),
    BasicShapes.Box(res):scale(hyp, bar, bar):rotate(-rot,0,0):translate(0, hs, 0),
    -- bottom face
    BasicShapes.Box(res):scale(hyp, bar, bar):rotate(rot,0,0):translate(0, -hs, 0),
    BasicShapes.Box(res):scale(hyp, bar, bar):rotate(-rot,0,0):translate(0, -hs, 0)
  )

  return self
end

return Scaffolding
