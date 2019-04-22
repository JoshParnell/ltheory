local Entity = require('Game.Entity')

function Entity:addMessage (fmt, ...)
  assert(self.messages)
  insert(self.messages, format(fmt, ...))
end

function Entity:addMessages ()
  assert(not self.messages)
  self.messages = {}
end

function Entity:getMessages ()
  assert(self.messages)
  return self.messages
end
