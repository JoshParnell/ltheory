local events = {}

-- TODO : Add a 'self' parameter so we don't have to create closures so often
function OnEvent (event, fn)
  local listeners = events[event]
  if not listeners then
    listeners = {}
    events[event] = listeners
  end
  listeners[#listeners + 1] = fn
end

function SendEvent (event, data)
  local listeners = events[event]
  if listeners then
    for i = 1, #listeners do
      listeners[i](data)
    end
  end
end
