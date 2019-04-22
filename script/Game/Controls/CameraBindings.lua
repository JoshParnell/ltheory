local Control = WIP.Control

local self = {
  Yaw        = Control.Or(
                 Control.And(
                   Control.MouseButton(Button.Mouse.Right),
                   Control.MouseDX()),
                 Control.GamepadAxis(Button.Gamepad.RStickX)
                   :setMult(3):setExponent(2)),

  Pitch      = Control.Or(
                 Control.And(
                   Control.MouseButton(Button.Mouse.Right),
                   Control.MouseDY()),
                 Control.GamepadAxis(Button.Gamepad.RStickY)
                   :setMult(3):setExponent(2):invert()),
  Zoom       = Control.MouseWheel(),

  TranslateX = Control.Pair(Control.Key(Button.Keyboard.D), Control.Key(Button.Keyboard.A)),
  TranslateZ = Control.Pair(Control.Key(Button.Keyboard.W), Control.Key(Button.Keyboard.S)),
}

return self
