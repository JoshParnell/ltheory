--[[ TODO ----------------------------------------------------------------------
  Error accumulation due to += / -= on FP value. The quick solution is integer
  discretization, but, as explored in the econ sandbox, there are numerous
  other issues with not periodically recomputing flow. In reality, we will need
  to maintain a list of all active jobs contributing to a given node's flow
  such that we can recompute periodically.
----------------------------------------------------------------------------]]--

local Entity = require('Game.Entity')

function Entity:addFlows ()
  assert(not self.flows)
  self.flows = {}
  self:register(Event.Debug, Entity.debugFlows)
end

function Entity:debugFlows (state)
  local ctx = state.context
  ctx:text('Economic Flows')
  ctx:indent()
  for k, v in pairs(self.flows) do
    ctx:text('%s : %.2f', k:getName(), v)
  end
  ctx:undent()
end

function Entity:getFlow (item)
  assert(self.flows)
  return self.flows[item] or 0
end

function Entity:getFlows ()
  assert(self.flows)
  return self.flows
end

function Entity:hasFlows ()
  return self.flows ~= nil
end

function Entity:modFlow (item, value)
  assert(self.flows)
  self:setFlow(item, self:getFlow(item) + value)
end

function Entity:setFlow (item, value)
  assert(self.flows)
  self.flows[item] = value
end
