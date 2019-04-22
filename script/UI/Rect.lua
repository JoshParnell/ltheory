local self = {}

function self.draw (x, y, sx, sy)
  Draw.Rect(x, y, sx, sy)
end

function self.containsPoint (x, y, sx, sy, px, py)
  return
    x <= px and
    y <= py and
    px <= (x + sx) and
    py <= (y + sy)
end

function self.getPointRel (x, y, sx, sy, rx, ry)
  return Math.Lerp(x, x + sx, rx), Math.Lerp(y, y + sy, ry)
end

function self.offset (x, y, sx, sy, ox, oy)
  return x + ox, y + oy, sx, sy
end


function self.padExt (x, y, sx, sy, left, right, bottom, top)
  return x - left, y - top, sx + left + right, sy + bottom + top
end

function self.padExtUniform (x, y, sx, sy, pad)
  return x - pad, y - pad, sx + 2*pad, sy + 2*pad
end

function self.padExtX (x, sx, pad)
  return x - pad/2, sx + pad
end

function self.padExtY (y, sy, pad)
  return y - pad/2, sy + pad
end


function self.padInt (x, y, sx, sy, left, right, bottom, top)
  local pl = min(sx, left)
  x = x + pl
  sx = sx - pl
  local pt = min(sy, top)
  y = y + pt
  sy = sy - pt
  local pr = min(sx, right)
  sx = sx - pr
  local pb = min(sy, bottom)
  sy = sy - pb
  return x, y, sx, sy
end

function self.padIntUniform (x, y, sx, sy, pad)
  pad = 2*min(sx, pad/2)
  pad = 2*min(sy, pad/2)
  return x + pad, y + pad, sx - 2*pad, sy - 2*pad
end

function self.padIntX (x, sx, pad)
  pad = min(sx, pad)
  return x + pad/2, sx - pad
end

function self.padIntY (y, sy, pad)
  pad = min(sy, pad)
  return y + pad/2, sy - pad
end


function self.tostring (x, y, sx, sy)
  return string.format('x: %i, y: %i, sx: %i, sy: %i', x, y, sx, sy)
end

function self.tostringPos (x, y)
  return string.format('x: %i, y: %i', x, y)
end

function self.tostringSize (sx, sy)
  return string.format('sx: %i, sy: %i', sx, sy)
end

function self.print (x, y, sx, sy)
  print(self.tostring(x, y, sx, sy))
end

function self.printPos (x, y)
  print(self.tostringPos(x, y))
end

function self.printSize (sx, sy)
  print(self.tostringSize(sx, sy))
end

return self
