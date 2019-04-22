local Control = require('WIP.Control')

return {
  Select    = Control.Or(
    Control.MouseButton(Button.Mouse.Left),
    Control.Key(Button.Keyboard.Space)
  ):delta(),
  Cancel    = Control.Or(
    Control.MouseButton(Button.Mouse.Right),
    Control.Key(Button.Keyboard.Escape),
    Control.Key(Button.Keyboard.LShift)
  ):delta(),
  Up        = Control.Key(Button.Keyboard.W):delta(),
  Down      = Control.Key(Button.Keyboard.S):delta(),
  Left      = Control.Key(Button.Keyboard.A):delta(),
  Right     = Control.Key(Button.Keyboard.D):delta(),
  PrevGroup = Control.Key(Button.Keyboard.Q):delta(),
  NextGroup = Control.Key(Button.Keyboard.E):delta(),
  ScrollH   = Control.MouseButton(Button.Mouse.ScrollX),
  ScrollV   = Control.MouseButton(Button.Mouse.ScrollY),
}
