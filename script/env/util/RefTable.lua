local RefTable = class(function (self)
  self.refs = {}
  self.freelist = {}
  self.nextID = 1
end)

function RefTable:acquire (t)
  if #self.freelist > 0 then
    local v = self.freelist[#self.freelist]
    self.freelist[#self.freelist] = nil
    self.refs[v] = t
    return v
  else
    local v = self.nextID
    self.nextID = self.nextID + 1
    self.refs[v] = t
    return v
  end
end

function RefTable:get (id)
  return self.refs[id]
end

function RefTable:release (id)
  assert(self.refs[id])
  self.refs[id] = nil
  self.freelist[#self.freelist + 1] = id
end

return RefTable
