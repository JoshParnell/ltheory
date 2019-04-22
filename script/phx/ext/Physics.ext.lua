function onDef_Physics_t (t, mt)
  mt.__index.rayCast    = function (self, ray)                   local r = RayCastResult()   libphx.Physics_RayCast(self, ray, r)                   return r end
  mt.__index.sphereCast = function (self, sphere)                local r = ShapeCastResult() libphx.Physics_SphereCast(self, sphere, r)             return r end
  mt.__index.boxCast    = function (self, pos, rot, halfExtents) local r = ShapeCastResult() libphx.Physics_BoxCast(self, pos, rot, halfExtents, r) return r end
end
