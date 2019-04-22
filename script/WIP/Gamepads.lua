local Gamepads = {}

local init = false
local active = nil
local connected = { map = {} }

local function initGamepad (self)
  self:setDeadzone(GamepadAxis.LeftX, 0.25)
  self:setDeadzone(GamepadAxis.LeftY, 0.25)
  self:setDeadzone(GamepadAxis.RightX, 0.25)
  self:setDeadzone(GamepadAxis.RightY, 0.25)
  self:setDeadzone(GamepadAxis.LTrigger, 0.1)
  self:setDeadzone(GamepadAxis.RTrigger, 0.1)
end

function Gamepads.GetAxis (axis, index)
  return active and active:getAxis(axis) or 0.0
end

function Gamepads.GetButton (button, index)
  if active then
    return active:getButton(button) and 1.0 or 0.0
  else
    return 0.0
  end
end

function Gamepads.GetButtonPressed (button, index)
  if active then
    return active:getButtonPressed(button)
  else
    return 0.0
  end
end

function Gamepads.GetButtonReleased (button, index)
  if active then
    return active:getButtonReleased(button)
  else
    return 0.0
  end
end

function Gamepads.GetIdleTime ()
  return active and active:getIdleTime() or 1e30
end

function Gamepads.Update ()
  Profiler.Begin('Gamepads.Update')
  if not init then
    init = true
    Gamepad.AddMappings('./res/gamecontrollerdb_205.txt')
  end

  do -- Remove any gamepads that have been disconnected
    for i = #connected, 1, -1 do
      local gamepad = connected[i]
      if not gamepad:isConnected() then
        local id = gamepad:getID()
        connected.map[id] = nil
        gamepad:close()
        remove(connected, i)
      end
    end
  end

  do -- Check for newly-added gamepads that can be opened
    for i = 0, Joystick.GetCount() - 1 do
      if Gamepad.CanOpen(i) then
        local gamepad = Gamepad.Open(i)
        local id = gamepad:getID()
        if not connected.map[id] then
          connected.map[id] = gamepad
          connected[#connected + 1] = gamepad
          initGamepad(gamepad)
        else
          gamepad:close()
        end
      end
    end
  end

  do -- Determine which gamepad was most-recently active
    active = nil
    local minIdle = math.huge
    for i = 1, #connected do
      local idleTime = connected[i]:getIdleTime()
      if idleTime < minIdle then
        minIdle = idleTime
        active = connected[i]
      end
    end
  end
  Profiler.End()
end

return Gamepads
