local Bindings  = require('UI.Bindings')
local Button    = require('UI.Button')
local DrawEx    = require('UI.DrawEx')
local Panel     = require('UI.Panel')
local Rect      = require('UI.Rect')
local Widget    = require('UI.Widget')

local Window = {}
Window.__index = Window
Window.__call  = function (t, ...) return t.Create(...) end
setmetatable(Window, Panel)

local defaultTitle = 'Window Title'

function Window:setPadY (minY, maxY)
  minY = minY + Math.Round(2.0 * Config.ui.font.titleSize)
  return Widget.setPadY(self, minY, maxY)
end

Window.title       = nil
Window.closeBtn    = nil
Window.closeBtnPad = 2
Window.isWindow    = true

Window.name      = 'Window'
Window.focusable = true
Window.draggable = true

Window:setPadUniform(4)
Window:setStretch(0, 0)

function Window:onFindMouseFocus (mx, my, foci)
  if self.focusable then
    local x, y = self:getPosGlobal()
    if Rect.containsPoint(x, y, self.sx, self.padMinY, mx, my) then
      foci.focus = self
    end
  end
end

function Window:onLayoutSize ()
  local btnSize = self.padMinY - 2*self.closeBtnPad
  if self.closeBtn then
    self.closeBtn:setSize(btnSize, btnSize)
  end

  -- Header and Title
  local font  = Config.ui.font.title
  local bound = font:getSize(self.title)
  self.desiredSX = max(self.desiredSX, self.padSumX + bound.z + 2*btnSize + 4*self.closeBtnPad)
  self.desiredSY = max(self.desiredSY, self.padSumY)
end

function Window:onLayoutPos (px, py, psx, psy)
  Panel.onLayoutPos(self, px, py, psx, psy)

  if self.closeBtn then
    local x = self.x + self.sx - self.closeBtn.fixedSX - self.closeBtnPad
    local y = self.x + self.closeBtnPad
    self.closeBtn:setPos(x, y)
    self.closeBtn.clamp = false
  end
end

function Window:onDraw (focus, active)
   -- Full window background
  local x, y, sx, sy = self:getRectGlobal()
  DrawEx.Panel(x, y, sx, sy, Color(0.2, 0.2, 0.2, 1.0), 1.0)

  -- Client rect background
  local px, py, psx, psy = self:getRectPadGlobal()
  DrawEx.Panel(px, py, psx, psy, Color(0.3, 0.3, 0.3, 1.0), 0.25)

  -- Title
  local font  = Config.ui.font.title
  local color = Config.ui.color.textTitle
  local bound = font:getSize(self.title)

  self:drawTextRectCentered(
    font, self.title, bound, color,
    x, y, sx, self.padMinY + 2)
end

function Window:setCloseButton (enabled)
  if enabled then
    if not self.closeBtn then
      self.closeBtn = Button('x', function (button) self:cancel() end)
      self:add(self.closeBtn)
    end
  else
    if self.closeBtn then
      self:remove(self.closeBtn)
      self.closeBtn = nil
    end
  end
end

function Window.Create (title, modal, showCloseBtn)
  title = title or defaultTitle

  local self = setmetatable({
    title          = title,
    name           = string.format('Window %s', title),
    closeBtn       = nil,

    children       = List(),
  }, Window)

  self:setModal(modal)
  self:setCloseButton(showCloseBtn)
  return self
end

return Window
