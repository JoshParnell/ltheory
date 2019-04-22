local Flow = class(function (self, item, rate, location)
  self.item = item
  self.rate = rate
  self.location = location
end)

function Flow:__tostring ()
  return format('%.2f x %s @ %s',
    self.rate,
    self.item:getName(),
    self.location:getName())
end

return Flow
