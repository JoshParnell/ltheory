function Copy (v)
  if type(v) == 'table' then
    local cpy = {}
    for i, v in ipairs(v) do cpy[i] = v end
    for k, v in pairs(v) do cpy[k] = v end
    setmetatable(cpy, getmetatable(v))
    return cpy
  else
    Log.Error('Copy not supported on type <%s>', type(v))
  end
end
