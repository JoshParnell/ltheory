local Container = require('UI.Container')

local Stack = {}
Stack.__index = Stack
setmetatable(Stack, Container)

Stack.name = 'Stack'

function Stack.Create ()
  return setmetatable({ children = List() }, Stack)
end

return Stack
