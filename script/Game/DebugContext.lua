local DebugContext = class(function (self, x, y)
  self.x = x
  self.y = y
end)

function DebugContext:indent ()
  self.x = self.x + 16
end

function DebugContext:text (fmt, ...)
  UI.DrawEx.TextAlpha('UbuntuMono', format(fmt, ...), 14,
    self.x, self.y, 0, 14, 1, 1, 1, 1)
  self.y = self.y + 16
end

function DebugContext:undent ()
  self.x = self.x - 16
end

return DebugContext
