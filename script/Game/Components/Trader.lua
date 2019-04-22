local Entity = require('Game.Entity')
local Credit = require('Game.Item').Credit

--------------------------------------------------------------------------------

local Trader = class(function (self, parent)
  self.parent = parent
  self.credits = 0
  self.elems = {}
end)

function Trader:getData (item)
  if not self.elems[item] then
    self.elems[item] = {
      asks = {},
      bids = {},
      asksQueue = {},
      bidsQueue = {},
      totalAsk = 0,
      totalAskPrice = 0,
      totalBid = 0,
      totalBidPrice = 0,
      escrow = 0,
    }
  end
  return self.elems[item]
end

function Trader:addAsk (item, price)
  local data = self:getData(item)
  if not self.parent:removeItem(item, 1) then return false end
  data.escrow = data.escrow + 1
  insert(data.asksQueue, price)
  return true
end

function Trader:addBid (item, price)
  local data = self:getData(item)
  -- TODO : Remove credits
  insert(data.bidsQueue, price)
  return true
end

-- Return the maximum profitable volume and corresponding total profit from
-- buying item here and selling at dst
function Trader:computeTrade (item, maxCount, dst)
  local src = self

  local asks = src:getData(item).asks
  local bids = dst:getData(item).bids
  local count = 0
  local profit = 0

  local i = 1
  while count < maxCount do
    local ask = asks[i]
    local bid = bids[i]
    if not ask or not bid or ask >= bid then break end
    count = count + 1
    profit = profit + (bid - ask)
    i = i + 1
  end

  return count, profit
end

function Trader:getBidVolume (item)
  local data = self:getData(item)
  return #data.bids + #data.bidsQueue
end

function Trader:getAskVolume (item)
  local data = self:getData(item)
  return #data.asks + #data.asksQueue
end

function Trader:getBuyFromPrice (item, count)
  local price = 0
  local asks = self:getData(item).asks
  for i = 1, count do
    price = price + (asks[i] or math.huge)
  end
  return price
end

function Trader:getSellToPrice (item, count)
  local price = 0
  local bids = self:getData(item).bids
  for i = 1, count do
    price = price + (bids[i] or 0)
  end
  return price
end

function Trader:buy (asset, item)
  local player = asset:getOwner()
  local data = self:getData(item)
  if #data.asks == 0 then return false end
  local price = data.asks[1]
  assert(data.escrow > 0)
  if not player:hasItem(Credit, price) then return false end

  asset:addItem(item, 1)
  player:removeItem(Credit, price)
  self.credits = self.credits + price
  data.totalAsk = data.totalAsk + 1
  data.totalAskPrice = data.totalAskPrice + price
  data.escrow = data.escrow - 1
  remove(data.asks, 1)
  return true
end

function Trader:sell (asset, item)
  local player = asset:getOwner()
  local data = self:getData(item)
  if #data.bids == 0 then return false end
  if not asset:hasItem(item, 1) then return false end

  local price = data.bids[1]
  asset:removeItem(item, 1)
  player:addItem(Credit, price)
  self.credits = self.credits - price
  data.totalBid = data.totalBid + 1
  data.totalBidPrice = data.totalBidPrice + price
  self.parent:addItem(item, 1)
  remove(data.bids, 1)
  return true
end

local function sortAsks (a, b)
  return a < b
end

local function sortBids (a, b)
  return a > b
end

function Trader:update ()
  for item, data in pairs(self.elems) do
    if #data.asksQueue > 0 then
      for i, v in ipairs(data.asksQueue) do insert(data.asks, v) end
      table.clear(data.asksQueue)
      table.sort(data.asks, sortAsks)
    end

    if #data.bidsQueue > 0 then
      for i, v in ipairs(data.bidsQueue) do insert(data.bids, v) end
      table.clear(data.bidsQueue)
      table.sort(data.bids, sortBids)
    end
  end
end

--------------------------------------------------------------------------------

function Entity:addTrader ()
  assert(not self.trader)
  self.trader = Trader(self)
  self:register(Event.Debug, Entity.debugTrader)
  self:register(Event.Update, Entity.updateTrader)
end

function Entity:debugTrader (state)
  local ctx = state.context
  ctx:text('Trader')
  ctx:indent()
  ctx:text('Credits: %d', self.trader.credits)
  for item, data in pairs(self.trader.elems) do
    ctx:text('%s', item:getName())
    ctx:indent()
    if #data.bids > 0 then
      ctx:text('[BID] Vol: %d  Hi: %d', #data.bids, data.bids[1])
    end
    if #data.asks > 0 then
      ctx:text('[ASK] Vol: %d  Lo: %d', #data.asks, data.asks[1])
    end
    ctx:undent()
  end
  ctx:undent()
end

function Entity:getTrader ()
  assert(self.trader)
  return self.trader
end

function Entity:hasTrader ()
  return self.trader ~= nil
end

function Entity:updateTrader (state)
  self.trader:update(state.dt)
end

--------------------------------------------------------------------------------
