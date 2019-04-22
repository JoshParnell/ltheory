local Action = require('Game.Action')

local MineAt = subclass(Action, function (self, target)
  assert(target:hasYield())
  self.target = target
end)

function MineAt:clone ()
  return MineAt(self.target)
end

function MineAt:getName ()
  return format('MineAt @ %s', self.target:getName())
end

function MineAt:onUpdateActive (e, dt)
  local item = self.target:getYield().item
  if Config.debug.instantJobs then
    while e:addItem(item, 1) do end
    e:popAction()
    return
  else
    -- TODO : dt-invariant extraction rate
    if not e:addItem(item, 1) then
      e:popAction()
      return
    end
  end
end

return MineAt
