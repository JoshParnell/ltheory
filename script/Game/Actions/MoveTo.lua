local Action = require('Game.Action')

local rng = RNG.FromTime()

local MoveTo = subclass(Action, function (self, target, range)
  self.target = target
  self.range = range
end)

function MoveTo:clone ()
  return MoveTo(self.target, self.range)
end

function MoveTo:getName ()
  return format('MoveTo %s', self.target:getName())
end

function MoveTo:onUpdateActive (e, dt)
  if e:getMinDistance(self.target) <= self.range then
    e:popAction()
    return
  end

  if Config.debug.instantJobs then
    local p = e:getPos()
    local dp = self.target:getPos() - p
    e:setPos(p + dp:normalize():scale(rng:getUniform() * min(dp:length(), dt * Config.debug.jobSpeed)))
  else
    self:flyToward(e,
      self.target:getPos(),
      e:getForward(),
      e:getUp())
  end
end

return MoveTo
