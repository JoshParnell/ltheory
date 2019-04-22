function onDef_Ray_t (t, mt)
  mt.__index.getPoint = function (self, t) return Vec3f(
    self.px + t * self.dirx,
    self.py + t * self.diry,
    self.pz + t * self.dirz)
  end

  mt.__index.getDirection = function (self) return Vec3f(self.dirx, self.diry, self.dirz) end
  mt.__index.getOrigin    = function (self) return Vec3f(self.px, self.py, self.pz) end

  mt.__tostring = function (self)
    return string.format(
      '(origin: (%f, %f, %f), dir: (%f, %f, %f), t: [%f, %f])',
      self.px, self.py, self.pz,
      self.dirx, self.diry, self.dirz,
      self.tMin, self.tMax)
  end
end
