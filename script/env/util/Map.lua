local Map = class(function (self, ctor)
  self.__ctor = ctor
end)

function Map.__index (t, k)
  t[k] = t.__ctor()
  return t[k]
end

-- Return a shallow copy of the map
function Map:clone ()
  local clone = Map()
  for k, v in pairs(self) do clone[k] = v end
  return clone
end

function Map:iMerge (other)
  for k, v in pairs(other) do self[k] = v end
  return self
end

return Map
