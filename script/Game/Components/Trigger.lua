local Entity = require('Game.Entity')

local function onAddedToParent (self, event)
  -- TODO : Should probably move this to the parent.
  if event.parent.physics ~= nil then
    event.parent.physics:addTrigger(self.trigger)
  end
end

local function onRemovedFromParent (self, event)
	-- TODO : Should probably move this to the parent.
  if event.parent.physics ~= nil then
    event.parent.physics:removeTrigger(self.trigger)
  end
end

function Entity:addTrigger (halfExtents)
  assert(not self.trigger)
  self.trigger = Trigger.CreateBox(halfExtents)

  self:register(Event.AddedToParent, onAddedToParent)
  self:register(Event.RemovedFromParent, onRemovedFromParent)
end

-- TODO : Deal with naming conflicts
function Entity:triggerAttach (parent, pos)
  assert(self.trigger)
  self.trigger:attach(parent, pos)
end

function Entity:triggerDetach (parent)
  assert(self.trigger)
  self.trigger:detach(parent)
end

function Entity:getContentsCount ()
  assert(self.trigger)
  return self.trigger:getContentsCount()
end

function Entity:getContents (index)
  assert(self.trigger)
  return self.trigger:getContents(index)
end

function Entity:triggerSetCollisionMask (mask)
  assert(self.trigger)
  self.trigger:setCollisionMask(mask)
end

function Entity:triggerSetPos (pos)
  assert(self.trigger)
  self.trigger:setPos(pos)
end

function Entity:triggerSetPosLocal (pos)
  assert(self.trigger)
  self.trigger:setPosLocal(pos)
end
