local Action = require('Game.Action')

local Job = subclass(Action, function (self) end)

function Job:clone ()
  assert(false, 'NYI @ Job.clone')
end

function Job:getFlows (e)
  assert(false, 'NYI @ Job.getFlows')
end

function Job:getName ()
  assert(false, 'NYI @ Job.getName')
end

function Job:getPayout (e)
  assert(false, 'NYI @ Job.getPayout')
end

function Job:getPressure (e)
  local pressure = 0
  for _, flow in ipairs(self:getFlows(e)) do
    local prev = flow.location:getFlow(flow.item)
    local curr = prev + flow.rate
    pressure = pressure + (curr*curr - prev*prev)
  end
  return pressure
end

function Job:getTravelTime (e)
  assert(false, 'NYI @ Job.getTravelTime')
end

return Job
