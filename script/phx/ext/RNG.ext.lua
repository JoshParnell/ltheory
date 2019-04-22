function onDef_RNG_t (t, mt)
  mt.__index.choose    = function (self, table) return table[libphx.RNG_GetInt(self, 1, #table)] end
  mt.__index.getAxis2  = function (self)       local v = Vec2f() libphx.RNG_GetAxis2(self, v)      return v end
  mt.__index.getAxis3  = function (self)       local v = Vec3f() libphx.RNG_GetAxis3(self, v)      return v end
  mt.__index.getDir2   = function (self)       local v = Vec2f() libphx.RNG_GetDir2(self, v)       return v end
  mt.__index.getDir3   = function (self)       local v = Vec3f() libphx.RNG_GetDir3(self, v)       return v end
  mt.__index.getDisc   = function (self)       local v = Vec2f() libphx.RNG_GetDisc(self, v)       return v end
  mt.__index.getSphere = function (self)       local v = Vec3f() libphx.RNG_GetSphere(self, v)     return v end
  mt.__index.getVec2   = function (self, l, u) local v = Vec2f() libphx.RNG_GetVec2(self, v, l, u) return v end
  mt.__index.getVec3   = function (self, l, u) local v = Vec3f() libphx.RNG_GetVec3(self, v, l, u) return v end
  mt.__index.getVec4   = function (self, l, u) local v = Vec4f() libphx.RNG_GetVec4(self, v, l, u) return v end
  mt.__index.getQuat   = function (self)       local q = Quat()  libphx.RNG_GetQuat(self, q)       return q end
end
