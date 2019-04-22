-- TODO : Rename to 'Container' / 'Contained'

local Entity = require('Game.Entity')

local function broadcast (self, event)
  for i = #self.children, 1, -1 do
    if self.children[i].parent == self then
      self.children[i]:send(event)
    else
      self.children[i] = self.children[#self.children]
      self.children[#self.children] = nil
    end
  end
end

function Entity:addChild (child)
  assert(self.children)
  if child.parent == self then return end
  if child.parent then child.parent:removeChild(child) end
  insert(self.children, child)
  child.parent = self
  self:send(Event.ChildAdded(child))
  child:send(Event.AddedToParent(self))
end

function Entity:addChildren ()
  assert(not self.children)
  self.children = {}
  self:register(Event.Broadcast, broadcast)
end

function Entity:getChildren ()
  assert(self.children)
  return self.children
end

function Entity:getParent ()
  return self.parent
end

function Entity:getRoot ()
  local root = self
  while root:getParent() do
    root = root:getParent()
  end
  return root
end

function Entity:hasChildren ()
  return self.children ~= nil
end

function Entity:iterChildren ()
  assert(self.children)
  return ipairs(self.children)
end

function Entity:removeChild (child)
  assert(self.children)
  assert(child.parent == self)
  child.parent = nil
  self:send(Event.ChildRemoved(child))
  child:send(Event.RemovedFromParent(self))
end
