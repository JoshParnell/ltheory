function onDef_Font_t (t, mt)
  mt.__index.getSize = function (self, text)
    local v = Vec4i()
    libphx.Font_GetSize(self, v, text)
    return v
  end
end
