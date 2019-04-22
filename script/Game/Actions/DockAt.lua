local Action = require('Game.Action')

local rng = RNG.FromTime()

-- TODO : Dock range should be specified by the dockable component
local kDockRange = 200

local function getTargetPos (e, target)
  local tp = target:getPos()
  local tr = target:getRadius()
  local tu = target:getUp()
  local er = e:getRadius()
  return tp - tu:muls(1.25*tr + er)
end

local DockAt = subclass(Action, function (self, target)
  self.target = target
end)

function DockAt:clone ()
  return DockAt(self.target)
end

function DockAt:getName ()
  return format('DockAt %s', self.target:getName())
end

function DockAt:onUpdateActive (e, dt)
  local tp = getTargetPos(e, self.target)
  if (e:getPos() - tp):length() <= kDockRange then
    self.target:addDocked(e)
    e:popAction()
    return
  end

  if Config.debug.instantJobs then
    local p = e:getPos()
    local dp = tp - p
    e:setPos(p + dp:normalize():scale(rng:getUniform() * min(dp:length(), dt * Config.debug.jobSpeed)))
  else
    local tf = self.target:getForward()
    local tu = self.target:getUp()
    self:flyToward(e, tp, -tf, tu)
  end
end

-- TODO : Update this when we have real dock positions.

return DockAt
