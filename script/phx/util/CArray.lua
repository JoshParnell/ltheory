local Type = require('phx.util.Type')
local cache = {}

local function CreateCArray (ElemT)
  local T = Type.Create('_arr_' .. ElemT.name)
  T.niceName = format('Array<%s>', ElemT.niceName)

  ffi.cdef(string.format([[
    typedef struct %s {
      int32_t size;
      int32_t capacity;
      %s*     data;
    } %s;
  ]], T.name, ElemT.name, T.name))

  local mt = T:getMetatable()
  local elemSize = ElemT:getSize()

  function mt.__index:add (elem)
    if self.capacity == self.size then
      self.capacity = max(self.capacity * 2, 1)
      self.data = Memory.Realloc(self.data, self.capacity * elemSize)
    end
    self.data[self.size] = elem
    self.size = self.size + 1
  end

  function mt.__index:back ()
    return self.data + (self.size - 1)
  end

  function mt.__index:choose (rng)
    return self.data[rng:getInt(0, self.size - 1)]
  end

  function mt.__index:clear ()
    self.size = 0
  end

  function mt.__index:front ()
    return self.data
  end

  function mt.__index:get (i)
    return self.data[i - 1]
  end

  function mt.__index:getPtr (i)
    return self.data + (i - 1)
  end

  function mt.__index:getSize ()
    return self.size
  end

  function mt.__index:getCapacity ()
    return self.capacity
  end

  function mt.__index:getData ()
    return self.data
  end

  function mt.__index:removeAt (i)
    self.size = self.size - 1
    Memory.MemMove(self.data + i - 1, self.data + i, elemSize * (self.size - i + 1))
  end

  function mt.__index:removeAtFast (i)
    self.size = self.size - 1
    self.data[i - 1] = self.data[self.size]
  end

  function mt.__index:set (i, v)
    self.data[i - 1] = v
  end

  function mt:__gc ()
    Memory.Free(self.data)
  end

  function mt:__len ()
    return self.size
  end

  function mt:__tostring ()
    local lines = { format('%s @ %p', T.niceName, self) }
    table.insert(lines, format('  size:     %d', self.size))
    table.insert(lines, format('  capacity: %d', self.capacity))
    return table.concat(lines, '\n')
  end

  return T
end

local function CArray (ElemT)
  if cache[ElemT.name] then
    return cache[ElemT.name]
  else
    local T = CreateCArray(ElemT)
    cache[ElemT.name] = T
    return T
  end
end

return CArray
