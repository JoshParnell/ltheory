--[[ TODO ----------------------------------------------------------------------
  This is annoyingly-specific. Surely it can be wrapped up in a better, meatier
  feature. Remember in LTC++, you had a 'Computer' component that tracked
  targets, stored navigation information, AND did automatic caching of nearby
  obstacles.
----------------------------------------------------------------------------]]--

local Entity = require('Game.Entity')

function Entity:getTarget ()
  return self.target
end

function Entity:setTarget (target)
  self.target = target
end
