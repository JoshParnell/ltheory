--[[----------------------------------------------------------------------------
  Dispositions are normalized to the following scale:
     +1.0 = maximal friendliness
      0.0 = total neutrality
     -1.0 = maximal hostility
----------------------------------------------------------------------------]]--

local Entity = require('Game.Entity')

local kFriendlyThreshold = 0.5
local kHostileThreshold = -0.5

function Entity:addDispositions ()
  assert(not self.dispositions)
  self.dispositions = {}
end

function Entity:getDisposition (target)
  assert(self.dispositions)
  return self.dispositions[target] or 0
end

function Entity:isFriendlyTo (target)
  assert(self.dispositions)
  return self:getDisposition(target) >= kFriendlyThreshold
end

function Entity:isHostileTo (target)
  assert(self.dispositions)
  return self:getDisposition(target) <= kHostileThreshold
end

function Entity:modDisposition (target, amount)
  assert(self.dispositions)
  self:setDisposition(target, self:getDisposition(target) + amount)
end

function Entity:setDisposition (target, value)
  assert(self.dispositions)
  self.dispositions[target] = value
end

return {
  GetColor = function (disp)
    local x = 0.5 * disp + 0.5
    return Color(
      Math.Bezier3(x, 1.00, 0.10, 0.30),
      Math.Bezier3(x, 0.10, 0.75, 1.00),
      Math.Bezier3(x, 0.30, 1.50, 0.20),
      Math.Bezier3(x, 1.00, 1.00, 1.00))
  end
}
