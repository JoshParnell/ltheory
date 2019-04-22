local function GenerateColorLUT (rng, iterations, variation, rough)
  local self = Tex1D.Create(256, TexFormat.RGB8)
  self:setMagFilter(TexFilter.Linear);
  self:setMinFilter(TexFilter.Linear);

  -- Use midpoint displacement to generate an interesting curve
  local cPoints = List()
    :add(Vec3f(0, 0, 0))
    :add(Vec3f(1, 1, 1))
  local v = variation
  for i = 1, iterations do
    local newPoints = List()
    for j = 1, #cPoints - 1 do
      local p0 = cPoints[j + 0]
      local p1 = cPoints[j + 1]
      local pn = p0:lerp(p1, 0.5)
      pn.x = pn.x + v * rng:getGaussian()
      pn.y = pn.y + v * rng:getGaussian()
      pn.z = pn.z + v * rng:getGaussian()
      newPoints:add(p0)
      newPoints:add(pn)
    end

    newPoints:add(cPoints[#cPoints])
    cPoints = newPoints
    v = v * rough
  end

  -- Evaluate the generated bezier at each of the 256 texel locations
  local points = List()
  for i = 0, 255 do
    local t = i / 255
    local interp = cPoints:clone()
    while #interp > 1 do
      local newInterp = List()
      for j = 1, #interp - 1 do
        local p0 = interp[j + 0]
        local p1 = interp[j + 1]
        newInterp:add(p0:lerp(p1, t))
      end
      interp = newInterp
    end
    points:add(interp[1])
  end

  do -- Write the output into a byte buffer and transfer to texture
    local bytes = Bytes.Create(256 * 3 * 4) -- Transfer in RGB32F format
    for i = 1, #points do
      local point = points[i]
      bytes:writeF32(point.x)
      bytes:writeF32(point.y)
      bytes:writeF32(point.z)
    end

    self:setDataBytes(bytes, PixelFormat.RGB, DataFormat.Float)
    bytes:free()
  end

  return self
end

return GenerateColorLUT
