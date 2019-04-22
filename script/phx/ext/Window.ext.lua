function onDef_Window_t (t, mt)
  mt.__index.getPosition = function (self) local v = Vec2i() libphx.Window_GetPosition(self, v) return v end
  mt.__index.getSize     = function (self) local v = Vec2i() libphx.Window_GetSize(self, v)     return v end
end
