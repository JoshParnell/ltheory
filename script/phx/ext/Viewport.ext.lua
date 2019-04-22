function onDef_Viewport (t, mt)
  t.GetSize = function () local v = Vec2i() libphx.Viewport_GetSize(v) return v end
end
