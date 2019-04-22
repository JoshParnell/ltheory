local MathUtil = {}

--[[ TODO : Seems like this could be removed.
            1) I'm not sure why it's copying vectors.
            2) up is the zero vector when not supplied.
            3) Just use LookUp directly? ]]
-- CreateBasis(Vec3d dir, Vec3d pos)
-- return: Matrix
function MathUtil.CreateBasis(dir, pos, up)
  dir = Vec3f(dir.x, dir.y, dir.z)
  pos = Vec3f(pos.x, pos.y, pos.z)
  up = Vec3f(up.x, up.y, up.z)
  return Matrix.LookUp(pos, dir, up)
end

-- GenerateNumsThatAddToSum(int n, float desiredSum, RNG rng)
function MathUtil.GenerateNumsThatAddToSum(n, desiredSum, rng)
  local v = {}
  local u = {}
  local sum = 0
  for i = 1, n do
    v[i] = rng:getUniformRange(0, 1)
    u[i] = -log(v[i])
    sum = sum + u[i]
  end

  local p = {}
  local total = 0
  for i = 1, n do
    p[i] = (u[i] / sum) * desiredSum
    total = total + p[i]
  end

  return p
end

return MathUtil
