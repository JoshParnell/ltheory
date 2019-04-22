function onDef_Mesh_t (t, mt)
  mt.__index.getBound  = function (self) local b = Box3f() libphx.Mesh_GetBound(self, b) return b end
  mt.__index.getCenter = function (self) local v = Vec3f() libphx.Mesh_GetCenter(self, v) return v end
end
