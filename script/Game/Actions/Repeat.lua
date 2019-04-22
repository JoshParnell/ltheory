local Action = require('Game.Action')

local Repeat = subclass(Action, function (self, actions)
  self.actions = actions
end)

function Repeat:getName ()
  return 'Repeat'
end

function Repeat:onUpdateActive (e, dt)
  for i = #self.actions, 1, -1 do
    e:pushAction(self.actions[i]:clone())
  end
end

return Repeat
