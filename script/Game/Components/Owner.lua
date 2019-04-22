local Entity = require('Game.Entity')

function Entity:getOwner ()
  return self.owner
end

function Entity:getOwnerDisposition (target)
  if not self.owner then return 0 end
  return self.owner:getDisposition(target)
end

function Entity:getOwnerRoot ()
  local root = self
  while root:getOwner() do
    root = root:getOwner()
  end
  return root
end

function Entity:setOwner (owner)
  if self.owner then
    self.owner:removeAsset(self)
    self.owner = nil
  end

  if owner then
    owner:addAsset(self)
  end
end
