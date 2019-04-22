--[[----------------------------------------------------------------------------
  Event Manager object for writing event-driven logic. Use multiple event
  manager objects to separate events based on logical application boundaries.
----------------------------------------------------------------------------]]--
local EventManagerT   = {}
EventManagerT.__index = {}

local function makeDispatch (id)
  local fn = function (self, id, data)
    local listeners = self.listeners[id]
    for i = 1, #listeners do
      data = listeners[i](data) or data
    end
    return data
  end
  return fn
end

function EventManagerT.__index:call (id, data)
  local dispatch = self.dispatch[id]
  if dispatch then
    dispatch(self, id, data)
  end
end

function EventManagerT.__index:listen (id, listener)
  local listeners = self.listeners[id]
  if listeners then
    table.insert(listeners, listener)
  else
    self.dispatch[id] = makeDispatch(id)
    self.listeners[id] = { listener }
  end
end

function EventManagerT.__index:listenFirst (id, listener)
  local listeners = self.listeners[id]
  if listeners then
    table.insert(listeners, listener, 0)
  else
    self.dispatch[id] = makeDispatch(id)
    self.listeners[id] = { listener }
  end
end

local function CreateEventManager ()
  return setmetatable({
    dispatch = {},
    listeners = {},
  }, EventManagerT)
end

return CreateEventManager
