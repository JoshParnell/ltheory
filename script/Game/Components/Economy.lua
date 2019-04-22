local Entity = require('Game.Entity')
local Jobs = requireAll('Game.Jobs')

--------------------------------------------------------------------------------

local Economy = class(function (self, parent)
  self.parent = parent
  self.factories = {}
  self.flows = {}
  self.goods = {}
  self.jobs = {}
  self.markets = {}
  self.traders = {}
  self.yields = {}
end)

-- TODO : Economy cache should be updated infrequently and the update should be
--        spread over many frames.
function Economy:update (dt)
  Profiler.Begin('Economy.Update')
  table.clear(self.factories)
  table.clear(self.flows)
  table.clear(self.markets)
  table.clear(self.jobs)
  table.clear(self.traders)
  table.clear(self.yields)

  do -- Cache points-of-interest
    for _, e in self.parent:iterChildren() do
      if e:hasFactory() then insert(self.factories, e) end
      if e:hasFlows() then insert(self.flows, e) end
      if e:hasMarket() then insert(self.markets, e) end
      if e:hasTrader() then insert(self.traders, e) end
      if e:hasYield() then insert(self.yields, e) end
    end
  end

  do -- Cache mining jobs
    for _, src in ipairs(self.yields) do
      for _, dst in ipairs(self.markets) do
        insert(self.jobs, Jobs.Mine(src, dst))
      end
    end
  end

  if false then
    do -- Cache trade jobs from positive to negative flow
      for _, src in ipairs(self.markets) do
        for item, srcFlow in pairs(src:getFlows()) do
          if srcFlow > 0 then
            for _, dst in ipairs(self.markets) do
              if dst:getFlow(item) < 0 then
                insert(self.jobs, Jobs.Transport(src, dst, item))
              end
            end
          end
        end
      end
    end
  end

  -- Cache profitable trade offers
  for _, src in ipairs(self.traders) do
    for item, data in pairs(src:getTrader().elems) do
      local buyPrice = src:getTrader():getBuyFromPrice(item, 1)
      for _, dst in ipairs(self.traders) do
        local sellPrice = dst:getTrader():getSellToPrice(item, 1)
        if buyPrice < sellPrice then
          insert(self.jobs, Jobs.Transport(src, dst, item))
        end
      end
    end
  end

  do -- Compute net flow of entire economy
    -- Clear current flow
    for k, v in pairs(self.parent.flows) do self.parent.flows[k] = 0 end

    -- Sum all flows
    for _, e in ipairs(self.flows) do
      for k, v in pairs(e.flows) do
        self.parent.flows[k] = (self.parent.flows[k] or 0) + v
      end
    end
  end

  do -- Compute commodity metrics
    self.goods = {}
  end

  Profiler.End()
end

function Economy:debug (ctx)
  ctx:text('Economy')
  ctx:indent()
  ctx:text('%d jobs', #self.jobs)
  ctx:text('%d markets', #self.markets)
  for item, data in pairs(self.goods) do
    ctx:text('%s', item:getName())
    ctx:indent()
    -- ctx:text('BUYING  : min = %.2f, max = %.2f', data.buyMin, data.buyMax)
    -- ctx:text('SELLING : min = %.2f, max = %.2f', data.sellMin, data.sellMax)
    ctx:undent()
  end
end

--------------------------------------------------------------------------------

function Entity:addEconomy ()
  assert(not self.economy)
  self.economy = Economy(self)
  self:register(Event.Debug, Entity.debugEconomy)
  self:register(Event.Update, Entity.updateEconomy)
end

function Entity:debugEconomy (state)
  self.economy:debug(state.context)
end

function Entity:getEconomy ()
  assert(self.economy)
  return self.economy
end

function Entity:hasEconomy ()
  return self.economy ~= nil
end

function Entity:updateEconomy (state)
  self.economy:update(state.dt)
end

--------------------------------------------------------------------------------
