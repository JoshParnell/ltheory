local Action = require('Game.Action')

local kJobIterations = 100

local Think = subclass(Action, function (self)
  self.timer = 0
  self.rng = RNG.FromTime()
end)

function Think:clone ()
  return Think()
end

function Think:getName ()
  return 'Think'
end

local function applyFlows (flows, mult)
  for _, flow in ipairs(flows) do
    flow.location:modFlow(flow.item, mult * flow.rate)
  end
end

function Think:manageAsset (asset)
  local root = asset:getRoot()
  local bestPressure = asset.job and asset.job:getPressure(asset) or math.huge
  local bestJob = asset.job
  for i = 1, kJobIterations do
    -- TODO : KnowsAbout check
    local job = self.rng:choose(root:getEconomy().jobs)
    if not job then break end

    local pressure = job:getPressure(asset)
    if pressure < bestPressure then
      bestPressure = pressure
      bestJob = job
    end
  end

  if bestJob then
    if asset.jobFlows then
      applyFlows(asset.jobFlows, -1)
      asset.jobFlows = nil
    end

    asset.job = bestJob
    asset.jobFlows = bestJob:getFlows(asset)
    applyFlows(asset.jobFlows, 1)

    asset:pushAction(bestJob)
  end
end

if true then -- Use payout, not flow
  function Think:manageAsset (asset)
    local root = asset:getRoot()
    local bestPayout = 0
    local bestJob = nil

    -- Consider re-running last job
    if asset.job then
      local payout = asset.job:getPayout(asset)
      if payout > bestPayout then
        bestPayout = payout
        bestJob = asset.job
      end
    end

    -- Consider changing to a new job
    for i = 1, kJobIterations do
      -- TODO : KnowsAbout check
      local job = self.rng:choose(root:getEconomy().jobs)
      if not job then break end

      local payout = job:getPayout(asset)
      if payout > bestPayout then
        bestPayout = payout
        bestJob = job
      end
    end

    if bestJob then
      asset.job = bestJob
      asset:pushAction(bestJob)
    end
  end

end

function Think:onUpdateActive (e, dt)
  Profiler.Begin('Action.Think')
  do -- Manage assets
    for asset in e:iterAssets() do
      if asset:getRoot():hasEconomy() and asset:isIdle() then
        self:manageAsset(asset)
      end
    end
  end

  self.timer = self.timer + dt
  do -- Capital expenditure
    if self.timer > 5 then
      -- 
    end
  end
  Profiler.End()
end

return Think
