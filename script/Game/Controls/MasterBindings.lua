local Control = WIP.Control

local self = {
  TogglePanel     = Control.Key(Button.Keyboard.Backtick):delta(),
  Controls = {
                    Control.Key(Button.Keyboard.N1):delta(),
                    Control.Key(Button.Keyboard.N2):delta(),
                    Control.Key(Button.Keyboard.N3):delta(),
  },
}

return self
