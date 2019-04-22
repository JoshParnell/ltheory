local Action = require('Game.Action')

local Escort = subclass(Action, function (self, target, offset)
  self.target = target
  self.offset = offset
end)

-- TODO : Compute a closing velocity to get correct lead time
local kLeadTime = 1

function Escort:clone ()
  return Escort(self.target, self.offset)
end

function Escort:getName ()
  return format('Escort %s', self.target:getName())
end

function Escort:onUpdateActive (e, dt)
  if not self.target:isAlive() then
    e:popAction()
    return
  end

  local target = self.target
  self:flyToward(e,
    target:toWorldScaled(self.offset) + target:getVelocity():scale(kLeadTime),
    target:getForward(),
    target:getUp())

  -- TODO : Attack nearby hostiles
end

return Escort
