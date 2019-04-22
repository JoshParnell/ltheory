local all = {}

local Item = class(function (self, name, mass, energyDensity)
  self.name = name
  self.mass = mass or 1
  self.energy = (energyDensity or 1) * self.mass
  insert(all, self)
end)

function Item.All ()
  return all
end

function Item:getEnergy ()
  return self.energy
end

function Item:getEnergyDensity ()
  return self.energy / self.mass
end

function Item:getMass ()
  return self.mass
end

function Item:getName ()
  return self.name
end

function Item:setEnergy (energy)
  self.energy = energy
  return self
end

Item.Credit = Item('Credit')
Item.Credit.mass = 0

return Item
