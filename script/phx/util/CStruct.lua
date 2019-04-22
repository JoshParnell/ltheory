local Type = require('phx.util.Type')

local function add (self, T, name)
  if self.fieldTable[name] then
    Log.Error('Type <%s> already has field with name <%s>', self.name, name)
  end

  if not T then
    Log.Error('Field <%s> of type <%s> has bad type', name, self.name)
  end

  if T.defined == false then
    Log.Error('Field <%s> of type <%s> has incomplete type <%s>', name, self.name, T.name)
  end

  local field = { T = T, name = name }
  table.insert(self.fields, field)
  self.fieldTable[name] = field
  return self
end

local function define (self)
  local lines = { format('typedef struct %s {', self.name) }
  for i = 1, #self.fields do
    local field = self.fields[i]
    table.insert(lines, format('  %s %s;', field.T.name, field.name))
  end
  table.insert(lines, format('} %s;', self.name))
  ffi.cdef(table.concat(lines, '\n'))

  self.add = nil
  self.define = nil
  self.defined = true

  local mt = self:getMetatable()

  function mt.__tostring (x)
    return format('[%s @ %p]', self.niceName, x)
  end

  -- When a new entry is added to a finalized type descriptor, copy and push it
  -- into the instance metatable (so that methods, static fields, and static
  -- functions can be all accessed from the instance itself)
  function self.__newindex (t, k, v)
    rawset(t, k, v)
    mt.__index[k] = v
    -- for i = 1, #t.children do t.children[i][k] = v end
  end

  -- Insert self into parent's list of subclasses; shallow copy parent's
  -- index table into our own. Note that we ignore special functions like
  -- getType and hasField, since we should maintain our own copy of them
  local ignore = {
    getType   = true,
    hasField  = true,
    hasMethod = true,
  }

  local parent = self.parent
  if parent then
    table.insert(parent.children, self)
    local mt = parent:getMetatable()
    for k, v in pairs(mt.__index) do
      if not ignore[k] then
        self[k] = v
      end
    end

    -- Rearrange constructors so that base class constructors are called first
    local ctors = {}
    for i = 1, #parent.onConstruct do ctors[#ctors + 1] = parent.onConstruct[i] end
    for i = 1, #self.onConstruct do ctors[#ctors + 1] = self.onConstruct[i] end
    self.onConstruct = ctors

    for i = 1, #self.parent.onDestruct do
      self:addOnDestruct(self.parent.onDestruct[i])
    end
  end

  -- Ensure that child methods override parent
  for k, v in pairs(self.methods) do
    mt.__index[k] = v
  end

  return self
end

local function CStruct (name)
  ffi.cdef(string.format('struct %s;', name))
  local self = Type.Create(name)
  self.niceName = name
  self.defined = false
  self.add = add
  self.define = define
  self.managed = false
  return self
end

return CStruct
