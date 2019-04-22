local Action = require('Game.Action')

local Undock = subclass(Action, function (self) end)

function Undock:clone ()
  return Undock()
end

function Undock:getName ()
  return 'Undock'
end

function Undock:onUpdateActive (e, dt)
  if e:getParent():hasDockable() then
    e:getParent():removeDocked(e)
  end
  e:popAction()
end

return Undock
