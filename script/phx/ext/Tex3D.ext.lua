function onDef_Tex3D_t (t, mt)
  mt.__index.getSize      = function (self)        local v = Vec3i() libphx.Tex3D_GetSize(self, v)             return v end
  mt.__index.getSizeLevel = function (self, level) local v = Vec3i() libphx.Tex3D_GetSizeLevel(self, v, level) return v end
end
