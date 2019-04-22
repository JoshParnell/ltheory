local Control = {}

local ControlT = class(function (self)
  self.mult = 1.0
  self.expn = 1.0
  self.bias = 0.0
end)

local gamepadAxisIcon = {
  [Button.Gamepad.LStickX]  = 'icon/lstick',
  [Button.Gamepad.LStickY]  = 'icon/lstick',
  [Button.Gamepad.RStickX]  = 'icon/rstick',
  [Button.Gamepad.RStickY]  = 'icon/rstick',
  [Button.Gamepad.LTrigger] = 'icon/ltrigger',
  [Button.Gamepad.RTrigger] = 'icon/rtrigger',
}

local gamepadButtonIcon = {
  [Button.Gamepad.A]       = 'icon/a',
  [Button.Gamepad.B]       = 'icon/b',
  [Button.Gamepad.X]       = 'icon/x',
  [Button.Gamepad.Y]       = 'icon/y',
  [Button.Gamepad.Back]    = 'icon/snap',
  [Button.Gamepad.Start]   = 'icon/menu',
  [Button.Gamepad.LStick]  = 'icon/lstick',
  [Button.Gamepad.RStick]  = 'icon/rstick',
  [Button.Gamepad.LBumper] = 'icon/lbumper',
  [Button.Gamepad.RBumper] = 'icon/rbumper',
  [Button.Gamepad.Up]      = 'icon/dpad_up',
  [Button.Gamepad.Down]    = 'icon/dpad_down',
  [Button.Gamepad.Left]    = 'icon/dpad_left',
  [Button.Gamepad.Right]   = 'icon/dpad_right',
}

function ControlT:delta ()
  return Control.Delta(self)
end

function ControlT:get ()
  local v = self:getRaw()
  return self.mult * Math.Sign(v) * pow(
    max(0.0, (abs(v) - self.bias) / (1.0 - self.bias)),
    self.expn)
end

function ControlT:getIcon ()
  local path = self:getIconPath()
  return path and Cache.Texture(path, true)
end

function ControlT:invert ()
  self.mult = -self.mult
  return self
end

function ControlT:setDeadzone (deadzone)
  self.bias = deadzone
  return self
end

function ControlT:setMult (mult)
  self.mult = mult
  return self
end

function ControlT:setExponent (expn)
  self.expn = expn
  return self
end

-- TODO : Integrate disabled devices by implementing :isActive and dropping
--        inactive devices from consideration in And/Or.

Control.And = subclass(ControlT, function (self, ...)
  self.controls = { ... }
end)

function Control.And:getRaw ()
  local value = 1.0
  for i = 1, #self.controls do value = value * self.controls[i]:get() end
  return value
end

Control.Delta = subclass(ControlT, function (self, control)
  self.control = control
  self.last = control:get()
end)

function Control.Delta:getIconPath ()
  return self.control:getIconPath()
end

-- TODO : This must be split into an update & cached value, such that the
--        control can be retrieved multiple times in one frame without affecting
--        the delta value. In general, deltas require extra handling. This is
--        also where flattening bindings will come into play and potentially
--        get tricky. After PAX, having used this control system a bit, we'll
--        need to come back and assess what we've learned (and, in particular,
--        if deltas are the natural splitting point where we move to events
--        rather than 'continuous' controls, which deltas are not.)
function Control.Delta:getRaw ()
  local curr = self.control:get()
  local last = self.last
  self.last = curr
  return curr - last
end

Control.GamepadAxis = subclass(ControlT, function (self, axis)
  self.axis = axis
end)

function Control.GamepadAxis:getIconPath ()
  return gamepadAxisIcon[self.axis]
end

function Control.GamepadAxis:getRaw ()
  return Input.GetValue(self.axis)
end

Control.GamepadButton = subclass(ControlT, function (self, button)
  self.button = button
end)

function Control.GamepadButton:getIconPath ()
  return gamepadButtonIcon[self.button]
end

function Control.GamepadButton:getRaw ()
  return Input.GetValue(self.button)
end

Control.GamepadButtonPressed = subclass(ControlT, function (self, button)
  self.button = button
end)

function Control.GamepadButtonPressed:getIconPath ()
  return gamepadButtonIcon[self.button]
end

function Control.GamepadButtonPressed:getRaw ()
  return Input.GetPressed(self.button) and 1.0 or 0.0
end

Control.GamepadButtonReleased = subclass(ControlT, function (self, button)
  self.button = button
end)

function Control.GamepadButtonReleased:getIconPath ()
  return gamepadButtonIcon[self.button]
end

function Control.GamepadButtonReleased:getRaw ()
  return Input.GetReleased(self.button) and 1.0 or 0.0
end

Control.Key = subclass(ControlT, function (self, key)
  self.key = key
end)

function Control.Key:getRaw ()
  return Input.GetValue(self.key)
end

Control.Alt   = function () return Control.Or(Control.Key(Button.Keyboard.LAlt),   Control.Key(Button.Keyboard.RAlt))   end
Control.Ctrl  = function () return Control.Or(Control.Key(Button.Keyboard.LCtrl),  Control.Key(Button.Keyboard.RCtrl))  end
Control.Shift = function () return Control.Or(Control.Key(Button.Keyboard.LShift), Control.Key(Button.Keyboard.RShift)) end

Control.MouseX = subclass(ControlT, function (self) end)
Control.MouseY = subclass(ControlT, function (self) end)

function Control.MouseX:getRaw ()
  local c = Camera.get()
  local m = Input.GetValue(Button.Mouse.X)
  return Math.Clamp(2.0 * (m - c.x) / c.sx - 1.0, -1.0, 1.0)
end

function Control.MouseY:getRaw ()
  local c = Camera.get()
  local m = Input.GetValue(Button.Mouse.Y)
  return Math.Clamp(2.0 * (m - c.y) / c.sy - 1.0, -1.0, 1.0)
end

-- TODO : Really a delta. Unify with MouseX/Y + think about out how 'mouse
--        relative to center' best fits into this architecture.
Control.MouseDX = subclass(ControlT, function (self) end)
Control.MouseDY = subclass(ControlT, function (self) end)

function Control.MouseDX:getRaw () local md = Input.GetMouseDelta() return md.x end
function Control.MouseDY:getRaw () local md = Input.GetMouseDelta() return md.y end

Control.MouseButton = subclass(ControlT, function (self, button)
  self.button = button
end)

function Control.MouseButton:getRaw ()
  return Input.GetValue(self.button)
end

Control.MouseWheel = subclass(ControlT, function (self) end)

-- TODO : Unlike other signals, this won't be clamped to [-1, 1]. Problem?
-- NOTE : In reality, this is a delta.
-- NOTE : Yes, this has already caused problems in the form of dt-dependence
function Control.MouseWheel:getRaw ()
  return Input.GetValue(Button.Mouse.ScrollY)
end

Control.Null = subclass(ControlT, function (self) end)

function Control.Null:getRaw ()
  return 0
end

Control.Pair = subclass(ControlT, function (self, pos, neg)
  self.pos = pos
  self.neg = neg
end)

function Control.Pair:getRaw ()
  return self.pos:get() - self.neg:get()
end

Control.Or = subclass(ControlT, function (self, ...)
  self.controls = { ... }
end)

function Control.Or:getRaw ()
  local value = 0.0
  for i = 1, #self.controls do
    local v = self.controls[i]:get()
    if abs(v) > abs(value) then value = v end
  end
  return value
end

return Control

-- TODO : Don't trigger bindings without modifiers when a modifier is pressed.
-- TODO : It should be possible to get the delta from a non-delta control.
