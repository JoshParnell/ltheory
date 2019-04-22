local function defineVec3 (t, mt)
  local Vec3 = mt.__call

  function t.Identity ()
    return (Vec3(0, 0, 0))
  end
end

local function defineVec3_t (t, mt)
  local Vec3 = t

  function mt.__add (a, b)
    return (Vec3(a.x + b.x, a.y + b.y, a.z + b.z))
  end

  function mt.__div (a, b)
    return (Vec3(a.x / b.x, a.y / b.y, a.z / b.z))
  end

  function mt.__mul (a, b)
    return (Vec3(a.x * b.x, a.y * b.y, a.z * b.z))
  end

  function mt.__pow (a, b)
    return (Vec3(a.x ^ b.x, a.y ^ b.y, a.z ^ b.z))
  end

  function mt.__sub (a, b)
    return (Vec3(a.x - b.x, a.y - b.y, a.z - b.z))
  end

  function mt.__unm (v)
    return (Vec3(-v.x, -v.y, -v.z))
  end

  function mt.__index.iadd (a, b)
    a.x = a.x + b.x
    a.y = a.y + b.y
    a.z = a.z + b.z
  end

  function mt.__index.idiv (a, b)
    a.x = a.x / b.x
    a.y = a.y / b.y
    a.z = a.z / b.z
  end

  function mt.__index.idivs (a, s)
    a.x = a.x / s
    a.y = a.y / s
    a.z = a.z / s
  end

  function mt.__index.divs (a, s)
    return (Vec3(a.x / s, a.y / s, a.z / s))
  end

  function mt.__index.imadds (a, b, s)
    a.x = a.x + s * b.x
    a.y = a.y + s * b.y
    a.z = a.z + s * b.z
  end

  function mt.__index.imul (a, b)
    a.x = a.x * b.x
    a.y = a.y * b.y
    a.z = a.z * b.z
  end

  function mt.__index.imuls (a, s)
    a.x = a.x * s
    a.y = a.y * s
    a.z = a.z * s
  end

  function mt.__index.muls (a, s)
    return (Vec3(a.x * s, a.y * s, a.z * s))
  end

  function mt.__index.isub (a, b)
    a.x = a.x - b.x
    a.y = a.y - b.y
    a.z = a.z - b.z
  end

  function mt.__index.abs (v)
    return (Vec3(math.abs(v.x), math.abs(v.y), math.abs(v.z)))
  end

  function mt.__index.clamp (v, lower, upper)
    return (Vec3(
      math.max(lower.x, math.min(upper.x, v.x)),
      math.max(lower.y, math.min(upper.y, v.y)),
      math.max(lower.z, math.min(upper.z, v.z))))
  end

  function mt.__index.iclampLength (v, clamp)
    local lenSq = v:lengthSquared()
    if lenSq > clamp*clamp then
      v:iscale(clamp / sqrt(lenSq))
    end
  end

  function mt.__index.clampLength (v, clamp)
    local result = v:clone()
    local lenSq = v:lengthSquared()
    if lenSq > clamp*clamp then
      result:iscale(clamp / sqrt(lenSq))
    end
    return result
  end

  function mt.__index.icross (a, b, out)
    out.x = b.z * a.y - b.y * a.z
    out.y = b.x * a.z - b.z * a.x
    out.z = b.y * a.x - b.x * a.y
  end

  function mt.__index.cross (a, b)
    return (Vec3(
      b.z * a.y - b.y * a.z,
      b.x * a.z - b.z * a.x,
      b.y * a.x - b.x * a.y))
  end

  function mt.__index.distance (a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return (math.sqrt(dx*dx + dy*dy + dz*dz))
  end

  function mt.__index.distanceSquared (a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return dx*dx + dy*dy + dz*dz
  end

  function mt.__index.dot (a, b)
    return a.x*b.x + a.y*b.y + a.z*b.z
  end

  function mt.__index.approximatelyEqual (a, b)
    return abs(a.x - b.x) < 1e-3
       and abs(a.y - b.y) < 1e-3
       and abs(a.z - b.z) < 1e-3
  end

  function mt.__index.equal (a, b)
    return a.x == b.x
       and a.y == b.y
       and a.z == b.z
  end

  function mt.__index.iinverse (v)
    v:iscale(-1)
  end

  function mt.__index.inverse (v)
    return v:scale(-1)
  end

  function mt.__index.isZero (v)
    return v.x == 0 and v.y == 0 and v.z == 0
  end

  function mt.__index.length (v)
    return (math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z))
  end

  function mt.__index.lengthSquared (v)
    return (v.x*v.x + v.y*v.y + v.z*v.z)
  end

  function mt.__index.ilerp (a, b, t)
    a.x = a.x + (b.x - a.x) * t
    a.y = a.y + (b.y - a.y) * t
    a.z = a.z + (b.z - a.z) * t
  end

  function mt.__index.lerp (a, b, t)
    return (Vec3(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.z + (b.z - a.z) * t))
  end

  function mt.__index.lerpv (a, b, tv)
    return (Vec3(
      a.x + (b.x - a.x) * tv.x,
      a.y + (b.y - a.y) * tv.y,
      a.z + (b.z - a.z) * tv.z))
  end

  function mt.__index.max (a, b)
    return (Vec3(
      math.max(a.x, b.x),
      math.max(a.y, b.y),
      math.max(a.z, b.z)))
  end

  function mt.__index.maxComponent (v)
    return (math.max(v.x, math.max(v.y, v.z)))
  end

  function mt.__index.min (a, b)
    return (Vec3(
      math.min(a.x, b.x),
      math.min(a.y, b.y),
      math.min(a.z, b.z)))
  end

  function mt.__index.minComponent (v)
    return (math.min(v.x, math.min(v.y, v.z)))
  end

  function mt.__index.inormalize (v)
    local l = math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
    assert(l > 1e-12, 'Attempting to normalize vector with near-zero length')
    v.x = v.x / l
    v.y = v.y / l
    v.z = v.z / l
  end

  function mt.__index.normalize (v)
    local l = math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
    assert(l > 1e-12, 'Attempting to normalize vector with near-zero length')
    return (Vec3(v.x / l, v.y / l, v.z / l))
  end

  function mt.__index.pNormalize (v, p)
    local l = (math.abs(v.x)^p + math.abs(v.y)^p + math.abs(v.z)^p)^(1.0/p)
    assert(l > 1e-12, 'Attempting to normalize vector with near-zero length')
    return (Vec3(v.x / l, v.y / l, v.z / l))
  end

  -- Assumes b is normalized
  function mt.__index.project (a, b)
    local d = a.x*b.x + a.y*b.y + a.z*b.z
    return (Vec3(d*b.x, d*b.y, d*b.z))
  end

  -- Assumes b is normalized
  function mt.__index.reject (a, b)
    local d = a.x*b.x + a.y*b.y + a.z*b.z
    return (Vec3(a.x - d*b.x, a.y - d*b.y, a.z - d*b.z))
  end

  function mt.__index.iscale (v, s)
    v.x = v.x * s
    v.y = v.y * s
    v.z = v.z * s
  end

  function mt.__index.scale (v, s)
    return (Vec3(s*v.x, s*v.y, s*v.z))
  end

  function mt.__index.set (v, x, y, z)
    v.x = x
    v.y = y
    v.z = z
  end

  function mt.__index.setv (v, other)
    v.x = other.x
    v.y = other.y
    v.z = other.z
  end

  function mt.__index.sqrt (v)
    return (Vec3(math.sqrt(v.x), math.sqrt(v.y), math.sqrt(v.z)))
  end
end

local function defineVec3i_t (t, mt)
  function mt.__index.toVec3f (v)
    return Vec3f(v.x, v.y, v.z)
  end

  function mt.__index.toVec3d (v)
    return Vec3d(v.x, v.y, v.z)
  end

  function mt.__index.toVec2i (v)
    return Vec2i(v.x, v.y)
  end

  function mt.__index.toVec4i (v)
    return Vec4i(v.x, v.y, v.z, 0.0)
  end

  function mt.__tostring (v)
    return string.format('(%i, %i, %i)', v.x, v.y, v.z)
  end
end

local function defineVec3f_t (t, mt)
  function mt.__index.toVec3i (v)
    return Vec3i(v.x, v.y, v.z)
  end

  function mt.__index.toVec3d (v)
    return Vec3d(v.x, v.y, v.z)
  end

  function mt.__index.toVec2f (v)
    return Vec2f(v.x, v.y)
  end

  function mt.__index.toVec4f (v)
    return Vec4f(v.x, v.y, v.z, 0.0)
  end

  function mt.__tostring (v)
    return string.format('(%.4f, %.4f, %.4f)', v.x, v.y, v.z)
  end
end

local function defineVec3d_t (t, mt)
  function mt.__index.toVec3i (v)
    return Vec3i(v.x, v.y, v.z)
  end

  function mt.__index.toVec3f (v)
    return Vec3f(v.x, v.y, v.z)
  end

  function mt.__index.toVec2d (v)
    return Vec2d(v.x, v.y)
  end

  function mt.__index.toVec4d (v)
    return Vec4d(v.x, v.y, v.z, 0.0)
  end

  function mt.__tostring (v)
    return string.format('(%.4f, %.4f, %.4f)', v.x, v.y, v.z)
  end
end

onDef_Vec3i = defineVec3
onDef_Vec3f = defineVec3
onDef_Vec3d = defineVec3

onDef_Vec3i_t = function (t, mt) defineVec3_t(t, mt) defineVec3i_t(t, mt) end
onDef_Vec3f_t = function (t, mt) defineVec3_t(t, mt) defineVec3f_t(t, mt) end
onDef_Vec3d_t = function (t, mt) defineVec3_t(t, mt) defineVec3d_t(t, mt) end
