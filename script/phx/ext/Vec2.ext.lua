local function defineVec2_t (t, mt)
   local Vec2 = t

  function mt.__add (a, b)
    return (Vec2(a.x + b.x, a.y + b.y))
  end

  function mt.__div (a, b)
    return (Vec2(a.x / b.x, a.y / b.y))
  end

  function mt.__mul (a, b)
    return (Vec2(a.x * b.x, a.y * b.y))
  end

  function mt.__pow (a, b)
    return (Vec2(a.x ^ b.x, a.y ^ b.y))
  end

  function mt.__sub (a, b)
    return (Vec2(a.x - b.x, a.y - b.y))
  end

  function mt.__unm (v)
    return (Vec2(-v.x, -v.y))
  end

  function mt.__index.iadd (a, b)
    a.x = a.x + b.x
    a.y = a.y + b.y
  end

  function mt.__index.idiv (a, b)
    a.x = a.x / b.x
    a.y = a.y / b.y
  end

  function mt.__index.idivs (a, s)
    a.x = a.x / s
    a.y = a.y / s
  end

  function mt.__index.divs (a, s)
    return (Vec2(a.x / s, a.y / s))
  end

  function mt.__index.imadds (a, b, s)
    a.x = a.x + s * b.x
    a.y = a.y + s * b.y
  end

  function mt.__index.imul (a, b)
    a.x = a.x * b.x
    a.y = a.y * b.y
  end

  function mt.__index.imuls (a, s)
    a.x = a.x * s
    a.y = a.y * s
  end

  function mt.__index.muls (a, s)
    return (Vec2(a.x * s, a.y * s))
  end

  function mt.__index.isub (a, b)
    a.x = a.x - b.x
    a.y = a.y - b.y
  end

  function mt.__index.abs (v)
    return (Vec2(math.abs(v.x), math.abs(v.y)))
  end

  function mt.__index.clamp (v, lower, upper)
    return (Vec2(
      math.max(lower.x, math.min(upper.x, v.x)),
      math.max(lower.y, math.min(upper.y, v.y))))
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

  function mt.__index.distance (a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return (sqrt(dx*dx + dy*dy))
  end

  function mt.__index.distanceSquared (a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return dx*dx + dy*dy
  end

  function mt.__index.dot (a, b)
    return a.x*b.x + a.y*b.y
  end

  function mt.__index.approximatelyEqual (a, b)
    return abs(a.x - b.x) < 1e-3
       and abs(a.y - b.y) < 1e-3
  end

  function mt.__index.equal (a, b)
    return a.x == b.x
       and a.y == b.y
  end

  function mt.__index.isZero (v)
    return v.x == 0 and v.y == 0
  end

  function mt.__index.length (v)
    return (sqrt(v.x * v.x + v.y * v.y))
  end

  function mt.__index.lengthSquared (v)
    return (v.x * v.x + v.y * v.y)
  end

  function mt.__index.ilerp (a, b, t)
    a.x = a.x + (b.x - a.x) * t
    a.y = a.y + (b.y - a.y) * t
  end

  function mt.__index.lerp (a, b, t)
    return (Vec2(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t))
  end

  function mt.__index.lerpv (a, b, t)
    return (Vec2(
      a.x + (b.x - a.x) * t.x,
      a.y + (b.y - a.y) * t.y))
  end

  function mt.__index.inormalize (v)
    local l = sqrt(v.x*v.x + v.y*v.y)
    assert(l > 1e-12, 'Attempting to normalize vector with near-zero length')
    v.x = v.x / l
    v.y = v.y / l
  end

  function mt.__index.normalize (v)
    local l = sqrt(v.x*v.x + v.y*v.y)
    assert(l > 1e-12, 'Attempting to normalize vector with near-zero length')
    return (Vec2(v.x / l, v.y / l))
  end

  function mt.__index.iscale (v, s)
    v.x = v.x * s
    v.y = v.y * s
  end

  function mt.__index.scale (v, s)
    return (Vec2(s*v.x, s*v.y))
  end
end

local function defineVec2i_t (t, mt)
  function mt.__index.toVec2f (v)
    return Vec2f(v.x, v.y)
  end

  function mt.__index.toVec2d (v)
    return Vec2d(v.x, v.y)
  end

  function mt.__index.toVec3i (v)
    return Vec3i(v.x, v.y, 0.0)
  end

  function mt.__index.toVec4i (v)
    return Vec4i(v.x, v.y, 0.0, 0.0)
  end

  function mt.__tostring (v)
    return string.format('(%i, %i)', v.x, v.y)
  end
end

local function defineVec2f_t (t, mt)
  function mt.__index.toVec2i (v)
    return Vec2i(v.x, v.y)
  end

  function mt.__index.toVec2d (v)
    return Vec2d(v.x, v.y)
  end

  function mt.__index.toVec3f (v)
    return Vec3f(v.x, v.y, 0.0)
  end

  function mt.__index.toVec4f (v)
    return Vec4f(v.x, v.y, 0.0, 0.0)
  end

  function mt.__tostring (v)
    return string.format('(%.4f, %.4f)', v.x, v.y)
  end
end

local function defineVec2d_t (t, mt)
  function mt.__index.toVec2i (v)
    return Vec2i(v.x, v.y)
  end

  function mt.__index.toVec2f (v)
    return Vec2f(v.x, v.y)
  end

  function mt.__index.toVec3d (v)
    return Vec3d(v.x, v.y, 0.0)
  end

  function mt.__index.toVec4d (v)
    return Vec4d(v.x, v.y, 0.0, 0.0)
  end

  function mt.__tostring (v)
    return string.format('(%.4f, %.4f)', v.x, v.y)
  end
end

onDef_Vec2i_t = function (t, mt) defineVec2_t(t, mt) defineVec2i_t(t, mt) end
onDef_Vec2f_t = function (t, mt) defineVec2_t(t, mt) defineVec2f_t(t, mt) end
onDef_Vec2d_t = function (t, mt) defineVec2_t(t, mt) defineVec2d_t(t, mt) end
