local Entity = require('Game.Entity')

local function iterateAssets (s)
  s.i = s.i + 1
  return s.list[s.i]
end

function Entity:addAsset (asset)
  assert(self.assets)
  assert(asset.owner == nil)
  insert(self.assets, asset)
  asset.owner = self
end

function Entity:addAssets ()
  assert(not self.assets)
  self.assets = {}
end

function Entity:getAssets ()
  assert(self.assets)
  return self.assets
end

function Entity:hasAssets ()
  return self.assets ~= nil
end

-- TODO : Surely there is a way to achieve 'for x in e:iterBlah' without having
--        to resort to table creation??
function Entity:iterAssets ()
  return iterateAssets, { list = self.assets, i = 0 }
end

function Entity:removeAsset (asset)
  assert(self.assets)
  assert(asset.owner == self)
  asset.owner = nil
  for i, v in ipairs(self.assets) do
    if v == asset then
      self.assets[i] = self.assets[#self.assets]
      self.assets[#self.assets] = nil
      break
    end
  end
end
