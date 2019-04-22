--[[ TODO ----------------------------------------------------------------------
  - AI should use pathfinding
    - Pathfinding should be implemented as a query that goes through the current
      system and uses a lazy NavCache component
    - NavCache must be invalidated upon construction of new transporation
      infrastructure
  - getTravelTime should use route:getTravelTime, not Euclidean
  - Should be possible to do bidirectional trade routes, although reasoning
    about such routes is much more difficult than unidirectional routes
    - Need to use stochastic sampling here, going to have to abandon exhaustive
      search for sure
----------------------------------------------------------------------------]]--

local Job = require('Game.Job')

local Transport = subclass(Job, function (self, src, dst, item)
  self.src = src
  self.dst = dst
  self.item = item
end)

function Transport:clone ()
  return Transport(self.src, self.dst, self.item)
end

function Transport:getFlows (e)
  local capacity = e:getInventoryCapacity()
  local duration = self:getTravelTime(e)
  local count = math.floor(capacity / self.item:getMass())
  return {
    Flow(self.item, -count / duration, self.src),
    Flow(self.item,  count / duration, self.dst)
  }
end

function Transport:getName ()
  return format('Transport %s from %s to %s',
    self.item:getName(),
    self.src:getName(),
    self.dst:getName())
end

function Transport:getPayout (e)
  local capacity = e:getInventoryCapacity()
  local maxCount = math.floor(capacity / self.item:getMass())
  local count, profit = self.src:getTrader():computeTrade(self.item, maxCount, self.dst:getTrader())
  return profit
end

function Transport:getTravelTime (e)
  return 2.0 * self.src:getDistance(self.dst) / e:getTopSpeed()
end

function Transport:onUpdateActive (e, dt)
  if not e.jobState then e.jobState = 0 end
  e.jobState = e.jobState + 1

  if e.jobState == 1 then
    local capacity = e:getInventoryCapacity()
    local maxCount = math.floor(capacity / self.item:getMass())
    local count, profit = self.src:getTrader():computeTrade(self.item, maxCount, self.dst:getTrader())
    -- printf("[TRADE] %d x %s from %s -> %s, expect %d profit", count, self.item:getName(), self.src:getName(), self.dst:getName(), profit)
    e.tradeCount = count
    e:pushAction(Actions.DockAt(self.src))
  elseif e.jobState == 2 then
    for i = 1, e.tradeCount do self.src:getTrader():buy(e, self.item) end
  elseif e.jobState == 3 then
    e:pushAction(Actions.Undock())
  elseif e.jobState == 4 then
    e:pushAction(Actions.DockAt(self.dst))
  elseif e.jobState == 5 then
    while self.dst:getTrader():sell(e, self.item) do end
  elseif e.jobState == 6 then
    e:pushAction(Actions.Undock())
  elseif e.jobState == 7 then
    e:popAction()
    e.jobState = nil
  end
end

return Transport
