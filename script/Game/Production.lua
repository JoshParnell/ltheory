local Flow = require('Game.Flow')

local all = {}

local Production = class(function (self, name)
  self.name = name
  self.inputs = {}
  self.outputs = {}
  self.duration = 1
  insert(all, self)
end)

function Production.All ()
  return all
end

function Production:addInput (item, count)
  assert(item)
  assert(count)
  insert(self.inputs, { item = item, count = count })
  return self
end

function Production:addOutput (item, count)
  assert(item)
  assert(count)
  insert(self.outputs, { item = item, count = count })
  return self
end

function Production:getDuration ()
  return self.duration
end

function Production:getFlows (location)
  local flows = {}
  local duration = self:getDuration()
  for _, input in self:iterInputs() do
    insert(flows, Flow(input.item, -input.count / duration, location))
  end
  for _, output in self:iterOutputs() do
    insert(flows, Flow(output.item,  output.count / duration, location))
  end
  return flows
end

function Production:getName ()
  return self.name
end

-- TODO : Unify with Job:getPressure via 'FlowList' type
function Production:getPressure (location)
  local flows = self:getFlows(location)
  local pressure = 0
  for _, flow in ipairs(flows) do
    local prev = flow.location:getFlow(flow.item)
    local curr = prev + flow.rate
    pressure = pressure + (curr*curr - prev*prev)
  end
  return pressure
end

function Production:iterInputs ()
  return ipairs(self.inputs)
end

function Production:iterOutputs ()
  return ipairs(self.outputs)
end

function Production:setDuration (duration)
  self.duration = duration
end

return Production
