local InputTest = Application()

function InputTest:onInit ()
  --InputBindings.Register(UI.Bindings.Keyboard)
  --InputBindings.Init();
end

function InputTest:onUpdate (dt)
  --[[ NOTE : Low Level API Usage Style 1 - Direct State Queries
  for i = 1, 512 do
    if Input.GetPressed(i)  then printf('Pressed  - %s', ffi.string(libphx.Button_ToString(i))) end
    if Input.GetReleased(i) then printf('Released - %s', ffi.string(libphx.Button_ToString(i))) end
  end
  --]]

  ---[[ NOTE : Low Level API Usage Style 2 - Event Queue
  local self = InputTest
  self.eventCount = Input.GetEventCount()
  for i = 1, Input.GetEventCount() do
    local event = InputEvent()
    Input.GetNextEvent(event)
    if event.deviceType == DeviceType.Gamepad and
       (Bit.Has32(event.state, State.Pressed) or
        Bit.Has32(event.state, State.Released))
    then
      print(event)
    end
  end
  --]]

  --[[ NOTE : High Level API Usage Style 1 - Direct State Queries
  InputBindings.Update();
  --]]


  --[[ NOTE : High Level API Usage Style 2 - Event Stream --]]
  --[[ NOTE : High Level API Usage Style 3 - Callbacks --]]
end

function InputTest:onDraw ()
end

function InputTest:onExit ()
  --InputBindings.Unregister(UI.Bindings.Keyboard)
  --InputBindings.Free();
end

return InputTest
