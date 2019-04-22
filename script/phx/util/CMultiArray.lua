--[[----------------------------------------------------------------------------
  A heterogeneous array for storing objects of different types. MultiArray
  uses a separate internal array for each type of object added to the structure.
  This allows for efficient, type-predicated iteration.
----------------------------------------------------------------------------]]--
local Type     = require('phx.util.Type')
local CArray   = require('phx.util.CArray')
local CPointer = require('phx.util.CPointer')

local T = Type.Create('MultiArray')
T.niceName = 'MultiArray'

ffi.cdef [[
  typedef struct MultiArray_Node {
    int32_t size;
    int32_t capacity;
    char*   data;
    int32_t tid;
  } MultiArray_Node;
]]

ffi.cdef [[
  typedef struct MultiArray {
    int32_t size;
    int32_t capacity;
    struct MultiArray_Node* data;
  } MultiArray;
]]

local mt = T:getMetatable()
local elemSize = ffi.sizeof('void*')
local nodeSize = ffi.sizeof('MultiArray_Node')

local function arrayAdd (arr, elem)
  libphx.CArray_Grow(ffi.cast('CArray*', arr), elemSize)
  local pData = ffi.cast('void**', arr.data)
  pData[arr.size - 1] = elem
end

function mt.__index:add (elem)
  local tid = elem:getType().id
  for i = 0, self.size - 1 do
    if self.data[i].tid == tid then
      arrayAdd(self.data[i], elem)
      return
    end
  end

  libphx.CArray_Grow(ffi.cast('CArray*', self), nodeSize)
  local arr = self.data[self.size - 1]
  arr.tid = tid
  arr.size = 0
  arr.capacity = 0
  arr.data = nil
  arrayAdd(arr, elem)
end

function mt.__index:clear ()
  for i = 0, self.size - 1 do
    libphx.CArray_Clear(ffi.cast('CArray*', self.data[i]))
  end
  libphx.CArray_Clear(ffi.cast('CArray*', self))
end

function mt.__index:free ()
  for i = 0, self.size - 1 do
    libphx.CArray_Free(ffi.cast('CArray*', self.data[i]))
  end
  libphx.CArray_Free(ffi.cast('CArray*', self))
end

function mt.__index:foreach (fn)
  for i = 1, #self do
    local objs = self:get(i)
    for j = 1, #objs do fn(objs:get(j)) end
  end
end

function mt.__index:get (index)
  local arr = self.data[index - 1]
  local ArrayT = CArray(CPointer(Type.GetByID(arr.tid)))
  return ArrayT:cast(self.data + index - 1)
end

function mt.__index:getType (index)
  local arr = self.data[index - 1]
  return Type.GetByID(arr.tid)
end

function mt.__index:getByType (typeName)
  local T = Type.Get(typeName)
  for i = 1, #self do
    local arr = self.data[i - 1]
    if arr.tid == T.id then
      local ArrayT = CArray(CPointer(T))
      return ArrayT:cast(self.data + i - 1)
    end
  end
  return nil
end

function mt.__index:getElemType (index)
  return Type.GetByID(self.data[index - 1].tid)
end

function mt.__index:getSize ()
  return self.size
end

function mt:__len ()
  return self.size
end

function mt:__tostring ()
  local lines = { 'MultiArray:' }
  for i = 0, self.size - 1 do
    local arr = self.data[i]
    local tp = Type.GetByID(arr.tid)
    table.insert(lines, format('  %s : %d', tp.niceName, arr.size))
  end
  return table.concat(lines, '\n')
end

return T
