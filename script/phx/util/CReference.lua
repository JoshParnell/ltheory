--[[----------------------------------------------------------------------------
  The CReference type provides a mechanism for automatically managing the
  lifetimes of CTypes that have refCount fields. Using :set to assign the
  internal pointer will automatically increment and decrement the underlying
  object's refCount as necessary, and will destroy the object if the refCount
  reaches 0.

  NOTE : CReference is NOT for use with engine-level types, and will not work
         for automatically managing, for example, Meshes or Tex2Ds.
----------------------------------------------------------------------------]]--
local Type = require('phx.util.Type')
local cache = {}

local function CreateCReference (ElemT)
  ffi.cdef(format([[
    typedef struct _ref_%s {
      %s* p;
    } _ref_%s;
  ]], ElemT.name, ElemT.name, ElemT.name))

  local T = Type.Create('_ref_' .. ElemT.name, false)
  T.niceName = format('Reference<%s>', ElemT.niceName)

  local mt = T:getMetatable()
  function mt.__index:get ()
    if self.p == nil then
      return nil
    else
      return self.p
    end
  end

  function mt.__index:isNull ()
    return self.p == nil
  end

  function mt.__index:notNull ()
    return self.p ~= nil
  end

  function mt.__index:set (elem)
    if self.p ~= nil then
      self.p.refCount = self.p.refCount - 1
      if self.p.refCount <= 0 then
        self.p:getType():delete(self.p)
      end
    end

    self.p = elem

    if elem ~= nil then
      elem.refCount = elem.refCount + 1
    end
  end

  function mt.__gc ()
    self:set(nil)
  end

  function mt.__tostring ()
    if self.p ~= nil then
      return format('Reference<%s>[%p]', ElemT.niceName, self.p)
    else
      return format('Reference<%s>[nil]', ElemT.niceName)
    end
  end

  T:addOnDestruct(function (self)
    self:set(nil)
  end)

  T:setInitializer(function (self, elem)
    self:set(elem)
  end)

  return T
end

local function CReference (ElemT)
  if cache[ElemT.name] then
    return cache[ElemT.name]
  else
    local T = CreateCReference(ElemT)
    cache[ElemT.name] = T
    return T
  end
end

return CReference
