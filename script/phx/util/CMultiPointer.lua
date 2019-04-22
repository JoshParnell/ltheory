--[[----------------------------------------------------------------------------
  A type-erased pointer, capable of storing a pointer to any type of object
  and providing a simple mechanism to cast back to the actual type.
----------------------------------------------------------------------------]]--
local Type = require('phx.util.Type')

local T = Type.Create('MultiPointer')

ffi.cdef [[
  typedef struct MultiPointer {
    void* p;
    int32_t tid;
  } MultiPointer;
]]

local mt = T:getMetatable()

function mt.__index:get ()
  if self.p == nil then
    return nil
  else
    local tp = Type.GetByID(self.tid)
    return ffi.cast(tp.ptrName, self.p)
  end
end

function mt.__index:isNull ()
  return self.p == nil
end

function mt.__index:notNull ()
  return self.p ~= nil
end

function mt.__index:set (elem)
  if elem == nil then
    self.p = nil
    self.tid = 0
  else
    self.p = ffi.cast('void*', elem)
    self.tid = elem:getType().id
  end
end

function mt:__tostring ()
  if self.p ~= nil then
    local tp = Type.GetByID(self.tid)
    return format('MultiPointer [%s @ %p]', tp.niceName, self.p)
  else
    return 'MultiPointer [nil]'
  end
end

return T
