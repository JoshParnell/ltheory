local Event = {}

function Event.AddedToParent (parent)
  return {
    type = Event.AddedToParent,
    parent = parent,
  }
end

function Event.Broadcast (event)
  return {
    type = Event.Broadcast,
    event = event,
  }
end

function Event.ChildAdded (child)
  return {
    type = Event.ChildAdded,
    child = child,
  }
end

function Event.ChildRemoved (child)
  return {
    type = Event.ChildRemoved,
    child = child,
  }
end

function Event.Damaged (amount, source)
  return {
    type = Event.Damaged,
    amount = amount,
    source = source,
  }
end

function Event.Debug (context)
  return {
    type = Event.Debug,
    context = context,
  }
end

function Event.Destroyed ()
  return {
    type = Event.Destroyed,
  }
end

function Event.RemovedFromParent (parent)
  return {
    type = Event.RemovedFromParent,
    parent = parent,
  }
end

function Event.Render (mode, eye)
  return {
    type = Event.Render,
    mode = mode,
    eye = eye,
  }
end

function Event.Update (dt)
  return {
    type = Event.Update,
    dt = dt,
  }
end

return Event
