local Bindings  = require('UI.Bindings')
local Container = require('UI.Container')

local Panel = {}
Panel.__index = Panel
Panel.__call  = function (t, ...) return t.Create(...) end
setmetatable(Panel, Container)

Panel.isPanel   = true
Panel.isModal   = false
Panel.autoClose = false
Panel.name      = 'Panel'

function Panel:findMouseFocus (mx, my, foci)
  if self.enabledT == 1 and self:containsPoint(mx, my) then
    foci.panelFocus = self
    self:onFindMouseFocusChildren(mx, my, foci)
    if not foci.focus then
      self:onFindMouseFocus(mx, my, foci)
    end
  end
end

function Panel:onInput (state)
  local next = Bindings.NextGroup:get() > 0
  local prev = Bindings.PrevGroup:get() > 0
  if next or prev then

    -- Always jump to the current NavGroup if it isn't focused
    local root = state.navFocus and state.navFocus:getRoot()
    if root and state.focus ~= root then
      state:setFocus(root)
    else
      local navGroups = self:findAllInHierarchy(
        function (w) return w.isNavGroup end
      )
      if #navGroups > 0 then
        local navGroup
        if next then navGroup = navGroups:getNext(state.navFocus) end
        if prev then navGroup = navGroups:getPrev(state.navFocus) end
        state:setNavFocus(navGroup)
        state:setFocus(navGroup:getInitialFocus())
      end
    end
  end
end

function Panel:cancel ()
  if self.onCancel then
    self:onCancel()
  end
end

function Panel:setOnCancel (onCancel)
  self.onCancel = onCancel
  return self
end

function Panel:setModal (modal)
  if modal == nil then modal = false end

  self.isModal = modal
  local state = self:getState()
  if state then
    if modal then
      state:setModalFocus(self)
    elseif state.modalFocus == self then
      state:setModalFocus(nil)
    end
  end
  return self
end

function Panel.Create (name, modal, onCancel)
  local self = setmetatable({
    name     = format('Panel %s', name),
    isModal  = false,
    onCancel = nil,

    children = List(),
  }, Panel)

  self:setModal(modal)
  self:setOnCancel(onCancel)
  return self
end

return Panel

-- TODO : Stop adding NavGroups when a Panel is encountered

--[[ NOTE : Introduce an 'exclusive' flag if we ever end up with a use case for
            modals the don't allow any input behind them. ]]
