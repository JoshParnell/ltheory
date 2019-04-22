local State = {}
State.__index = State

function State:setFocus (focus)
  self.focus = focus

  do -- Filter focus
    -- NOTE : Focus is 'sticky' on draggable widgets
    if self.active and self.active.draggable then
      self.focus = self.active
    end

    -- NOTE : Focus is constrained to the currently active widget
    if self.active and self.focus ~= self.active then
      self.focus = nil
    end

    -- NOTE : Focus is 'sticky' on active widgets when not using the mouse
    if Input.GetActiveDeviceType() ~= DeviceType.Mouse then
      if self.active then self.focus = self.active end
    end
  end

  if self.focus then
    if Input.GetActiveDeviceType() ~= DeviceType.Mouse then
      if self.scrollFocus then self.scrollFocus:keepFocusVisible(self) end
    end
  end
end

function State:setScrollFocus (scrollFocus)
  self.scrollFocus = scrollFocus

  if self.scrollActive ~= self.scrollFocus then
    self.scrollActive = nil
  end
end

function State:setNavFocus (navFocus)
  self.navFocus = navFocus
end

function State:setPanelFocus (panelFocus)
  self.panelFocus = panelFocus

  local w = self.panelFocus
  if w and w.isWindow and w.parent then w.parent.children:moveToBack(w) end
end

function State:setModalFocus (modalFocus)
  if modalFocus then
    self:clearFocus()
    self.modalFocus = modalFocus
    self:refreshFocus()
  else
    self.modalFocus = modalFocus
  end
end

function State:onWidgetEnabled (widget)
  if widget.isModal then
    self:setModalFocus(widget)
  else
    self:refreshFocus()
  end
end

function State:onWidgetDisabled (widget)
  local function isDisabled (w)
    return w and w:hasParentOrSelfWhere(function (p)
      return p.removed or (p.isContainer and not p:isEnabled())
    end)
  end

  if isDisabled(self.active)       then self.active =       nil  end
  if isDisabled(self.focus)        then self:setFocus      (nil) end
  if isDisabled(self.scrollActive) then self.scrollActive = nil  end
  if isDisabled(self.scrollFocus)  then self:setScrollFocus(nil) end
  if isDisabled(self.navFocus)     then self:setNavFocus   (nil) end
  if isDisabled(self.panelFocus)   then self:setPanelFocus (nil) end
  if isDisabled(self.modalFocus)   then self.modalFocus =   nil  end

  self:refreshFocus()
end

function State:clearFocus ()
  self.active =       nil
  self:setFocus      (nil)
  self.scrollActive = nil
  self:setScrollFocus(nil)
  self:setNavFocus   (nil)
  self:setPanelFocus (nil)
  self.modalFocus =   nil
end

function State:refreshFocus ()
  if Input.GetActiveDeviceType() == DeviceType.Mouse then
    self.canvas:findMouseFocus()
  else
    --[[ NOTE : There is a 'hierarchy' to focus. panelFocus, navFocus, and
                scrollFocus, if they exist, must be parents of focus. Further,
                the focus must be a child of a valid panelFocus. We assume that
                it's not possible to reach a state of invalid/mixed focus. With
                this in mind, if there is no panelFocus we can assume all the
                other focii are empty as well and we don't have to worry about
                situations such as there being a focus but no panelFocus and
                ensuring we pick the Panel that is the parent of the focus.
                We're simply going to start at the first empty focus and end up
                setting focus for every lower focus. ]]

    --[[ TODO : It would be better to track previously focused panels and walk
                back to the last one. ]]
    if not self.panelFocus then
      local panel
      if self.modalFocus then
        panel = self.modalFocus
      else
        panel = self.canvas:findAllInHierarchy(
          function (w) return w.isPanel end
        )[1]
      end
      self:setPanelFocus(panel)
    end

    if self.panelFocus and not self.navFocus then
      local navGroup = self.panelFocus:findInHierarchy(
        function (w) return w.isNavGroup end,
        function (w) return not w.isPanel or w == self.panelFocus end
      )
      self:setNavFocus(navGroup)
    end

    if self.navFocus and not self.focus then
      local focus = self.navFocus:getInitialFocus()
      self:setFocus(focus)
    end

    if self.panelFocus and not self.focus then
      if self.panelFocus.focusable then
        self:setFocus(self.panelFocus)
      end
    end

    local focus = self.focus or self.navFocus
    if focus and not self.scrollFocus then
      local scrollView = focus:getFirstParentWhere(function(p)
        return p.isScrollView
      end)
      self:setScrollFocus(scrollView)
    end
  end
end

function State:getDeepestFocus ()
  return self.focus
      or self.scrollFocus
      or self.navFocus
      or self.panelFocus
      or self.modalFocus
end

function State.Create (canvas)
  return setmetatable({
    -- Input
    dt            = 0,
    mousePosX     = 0,
    mousePosY     = 0,

    -- Drag
    dragBeginX    = 0,
    dragBeginY    = 0,
    dragOffsetX   = 0,
    dragOffsetY   = 0,
    dragDeltaX    = 0,
    dragDeltaY    = 0,
    dragBeginTime = 0,
    dragEndTime   = 0,
    dragDuration  = 0,

    -- Focus
    focus        = nil,
    active       = nil,
    scrollFocus  = nil,
    scrollActive = nil,
    navFocus     = nil,
    panelFocus   = nil,
    modalFocus   = nil,

    -- Internal
    canvas       = canvas,
  }, State)
end

return State

--[[ TODO : If a container is enabled or disabled we don't process child widgets
            at all. e.g. children will not get onEnable and enabled child panels
            will not take focus. ]]

-- TODO : If an active widget is disabled we don't seed onDragEnd or other events
