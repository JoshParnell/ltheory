function onDef_Matrix_t (t, mt)
  function mt.__add (a, b)
    return (libphx.Matrix_Sum(a, b))
  end

  function mt.__mul (a, b)
    return (libphx.Matrix_Product(a, b))
  end

  function mt.__index.mulBox     (m, box) local out = Box3f() libphx.Matrix_MulBox    (m, out, box)                 return out end
  function mt.__index.mulDir     (m, dir) local out = Vec3f() libphx.Matrix_MulDir    (m, out, dir.x, dir.y, dir.z) return out end
  function mt.__index.mulPoint   (m, p)   local out = Vec3f() libphx.Matrix_MulPoint  (m, out, p.x, p.y, p.z)       return out end
  function mt.__index.mulVec     (m, v)   local out = Vec4f() libphx.Matrix_MulVec    (m, out, v.x, v.y, v.z, v.w)  return out end
  function mt.__index.getRight   (m)      local out = Vec3f() libphx.Matrix_GetRight  (m, out)                      return out end
  function mt.__index.getUp      (m)      local out = Vec3f() libphx.Matrix_GetUp     (m, out)                      return out end
  function mt.__index.getForward (m)      local out = Vec3f() libphx.Matrix_GetForward(m, out)                      return out end
  function mt.__index.getPos     (m)      local out = Vec3f() libphx.Matrix_GetPos    (m, out)                      return out end
  function mt.__index.toQuat     (m)      local out = Quat()  libphx.Matrix_ToQuat    (m, out)                      return out end
end
