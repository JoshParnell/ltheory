function onDef_Tex2D_t (t, mt)
  mt.__index.getSize       = function (self)        local v = Vec2i() libphx.Tex2D_GetSize(self, v)             return v end
  mt.__index.getSizeLevel  = function (self, level) local v = Vec2i() libphx.Tex2D_GetSizeLevel(self, v, level) return v end
end
