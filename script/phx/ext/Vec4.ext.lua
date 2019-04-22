local function defineVec4_t (t, mt)
  local Vec4 = t

  function mt.__add (a, b)
    return (Vec4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w))
  end

  function mt.__div (a, b)
    return (Vec4(a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w))
  end

  function mt.__mul (a, b)
    return (Vec4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w))
  end

  function mt.__pow (a, b)
    return (Vec4(a.x ^ b.x, a.y ^ b.y, a.z ^ b.z, a.w ^ b.w))
  end

  function mt.__sub (a, b)
    return (Vec4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w))
  end

  function mt.__unm (v)
    return (Vec4(-v.x, -v.y, -v.z, -v.w))
  end

  function mt.__index.iadd (a, b)
    a.x = a.x + b.x
    a.y = a.y + b.y
    a.z = a.z + b.z
    a.w = a.w + b.w
  end

  function mt.__index.idiv (a, b)
    a.x = a.x / b.x
    a.y = a.y / b.y
    a.z = a.z / b.z
    a.w = a.w / b.w
  end

  function mt.__index.idivs (a, s)
    a.x = a.x / s
    a.y = a.y / s
    a.z = a.z / s
    a.w = a.w / s
  end

  function mt.__index.divs (a, s)
    return (Vec4(a.x / s, a.y / s, a.z / s, a.w / s))
  end

  function mt.__index.imadds (a, b, s)
    a.x = a.x + s * b.x
    a.y = a.y + s * b.y
    a.z = a.z + s * b.z
    a.w = a.w + s * b.w
  end

  function mt.__index.imul (a, b)
    a.x = a.x * b.x
    a.y = a.y * b.y
    a.z = a.z * b.z
    a.w = a.w * b.w
  end

  function mt.__index.imuls (a, s)
    a.x = a.x * s
    a.y = a.y * s
    a.z = a.z * s
    a.w = a.w * s
  end

  function mt.__index.muls (a, s)
    return (Vec4(a.x * s, a.y * s, a.z * s, a.w * s))
  end

  function mt.__index.isub (a, b)
    a.x = a.x - b.x
    a.y = a.y - b.y
    a.z = a.z - b.z
    a.w = a.w - b.w
  end

  function mt.__index.abs (v)
    return (Vec4(math.abs(v.x), math.abs(v.y), math.abs(v.z), math.abs(v.w)))
  end

  function mt.__index.clamp (v, lower, upper)
    return (Vec4(
      math.max(lower.x, math.min(upper.x, v.x)),
      math.max(lower.y, math.min(upper.y, v.y)),
      math.max(lower.z, math.min(upper.z, v.z)),
      math.max(lower.w, math.min(upper.w, v.w))))
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

  function mt.__index.dot (a, b)
    return a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w
  end

  function mt.__index.approximatelyEqual (a, b)
    return abs(a.x - b.x) < 1e-3
       and abs(a.y - b.y) < 1e-3
       and abs(a.z - b.z) < 1e-3
       and abs(a.w - b.w) < 1e-3
  end

  function mt.__index.equal (a, b)
    return a.x == b.x
       and a.y == b.y
       and a.z == b.z
       and a.w == b.w
  end

  function mt.__index.isZero (v)
    return v.x == 0 and v.y == 0 and v.z == 0 and v.w == 0
  end

  function mt.__index.length (v)
    return (sqrt(v.x*v.x + v.y*v.y + v.z*v.z + v.w*v.w))
  end

  function mt.__index.lengthSquared (v)
    return v.x*v.x + v.y*v.y + v.z*v.z + v.w*v.w
  end

  function mt.__index.ilerp (a, b, t)
    a.x = a.x + (b.x - a.x) * t
    a.y = a.y + (b.y - a.y) * t
    a.z = a.z + (b.z - a.z) * t
    a.w = a.w + (b.w - a.w) * t
  end

  function mt.__index.lerp (a, b, t)
    return (Vec4(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.z + (b.z - a.z) * t,
      a.w + (b.w - a.w) * t))
  end

  function mt.__index.normalize (v)
    local l = sqrt(v.x*v.x + v.y*v.y + v.z*v.z + v.w*v.w)
    assert(l > 1e-12, 'Attempting to normalize vector with near-zero length')
    return (Vec4(v.x / l, v.y / l, v.z / l, v.w / l))
  end
end

local function defineVec4i_t (t, mt)
  function mt.__index.toVec4f (v)
    return Vec4f(v.x, v.y, v.z, v.w)
  end

  function mt.__index.toVec4d (v)
    return Vec4d(v.x, v.y, v.z, v.w)
  end

  function mt.__index.toVec2i (v)
    return Vec2i(v.x, v.y)
  end

  function mt.__index.toVec3i (v)
    return Vec3i(v.x, v.y, v.z)
  end

  function mt.__tostring (v)
    return string.format('(%i, %i, %i, %i)', v.x, v.y, v.z, v.w)
  end
end

local function defineVec4f_t (t, mt)
  function mt.__index.toVec4i (v)
    return Vec4i(v.x, v.y, v.z, v.w)
  end

  function mt.__index.toVec4d (v)
    return Vec4d(v.x, v.y, v.z, v.w)
  end

  function mt.__index.toVec2f (v)
    return Vec2f(v.x, v.y)
  end

  function mt.__index.toVec3f (v)
    return Vec3f(v.x, v.y, v.z)
  end

  function mt.__tostring (v)
    return string.format('(%.4f, %.4f, %.4f, %.4f)', v.x, v.y, v.z, v.w)
  end
end

local function defineVec4d_t (t, mt)
  function mt.__index.toVec4i (v)
    return Vec4i(v.x, v.y, v.z, v.w)
  end

  function mt.__index.toVec4f (v)
    return Vec4f(v.x, v.y, v.z, v.w)
  end

  function mt.__index.toVec2d (v)
    return Vec2d(v.x, v.y)
  end

  function mt.__index.toVec3d (v)
    return Vec3d(v.x, v.y, v.z)
  end

  function mt.__tostring (v)
    return string.format('(%.4f, %.4f, %.4f, %.4f)', v.x, v.y, v.z, v.w)
  end
end

onDef_Vec4i_t = function (t, mt) defineVec4_t(t, mt) defineVec4i_t(t, mt) end
onDef_Vec4f_t = function (t, mt) defineVec4_t(t, mt) defineVec4f_t(t, mt) end
onDef_Vec4d_t = function (t, mt) defineVec4_t(t, mt) defineVec4d_t(t, mt) end
