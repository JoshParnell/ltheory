--[[----------------------------------------------------------------------------
  Convenience class for building and sampling values from a discrete
  probability distribution.

  NOTE : The distribution will be normalized automatically -- no need to ensure
         that all weights sum to 1.

  TODO : Implement Alias Method for O(1) sampling. Sampling is currently O(n).
----------------------------------------------------------------------------]]--
local Distribution = class(function (self)
  self.values = {}
  self.weights = {}
end)

-- Add a single value, weight pair to the distribution
function Distribution:add (value, weight)
  insert(self.values, value)
  insert(self.weights, weight)
  self.cdf = nil
  self.totalWeight = nil
  return self
end

-- Add an entire table of value, weight pairs to the distribution
-- The table must be in the form { value1 = weight1, value2 = weight2, ... }
function Distribution:addTable (weightTable)
  for value, weight in pairs(weightTable) do
    self:add(value, weight)
  end
  return self
end

function Distribution:refresh ()
  local totalWeight = 0
  for i = 1, #self.weights do
    totalWeight = totalWeight + self.weights[i]
  end
  assert(totalWeight > 0, "Distribution has 0 total weight")

  self.cdf = {}
  local cumulative = 0
  for i = 1, #self.weights do
    local weightNorm = self.weights[i] / totalWeight
    cumulative = cumulative + weightNorm
    self.cdf[i] = cumulative
  end
  self.totalWeight = totalWeight
end

function Distribution:sample (rng)
  if not self.cdf then self:refresh() end
  local y = rng:getUniform()
  for i = 1, #self.cdf do
    if y <= self.cdf[i] then return self.values[i] end
  end
  return self.values[#self.values]
end

function Distribution:__tostring ()
  self:refresh()
  local lines = { 'Distribution {' }
  for i = 1, #self.values do
    lines[#lines + 1] = format('  %s : %.2f  (%.2f%% chance)',
      tostring(self.values[i]),
      self.weights[i],
      100.0 * (self.weights[i] / self.totalWeight))
  end
  lines[#lines + 1] = '}'
  return table.concat(lines, '\n')
end

return Distribution
