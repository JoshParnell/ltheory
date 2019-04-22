local Settings = {}
local varMap   = {}
local varList  = {}

function Settings.addBool (key, name, default)
  local self = {
    key = key,
    name = name,
    value = default,
    default = default,
    type = 'bool',
  }

  self.getter = function () return self.value end
  self.setter = function (v) self.value = v end
  varMap[key] = self
  table.insert(varList, self)
end

function Settings.addEnum (key, name, default, elems)
  local self = {
    key = key,
    name = name,
    value = default,
    default = default,
    elems = elems,
    type = 'enum',
  }

  self.getter = function () return self.value end
  self.setter = function (v) self.value = v end
  varMap[key] = self
  table.insert(varList, self)
end

function Settings.addFloat (key, name, default, min, max)
  local self = {
    key = key,
    name = name,
    value = default,
    default = default,
    type = 'float',
    min = min,
    max = max,
  }

  self.getter = function () return self.value end
  self.setter = function (v) self.value = v end
  varMap[key] = self
  table.insert(varList, self)
end

function Settings.exists (key)
  return varMap[key] ~= nil
end

function Settings.get (key)
  local self = varMap[key]
  if not self then Log.Error('Attempting to get nonexistent setting <%s>', key) end
  return self.value
end

function Settings.getter (key)
  local self = varMap[key]
  if not self then Log.Error('Attempting to get nonexistent setting <%s>', key) end
  return self.getter
end

function Settings.getEntry (key)
  local self = varMap[key]
  if not self then Log.Error('Attempting to get nonexistent setting <%s>', key) end
  return self
end

function Settings.getAll ()
  return varList
end

function Settings.set (key, value)
  local self = varMap[key]
  if not self then Log.Error('Attempting to set nonexistent setting <%s>', key) end
  self.value = value
end

setmetatable(Settings, { __index = function (t, k) return Settings.get(k) end })

return Settings
