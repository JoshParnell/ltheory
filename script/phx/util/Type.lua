--[[----------------------------------------------------------------------------
  Provides a global type registration and lookup service to enable polymorphic
  behaviors and virtual dispatch mechanisms, as well as to aid in cleaning up
  and unifying the CTypes API. As always, powertools like this should be used
  only where required, not as a kludge.
----------------------------------------------------------------------------]]--
local Type   = {}
local byName = {}
local byID   = {}
local nextID = 1

local TypeT   = {}
TypeT.__index = TypeT

function TypeT:addMethod (name, fn)
  assert(not self.defined, "Attempting to add method to already-defined type")
  self.methods[name] = fn
end

function TypeT:appendMethod (name, fn)
  assert(not self.defined, "Attempting to wrap method in already-defined type")
  local prev = self.methods[name]
  if prev then
    self.methods[name] = function (...)
      prev(...)
      fn(...)
    end
  else
    self.methods[name] = fn
  end
end

function TypeT:addOnConstruct (fn)
  self.onConstruct[#self.onConstruct + 1] = fn
end

function TypeT:addOnDestruct (fn)
  self.onDestruct[#self.onDestruct + 1] = fn
end

function TypeT:addOnSubclass (fn)
  self.onSubclass[#self.onSubclass + 1] = fn
end

function TypeT:cast (x)
  return ffi.cast(self.ptrName, x)
end

-- TODO : Engine-level _ref trickery to save LuaJIT from itself
function TypeT:dynamicCast (x)
  return ffi.cast(byID[ffi.cast(self.ptrName, x).tid].ptrName, x)
end

function TypeT:ensureMeta ()
  if not self.metatype then
    self.metatable = {}
    self.metatable.__index = {
      getType = function () return self end,
      hasField = function (e, name) return self.fieldTable[name] ~= nil end,
      hasMethod = function (e, name) return self.methods[name] ~= nil end,
    }

    self.metatable.__pairs = function (table)
      local i = 0
      local function iterator(data)
        i = i + 1
        local fields = data:getType().fields
        if i <= #fields then
          local name = fields[i].name
          return name, data[name]
        end
      end
      return iterator, table, nil
    end

    self.metatable.__ipairs = function (table)
      local function iterator(data, i)
        i = i + 1
        local fields = data:getType().fields
        if i <= #fields then
          local name = fields[i].name
          return i, data[name]
        end
      end
      return iterator, table, 0
    end

    self.metatype = ffi.metatype(self.name, self.metatable)
  end
end

function TypeT:getAlign ()
  return ffi.alignof(self.name)
end

function TypeT:getField (name)
  return self.fieldTable[name]
end

function TypeT:getIndexTable ()
  self:ensureMeta()
  return self.metatable.__index
end

function TypeT:getMetatable ()
  self:ensureMeta()
  return self.metatable
end

function TypeT:getMetatype ()
  self:ensureMeta()
  return self.metatype
end

function TypeT:getMethod (name)
  return self.methods[name]
end

function TypeT:getSize ()
  return ffi.sizeof(self.name)
end

function TypeT:hasField (name)
  return self.fieldTable[name] ~= nil
end

function TypeT:hasMethod (name)
  return self.methods[name] ~= nil
end

-- Stub new function, will replace the given type's new with a real allocator
-- function after creating a memory pool. Having a stub allows lazy creation
-- of memory pools (i.e., we don't create pools for types that are never
-- instantiated directly)
function TypeT:new ()
  -- Block size is chosen such that each block is one page of memory
  local blockSize = max(1, floor(0x1000 / self:getSize()))
  self.pool = MemPool.Create(self:getSize(), blockSize)
  self.new = function (T)
    local instance = ffi.cast(T.ptrName, MemPool.Alloc(T.pool))
    for i = 1, #T.onConstruct do T.onConstruct[i](instance) end
    return instance
  end
  self.delete = function (T, instance)
    for i = 1, #T.onDestruct do T.onDestruct[i](instance) end
    MemPool.Dealloc(T.pool, instance)
  end
  return self:new()
end

function TypeT:delete ()
  Log.Error('Attempting to delete instance of un-instantiated type <%s>', self.niceName)
end

function TypeT:setInitializer (fn)
  if self.initializer then
    Log.Error('Attempting to set initializer on type <%s>, which already has one')
  else
    self.initializer = fn
  end
end

function TypeT:__call (...)
  if self.managed then
    return self.metatype(...)
  else
    local instance = self:new()
    if self.initializer then
      self.initializer(instance, ...)
    end
    return instance
  end
end

-- TODO : This is awful and should die ASAP.
-- By conditionally forwarding __newindex back to the type table itself, we
-- allow the type table to hook the metamethod.
function TypeT.__newindex (t, k, v)
  if rawget(t, '__newindex') then
    rawget(t, '__newindex')(t, k, v)
  else
    rawset(t, k, v)
  end
end

function TypeT:__tostring ()
  return string.format('[CType %s]', self.niceName)
end

--------------------------------------------------------------------------------

function Type.Alias (oldName, newName)
  if not byName[oldName] then Log.Error('Attempting to alias non-existent type <%s>', oldName) end
  if byName[newName]     then Log.Error('Attempting to use an existing type name <%s> as alias', newName) end
  byName[newName] = byName[oldName]
end

function Type.Create (name, primitive)
  local self = byName[name]
  if self then Log.Error('Type <%s> already exists!', name) end

  self = setmetatable({
    children    = {},
    defined     = true,
    fields      = {},
    fieldTable  = {},
    id          = nextID,
    initializer = nil,
    managed     = true,
    methods     = {},
    name        = name,
    niceName    = name,
    onConstruct = {},
    onDestruct  = {},
    onSubclass  = {},
    parent      = nil,
    ptrName     = '_ptr_' .. name,
    primitive   = primitive or false,
  }, TypeT)

  -- Create unified alias for pointer type (_ptr_<T>)
  if self.primitive then
    ffi.cdef(string.format('typedef %s* %s;', self.name, self.ptrName))
  else
    ffi.cdef(string.format('typedef struct %s* %s;', self.name, self.ptrName))
  end

  nextID = nextID + 1
  byName[name] = self
  byID[self.id] = self
  return self
end

function Type.Get(name)
  return byName[name]
end

function Type.GetByID (id)
  return byID[id]
end

function Type.GetCount ()
  return nextID - 1
end

return Type
