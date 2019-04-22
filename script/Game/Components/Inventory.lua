local Entity = require('Game.Entity')

function Entity:addInventory (capacity)
  assert(not self.inventory)
  assert(capacity)
  self.inventory = {}
  self.inventoryCapacity = capacity
  self.inventoryFree = capacity
  self:register(Event.Debug, Entity.debugInventory)
end

function Entity:addItem (item, count)
  assert(self.inventory)
  assert(count >= 0)
  local mass = count * item:getMass()
  if mass > self.inventoryFree then return false end
  self.inventoryFree = self.inventoryFree - mass
  self.inventory[item] = self:getItemCount(item) + count
  return true
end

function Entity:debugInventory (state)
  local ctx = state.context
  ctx:text('Inventory')
  ctx:indent()
  for k, v in pairs(self.inventory) do
    ctx:text('%d x %s', v, k:getName())
  end
  ctx:undent()
end

function Entity:getInventory ()
  assert(self.inventory)
  return self.inventory
end

function Entity:getInventoryCapacity ()
  assert(self.inventory)
  return self.inventoryCapacity
end

function Entity:getInventoryFree ()
  assert(self.inventory)
  return self.inventoryFree
end

function Entity:getItemCount (item)
  assert(self.inventory)
  return self.inventory[item] or 0
end

function Entity:hasInventory ()
  return self.inventory ~= nil
end

function Entity:hasItem (item, count)
  assert(self.inventory)
  return self:getItemCount(item) >= count
end

function Entity:refreshInventory ()
  assert(self.inventory)
  self.inventoryFree = self.inventoryCapacity
  for k, v in pairs(self.inventory) do
    self.inventoryFree = self.inventoryFree - v * k:getMass()
  end
end

function Entity:removeItem (item, count)
  assert(self.inventory)
  assert(count >= 0)
  if self:getItemCount(item) < count then
    return false
  end

  local mass = count * item:getMass()
  self.inventoryFree = self.inventoryFree + mass
  self.inventory[item] = self:getItemCount(item) - count
  if self.inventory[item] == 0 then
    self.inventory[item] = nil
  end

  return true
end

function Entity:setInventoryCapacity (capacity)
  assert(self.inventory)
  self.inventoryCapacity = capacity
  self:refreshInventory()
end
