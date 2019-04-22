local Bindings  = require('UI.Bindings')
local Container = require('UI.Container')

local NavGroup = {}
NavGroup.__index = NavGroup
setmetatable(NavGroup, Container)

NavGroup.isNavGroup = true
NavGroup.name       = 'NavGroup'

function NavGroup:getInitialFocus ()
  return self:getRoot() or self:moveFocus(nil, Vec2f(0, 1))
end

function NavGroup:getRoot ()
  local firstFocusable = self:findInHierarchy(
    function (w) return w.focusable end
  )
  if firstFocusable then
    local focusableCount = firstFocusable.parent.children:count(
      function (w) return w.focusable end
    )
    if focusableCount == 1 then return firstFocusable end
  end
  return nil
end

function NavGroup:moveFocus (currFocus, moveDir)
  local bestScore,  bestFocus  = 1e6, nil
  local worstScore, worstFocus = 0,   nil

  currFocus = currFocus or self
  if currFocus.x == nil then error() end

  local root       = self:getRoot()
  local focusables = self:findAllInHierarchy(
    function (w) return w.focusable end
  )

  for i = 1, #focusables do
    local focus = focusables[i]

    if focus ~= root then
      local delta = Vec2f(focus.x - currFocus.x, focus.y - currFocus.y)
      local score = delta:dot(moveDir) * delta:length()

      if score >= 0 and score < bestScore and focus ~= currFocus then
        bestScore, bestFocus = score, focus
      end
      --[[ TODO : The flat out worst score is not really the intuitive wrap
                  point. What we really want is worst score long the movement
                  direction, negatively weighted by absolute score along the
                  perpendicular direction. i.e. We want to prefer things that
                  are closer to directly behind, not behind and to the sides. ]]
      if score < 0 and score < worstScore then
        worstScore, worstFocus = score, focus
      end
    end
  end

  return bestFocus or worstFocus
end

function NavGroup:findMouseFocus (mx, my, foci)
  if self.enabledT == 1 and self:containsPoint(mx, my) then
    foci.navFocus = self
    self:onFindMouseFocusChildren(mx, my, foci)
    if not foci.focus then
      self:onFindMouseFocus(mx, my, foci)
    end
  end
end

function NavGroup:onInput (state)
  if Bindings.Right:get() > 0 or
     Bindings.Left :get() > 0 or
     Bindings.Up   :get() > 0 or
     Bindings.Down :get() > 0
  then
    local dir = Vec2f(
      Bindings.Right.last - Bindings.Left.last,
      Bindings.Down.last  - Bindings.Up.last
    )

    if not dir:isZero() then
      local focus = self:moveFocus(state.focus, dir)
      if focus then state:setFocus(focus) end
    end
  end
end

function NavGroup.Create ()
  local self = setmetatable({
    children = List(),
  }, NavGroup)
  return self
end

return NavGroup
