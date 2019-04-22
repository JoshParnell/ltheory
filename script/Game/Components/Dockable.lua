-- NOTE : Requires the Children component

local Entity = require('Game.Entity')

local function destroyed (self, source)
  if self:getOwner() then self:getOwner():removeAsset(self) end

  local children = self:getChildren()
  for i = #children, 1, -1 do
    local e = children[i]
    e:damage(10, source)
    self:removeDocked(e)
  end
end

function Entity:addDockable ()
  assert(not self.dockable)
  self.dockable = true
  self:register(Event.Destroyed, destroyed)
end

function Entity:addDocked (e)
  assert(self.dockable)
  self:addChild(e)
end

function Entity:getDockable ()
  assert(self.dockable)
  return self.dockable
end

function Entity:getDocked (e)
  assert(self.dockable)
  return self:getChildren()
end

function Entity:hasDockable ()
  return self.dockable ~= nil
end

function Entity:removeDocked (e)
  assert(self.dockable)
  self:getParent():addChild(e)
end
