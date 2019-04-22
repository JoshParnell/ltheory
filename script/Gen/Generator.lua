local generators = {}

local function Add (type, weight, fn)
  if not generators[type] then generators[type] = Distribution() end
  generators[type]:add(fn, weight)
end

local function Get (type, rng)
  if not generators[type] then
    Log.Error("No generators for asset type '%s' are loaded", type)
  end
  return generators[type]:sample(rng)
end

return {
  Add = Add,
  Get = Get,
}
