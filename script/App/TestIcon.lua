local Test = Application()
local rng = RNG.FromTime()
local icon

function Test:onInit ()
  icon = Icon.Create()
  icon:addPoint(0.5, 0.5)
  icon:addPoint(0.2, 0.2)
end

function Test:onInput () end
function Test:onUpdate (dt) end

function Test:onDraw ()
  Draw.Clear(0.1, 0.1, 0.1, 1.0)
  BlendMode.PushAdditive()
  local y = 16
  local size = 16
  for i = 1, 6 do
    icon:draw(16, y, size, 0.1, 0.5, 1.0, 1.0)
    y = y + size + 4
    size = size * 2
  end
  BlendMode.Pop()
end

return Test
