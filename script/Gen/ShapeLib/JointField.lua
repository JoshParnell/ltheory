local Shape = require('Gen.ShapeLib.Shape')
local Joint = require('Gen.ShapeLib.Joint')
require('Gen.ShapeLib.Warp')

-- JointFields are lists of joints
--   with helper functions to generate them.
-- They can live separately from a Shape/Mesh,
--   so they're useful for creating clusters of Shapes
--   without using a Shape's Joints as the basis.
local JointField = {}
JointField.__index = JointField

-- JointField (Joint joints[])
function JointField.Create ()
  return setmetatable({
    joints = {}
  }, JointField)
end

-- GenerateFromFunction (
--   function* fnp, [position function]
--   function* fnd, [direction function]
--   function* fnu, [up function]
--   function* fns, [scale function]
--   int n)         [number to generate]
function JointField:generateFromFunction (fnp, fnd, fnu, fns, n, step)
  local ind = #self.joints + 1
  for i = 1, n do
    local dir = fnd(i * step)
    local up = fnu(i * step)
    local valid = dir:length() > 1e-6 and up:length() > 1e-6
    assert(valid)
    if valid then
      dir:inormalize()
      up:inormalize()
      self.joints[ind] = Joint()
      self.joints[ind].pos = fnp(i * step)
      self.joints[ind].dir = dir
      self.joints[ind].up = up
      self.joints[ind].scale = fns(i * step)
      ind = ind + 1
    end
  end
  assert(self:valid())
  return self
end

-- Valid ()
function JointField:valid ()
  return #self.joints > 0
end

-- GenerateFromShape(Shape shape, function* scaleFn [optional])
function JointField:generateFromShape(shape, scaleFn)
  for i = 1, #shape.polys do
    local joint = Joint()
    if joint:generateFromPoly(shape, shape.polys[i]) then
      if scaleFn then
        joint.scale = scaleFn(joint.pos.x, joint.pos.y, joint.pos.z)
      end
      self.joints[#self.joints+1] = joint
    end
  end
  return self
end

function JointField:createShape (shape, joint)
  assert(#shape.polys > 0)
  if #shape.polys < 1 then return end
  assert(#self.joints > 0)
  if #self.joints < 1 then return shape end

  local final = Shape()
  for i = 1, #self.joints do
    local newShape = shape:clone()
    -- protection in case using bad joint
    if self.joints[i]:valid() and joint:valid() then
      newShape:attachJointToJoint(joint, self.joints[i])
      final:add(newShape)
    end
  end

  return final:center()
end

-- ToString ()
function JointField:__tostring ()
  return format('JointField (# joints: %d)', #self.joints)
end

return JointField.Create
