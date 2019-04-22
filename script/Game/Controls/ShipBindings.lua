local self = {
  ThrustX = WIP.Control.Or(
    WIP.Control.Pair(
      WIP.Control.Key(Button.Keyboard.D),
      WIP.Control.Key(Button.Keyboard.A)),
    WIP.Control.GamepadAxis(Button.Gamepad.LStickX)),

  ThrustZ = WIP.Control.Or(
    WIP.Control.Pair(
      WIP.Control.Key(Button.Keyboard.W),
      WIP.Control.Key(Button.Keyboard.S)),
    WIP.Control.GamepadAxis(Button.Gamepad.LStickY)),

  Roll = WIP.Control.Or(
    WIP.Control.Pair(
      WIP.Control.Key(Button.Keyboard.E),
      WIP.Control.Key(Button.Keyboard.Q)),
    WIP.Control.Pair(
      WIP.Control.GamepadButton(Button.Gamepad.RBumper),
      WIP.Control.GamepadButton(Button.Gamepad.LBumper))),

  Yaw = WIP.Control.Or(
    WIP.Control.And(
      WIP.Control.MouseX(),
      WIP.Control.Key(Button.Keyboard.Space)),
    WIP.Control.GamepadAxis(Button.Gamepad.RStickX)),

  Pitch = WIP.Control.Or(
    WIP.Control.And(
      WIP.Control.MouseY(),
      WIP.Control.Key(Button.Keyboard.Space)),
    WIP.Control.GamepadAxis(Button.Gamepad.RStickY):invert()),

  Boost = WIP.Control.Or(
    WIP.Control.Key(Button.Keyboard.LShift),
    WIP.Control.GamepadAxis(Button.Gamepad.LTrigger)),

  Fire = WIP.Control.Or(
    WIP.Control.MouseButton(Button.Mouse.Left),
    WIP.Control.GamepadAxis(Button.Gamepad.RTrigger)),

  LockTarget = WIP.Control.Or(
    WIP.Control.Key(Button.Keyboard.T),
    WIP.Control.GamepadButton(Button.Gamepad.X))
    :delta(),

  ClearTarget = WIP.Control.Or(
    WIP.Control.Key(Button.Keyboard.G),
    WIP.Control.GamepadButton(Button.Gamepad.B))
    :delta(),

  Dock = WIP.Control.Or(
    WIP.Control.Key(Button.Keyboard.F),
    WIP.Control.GamepadButton(Button.Gamepad.Y))
    :delta(),

  SquadAttackTarget = WIP.Control.GamepadButton(Button.Gamepad.Up):delta(),
  SquadScramble     = WIP.Control.GamepadButton(Button.Gamepad.Down):delta(),
}

if Config.game.invertPitch then
  self.Pitch = self.Pitch:invert()
end

return self
