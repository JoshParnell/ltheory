function onDef_Quat (t, mt)
  function t.FromAxisAngle (axis, angle) local out = Quat() libphx.Quat_FromAxisAngle(axis, angle, out) return out end
  function t.FromBasis (x, y, z)         local out = Quat() libphx.Quat_FromBasis(x, y, z, out)         return out end
  function t.Identity ()                 local out = Quat() libphx.Quat_Identity(out)                   return out end
  function t.FromLookUp (look, up)       local out = Quat() libphx.Quat_FromLookUp(look, up, out)       return out end
  function t.FromRotateTo (from, to)     local out = Quat() libphx.Quat_FromRotateTo(from, to, out)     return out end
end

function onDef_Quat_t (t, mt)
  function mt.__mul (a, b)             local out = Quat()  libphx.Quat_Mul(a, b, out)       return out end
  function mt.__index.canonicalize (q) local out = Quat()  libphx.Quat_Canonicalize(q, out) return out end
  function mt.__index.getAxisX (q)     local out = Vec3f() libphx.Quat_GetAxisX(q, out)     return out end
  function mt.__index.getAxisY (q)     local out = Vec3f() libphx.Quat_GetAxisY(q, out)     return out end
  function mt.__index.getAxisZ (q)     local out = Vec3f() libphx.Quat_GetAxisZ(q, out)     return out end
  function mt.__index.getRight (q)     local out = Vec3f() libphx.Quat_GetRight(q, out)     return out end
  function mt.__index.getUp (q)        local out = Vec3f() libphx.Quat_GetUp(q, out)        return out end
  function mt.__index.getForward (q)   local out = Vec3f() libphx.Quat_GetForward(q, out)   return out end
  function mt.__index.inverse (q)      local out = Quat()  libphx.Quat_Inverse(q, out)      return out end
  function mt.__index.lerp (a, b, t)   local out = Quat()  libphx.Quat_Lerp(a, b, y, out)   return out end
  function mt.__index.mul (a, b)       local out = Quat()  libphx.Quat_Mul(a, b, out)       return out end
  function mt.__index.mulV (q, v)      local out = Vec3f() libphx.Quat_MulV(q, v, out)      return out end
  function mt.__index.normalize (q)    local out = Quat()  libphx.Quat_Normalize(q, out)    return out end
  function mt.__index.scale (q, scale) local out = Quat()  libphx.Quat_Scale(q, scale, out) return out end
  function mt.__index.slerp (a, b, t)  local out = Quat()  libphx.Quat_Slerp(a, b, t, out)  return out end
end
