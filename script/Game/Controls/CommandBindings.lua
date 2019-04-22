local Control = WIP.Control

local self = {
  Select          = Control.MouseButton(Button.Mouse.Left),
  ToggleSelection = Control.Ctrl(),
  AppendSelection = Control.Shift(),

  Context         = Control.MouseButton(Button.Mouse.Right):delta(),
  SetFocus        = Control.Key(Button.Keyboard.F):delta(),
  LockFocus       = Control.Key(Button.Keyboard.G):delta(),

  ToggleDetails   = Control.Key(Button.Keyboard.R):delta(),

  SetGroup        = Control.Key(Button.Keyboard.E):delta(),
  GetGroup        = Control.Key(Button.Keyboard.Q):delta(),
  GroupNumber = {
                    Control.Key(Button.Keyboard.N1):delta(),
                    Control.Key(Button.Keyboard.N2):delta(),
                    Control.Key(Button.Keyboard.N3):delta(),
                    Control.Key(Button.Keyboard.N4):delta(),
  },
}

return self
