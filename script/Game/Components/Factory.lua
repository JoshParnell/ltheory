local Entity = require('Game.Entity')

--------------------------------------------------------------------------------

local Factory = class(function (self, parent)
  self.parent = parent
  self.prods = {}
  self.time = 0
  self.timeOnline = 0
end)

function Factory:addProduction (type)
  local prod = {
    type = type,
    t = 0,
    active = false,
    blocked = false,
    askTimers = {},
    bidTimers = {},
  }

  insert(self.prods, prod)
  local duration = type:getDuration()

  do -- Update flows based on inputs / outputs of this production
    for _, input in type:iterInputs() do
      local rate = -input.count / duration
      self.parent:modFlow(input.item, rate)
      insert(prod.bidTimers, { item = input.item, value = 0, max = duration / input.count })
    end

    for _, output in type:iterOutputs () do
      local rate = output.count / duration
      self.parent:modFlow(output.item, rate)
      insert(prod.askTimers, { item = output.item, value = 0, max = duration / output.count })
    end
  end
end

-- Is the factory stalled due to a lack of inputs or excess of outputs at the
-- moment?
function Factory:isBlocked ()
  for _, prod in ipairs(self.prods) do
    if prod.blocked then return true end
  end
  return false
end

-- Get the fraction of time that this factory has been active (i.e., not
-- blocked)
function Factory:getUptime ()
  return self.timeOnline / self.time
end

function Factory:updateProduction (prod, dt)
  if not prod.active then
    -- Check inventory for presence of required inputs
    for _, input in prod.type:iterInputs() do
      if not self.parent:hasItem(input.item, input.count) then
        prod.blocked = true
        return
      end
    end

    prod.blocked = false

    -- Entity has all the necessary inputs, let's start a round of production
    for _, input in prod.type:iterInputs() do
      self.parent:removeItem(input.item, input.count)
    end

    prod.active = true
    prod.t = prod.type.duration
  end

  if prod.active then
    prod.t = prod.t - dt
    if prod.t <= 0 then
      prod.active = false
      for i, output in prod.type:iterOutputs() do
        -- TODO : How to handle failure when a factory finishes a production
        --        for which the output inventory has insufficient capacity?
        assert(self.parent:addItem(output.item, output.count))
      end
    end
  end
end

-- Buy inputs and sell outputs
function Factory:updateTradeOrders (prod, dt)
  local trader = self.parent:getTrader()
  local duration = prod.type:getDuration()
  
  -- TODO : Intelligently compute price ranges via estimation using item
  --        intrinsic energy

  local askSlope = 0.995
  local bidSlope = 0.995
  local maxAsk = 100 / askSlope
  local maxBid = 100 / bidSlope

  for _, timer in ipairs(prod.askTimers) do
    timer.value = timer.value + dt
    if timer.value >= timer.max then
      timer.value = timer.value - timer.max
      local price = askSlope * (trader:getData(timer.item).asks[1] or maxAsk)
      trader:addAsk(timer.item, price)
    end
  end

  for _, timer in ipairs(prod.bidTimers) do
    timer.value = timer.value + dt
    if timer.value >= timer.max then
      timer.value = timer.value - timer.max
      local price = (trader:getData(timer.item).bids[1] or 0)
      price = maxBid - bidSlope * (maxBid - price)
      trader:addBid(timer.item, price)
    end
  end
end

function Factory:update (dt)
  self.time = self.time + dt
  if not self:isBlocked() then self.timeOnline = self.timeOnline + dt end

  for _, prod in ipairs(self.prods) do
    self:updateProduction(prod, dt)
    -- NOTE : Disabled trade orders for the moment due to not having limits on
    --        max active orders, leading to stalling the entire game via tens
    --        of thousands of individual energy cell orders...
    -- self:updateTradeOrders(prod, dt)
  end
end

--------------------------------------------------------------------------------

function Entity:addFactory ()
  assert(not self.factory)
  self.factory = Factory(self)
  self:register(Event.Update, Entity.updateFactory)
  self:register(Event.Debug, Entity.debugFactory)
end

function Entity:addProduction (type)
  assert(self.factory)
  self.factory:addProduction(type)
end

function Entity:debugFactory (state)
  local ctx = state.context
  ctx:text('Factory')
  ctx:indent()
  ctx:text('<< %s >>', self.factory:isBlocked() and 'OFFLINE' or 'ONLINE')
  ctx:text('Uptime: %.0f%%', 100 * self.factory:getUptime())
  ctx:undent()
end

function Entity:getFactory ()
  assert(self.factory)
  return self.factory
end

function Entity:hasFactory ()
  return self.factory ~= nil
end

function Entity:updateFactory (state)
  self.factory:update(state.dt)
end
