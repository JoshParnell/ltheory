--[[----------------------------------------------------------------------------
  Keeps track of all objects in the active universe system that match a given
  predicate. Predicates are expected to be constant for the life of the object
  (e.g. hasHealth, isShip, etc) and lists are only updated when the active
  system changes or objects are added to or removed from the active system.
----------------------------------------------------------------------------]]--
local Event = require('Game.Event')

local TrackingList = {}
TrackingList.__index = TrackingList

function TrackingList.Create (context, predicateFn)
  return setmetatable({
    context     = context,
    predicateFn = predicateFn,
    root        = nil,
    tracked     = List(),
  }, TrackingList)
end

function TrackingList:update ()
  local root = self.context:getRoot()
  if root ~= self.root then
    self.root = root
    self.root:register(Event.ChildAdded,   function (...) self:onChildAdded(...) end)
    self.root:register(Event.ChildRemoved, function (...) self:onChildRemoved(...) end)

    self.tracked:clear()
    for i, e in self.root:iterChildren() do
      if self.predicateFn(e) then self.tracked:add(e) end
    end
  end
end

function TrackingList:onChildAdded (entity, state)
  if self.predicateFn(state.child) then
    self.tracked:add(state.child)
  end
end

function TrackingList:onChildRemoved (entity, state)
  self.tracked:removeFast(state.child)
end

return TrackingList.Create

--[[ TODO : When we use e.g. isAlive, this is a dynamic value that will change
            over the course of the entity's lifetime. Not what this list is made
            for. ]]

-- TODO : Do we need to unregister root event listeners when root changes?
-- TODO : This only tracks immediate children. Is that ok?
