local Parametric = {}

function Parametric.Circle ()
  return Parametric.Ellipse(1, 1)
end

function Parametric.Ellipse (sx, sy)
  local sx, sy = sx or 1, sy or 2
  return function (t)
    return Vec2d(sx * cos(t), sy * sin(t))
  end
end

function Parametric.Shroom (sx)
  local sx = sx or 3
  return function(t)
    return Vec2d((sx + cos(t))*cos(t),
                (sx + sin(t))*sin(t))
  end
end

-- Curvy diamond shape
-- 3-prong:        a = 3
-- 4-prong:        a = 4 etc..
-- 4-prong default
-- divides each result by a to guaruntee that
-- the resulting shape has a max radius of (about) a
function Parametric.Hypocycloid (a)
  local a = a or 5
  a = a - 1
  return function (t)
    return Vec2d(
      (a*cos(t) + cos(a*t))/a,
      (a*sin(t) - sin(a*t))/a
    )
  end
end

function Parametric.Parabola (sx, sy)
  local sx, sy = sx or 1, sy or 1
  return function (t)
    return Vec2d(sx * cos(2 * t), sy * sin(t))
  end
end

function Parametric.Rectangle (sx, sy)
  local sx, sy = sx or 1, sy or 1
  return function (t)
    local c, s = cos(t), sin(t)
    return Vec2d(
      sx * (abs(c) * c - abs(s) * s),
      sy * (abs(c) * c + abs(s) * s))
  end
end

function Parametric.Random (rng)
  local curveType = rng:getInt(1, 6)
  local sx = rng:getUniformRange(0.5, 2.0)
  local sy = rng:getUniformRange(0.5, 2.0)
  if curveType == 1 then return Parametric.Ellipse(sx, sy) end
  if curveType == 2 then return Parametric.Hypocycloid(rng:getInt(3,10)) end
  if curveType == 3 then return Parametric.Parabola(sx, sy) end
  if curveType == 4 then return Parametric.Rectangle(sx, sy) end
  if curveType == 5 then return Parametric.Shroom(rng:getUniformRange(2,5)) end
  if curveType == 6 then return Parametric.Circle() end
end

-- only returns functions with radial symmetry
function Parametric.RandomRadial (rng)
  local curveType = rng:getInt(1, 3)
  local sx = rng:getUniformRange(0.5, 2.0)
  local sy = rng:getUniformRange(0.5, 2.0)
  if curveType == 1 then return Parametric.Ellipse(sx, sy) end
  if curveType == 2 then return Parametric.Hypocycloid(rng:getInt(3,10)) end
  if curveType == 3 then return Parametric.Circle() end
end

return Parametric
