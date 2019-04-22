local MathUtil = require('Gen.MathUtil')

local Joint = {}
Joint.__index = Joint

-- Joint (Vec3d pos, Vec3d dir, Vec3d scale)
function Joint.Create ()
  return setmetatable({
    pos   = nil,
    dir   = nil,
    up    = nil,
    scale = nil,
  }, Joint)
end

-- GenerateJointFromTri (Shape shape, int[] poly)
-- Creates a joint with:
-- pos = center of tri
-- dir = surface normal
-- scale = (1,1,1); intended to be creatively used by caller
function Joint:generateFromPoly (shape, poly)
  local normal = shape:getFaceNormal(poly)
  -- protect against bad tris
  if normal:length() > 1e-6 then
    self.pos = shape:getFaceCenter(poly)
    self.dir = normal
    self.up = (shape:getVertex(poly[1]) - self.pos):normalize()
    self.scale = Vec3d(1,1,1)
    assert(self:valid())
    return true
  end
  return false
end

function Joint:valid ()
  return self.dir:length() > 1e-6 and self.up:length() > 1e-6
end

-- ToString ()
function Joint:__tostring ()
  return format("Joint pos%s dir%s up%s scale%s",
    tostring(self.pos), tostring(self.dir), tostring(self.up), tostring(self.scale)
  )
end

return Joint.Create
