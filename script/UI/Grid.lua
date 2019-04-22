--[[----------------------------------------------------------------------------
  Lays out children in both X and Y directions. Defaults to a 2 column layout.
  A Grid must have either a fixed number of rows or a fixed number of columns
  (and not both). These are set with setRows() and setCols(). Note that later
  calls will replace previous calls (and it's safe to change the layout
  on-the-fly). A Grid with a fixed number of columns will layout children
  horizontally, filling the row until the specified number of columns has been
  reached then automatically advancing to the next row. Setting a fixed number
  of rows causes the Grid to position children vertically until the desired
  number of rows have been reached before automatically advancing.
----------------------------------------------------------------------------]]--
local Container = require('UI.Container')

local Grid = {}
Grid.__index = Grid
setmetatable(Grid, Container)

Grid.fixedRows      = nil
Grid.fixedCols      = nil
Grid.indexToRow     = nil
Grid.indexToCol     = nil
Grid.rows           = nil
Grid.cols           = nil
Grid.rowInfo        = nil
Grid.colInfo        = nil
Grid.stretchXTotal  = nil
Grid.stretchYTotal  = nil
Grid.padCellX       = 2
Grid.padCellY       = 2

Grid.name = 'Grid'

ffi.cdef [[
  typedef struct _Grid_Row {
    float height;
    float stretchYMax;
  } _Grid_Row;

  typedef struct _Grid_Col {
    float width;
    float stretchXMax;
  } _Grid_Col;
]]

local RowInfo = ffi.typeof('_Grid_Row')
local ColInfo = ffi.typeof('_Grid_Col')

function Grid:onLayoutSizeChildren ()
  local indexToRow, indexToCol
  if self.fixedRows then
    self.rows = self.fixedRows
    self.cols = ceil(#self.children / self.fixedRows)
  elseif self.fixedCols then
    self.rows = ceil(#self.children / self.fixedCols)
    self.cols = self.fixedCols
  else
    if not self.didLayoutWarning then
      self.didLayoutWarning = true
      Log.Warning('Grid has neither rows nor columns set. Ya broke it.')
    end
    return
  end

  -- Initialize Cell Sizes
  self.stretchXTotal = 0
  self.stretchYTotal = 0
  for row = 1, self.rows do self.rowInfo[row] = RowInfo() end
  for col = 1, self.cols do self.colInfo[col] = ColInfo() end

  for i = 1, #self.children do
    -- Layout Children
    local child = self.children[i]
    child:layoutSize()

    -- Calculate Row and Columns Sizes
    local rowInfo       = self.rowInfo[self.indexToRow(i)]
    rowInfo.height      = max(rowInfo.height, child.sy)
    rowInfo.stretchYMax = max(rowInfo.stretchYMax, child.stretchY)

    local colInfo       = self.colInfo[self.indexToCol(i)]
    colInfo.width       = max(colInfo.width, child.sx)
    colInfo.stretchXMax = max(colInfo.stretchXMax, child.stretchX)
  end
end

function Grid:onLayoutSize ()
  -- Set Total Grid Size (and Pad Non-Empty Rows+Cols)
  self.desiredSX = self.padSumX
  self.desiredSY = self.padSumY

  for col = 1, self.cols do
    local colInfo      = self.colInfo[col]
    self.desiredSX     = self.desiredSX     + colInfo.width + 2*self.padCellX
    self.stretchXTotal = self.stretchXTotal + colInfo.stretchXMax
  end
  for row = 1, self.rows do
    local rowInfo      = self.rowInfo[row]
    self.desiredSY     = self.desiredSY     + rowInfo.height + 2*self.padCellY
    self.stretchYTotal = self.stretchYTotal + rowInfo.stretchYMax
  end
  if self.cols > 0 then self.desiredSX = self.desiredSX - 2*self.padCellX end
  if self.rows > 0 then self.desiredSY = self.desiredSY - 2*self.padCellY end
end

function Grid:onLayoutPosChildren ()
  -- Stretch Cols+Rows
  if self.stretchXTotal ~= 0 then
    local extraX = self.sx - self.desiredSX
    local usedX = 0
    for col = 1, self.cols do
      local colInfo = self.colInfo[col]
      local stretchAmount = floor(extraX * (colInfo.stretchXMax / self.stretchXTotal))
      colInfo.width = colInfo.width + stretchAmount
      usedX = usedX + stretchAmount
    end

    --[[ OPTIMIZE : This doesn't respect stretch weights when distributing
                    leftover pixels and it's an extra iteration. Yuck. ]]
    for col = 1, (extraX - usedX) do self.colInfo[col].width = self.colInfo[col].width + 1 end
  end

  if self.stretchYTotal ~= 0 then
    local extraY = self.sy - self.desiredSY
    local usedY = 0
    for row = 1, self.rows do
      local rowInfo = self.rowInfo[row]
      local stretchAmount = floor(extraY * (rowInfo.stretchYMax / self.stretchYTotal))
      rowInfo.height = rowInfo.height + stretchAmount
      usedY = usedY + stretchAmount
    end

    for row = 1, (extraY - usedY) do self.rowInfo[row].height = self.rowInfo[row].height + 1 end
  end

  local ox, oy = self:getPosGlobal()
  for i = 1, #self.children do
    local row = self.indexToRow(i)
    local col = self.indexToCol(i)
    local cellSX = self.colInfo[col].width
    local cellSY = self.rowInfo[row].height

    local cellX = self.padMinX
    local cellY = self.padMinY
    for j = 1, col-1 do cellX = cellX + self.colInfo[j].width  + 2*self.padCellX end
    for j = 1, row-1 do cellY = cellY + self.rowInfo[j].height + 2*self.padCellY end

    self.children[i]:layoutPos(ox, oy, cellX, cellY, cellSX, cellSY)
  end
end

function Grid:onDrawDebug (focus, active)
  local x, y = self:getPosGlobal()

  local rng = RNG.Create(1234)
  for i = 1, self.rows*self.cols do
    local row = self.indexToRow(i)
    local col = self.indexToCol(i)
    local cellSX = self.colInfo[col].width
    local cellSY = self.rowInfo[row].height

    local cellX = self.padMinX
    local cellY = self.padMinY
    for j = 1, col-1 do cellX = cellX + self.colInfo[j].width  + 2*self.padCellX end
    for j = 1, row-1 do cellY = cellY + self.rowInfo[j].height + 2*self.padCellY end

    Draw.Color(rng:getUniform(), rng:getUniform(), rng:getUniform(), 0.1)
    Draw.Rect(x + cellX, y + cellY, cellSX, cellSY)
  end
  rng:free()
  Config.ui.color.debugRect:set()

  Container.onDrawDebugChildren(self, focus, active)
end

function Grid:setRows (rows)
  self.fixedRows  = rows
  self.fixedCols  = nil
  self.indexToRow = function (i) return      ((i - 1) % self.rows) + 1 end
  self.indexToCol = function (i) return floor((i - 1) / self.rows) + 1 end
  return self
end

function Grid:setCols (cols)
  self.fixedRows  = nil
  self.fixedCols  = cols
  self.indexToRow = function (i) return floor((i - 1) / self.cols) + 1 end
  self.indexToCol = function (i) return      ((i - 1) % self.cols) + 1 end
  return self
end

function Grid:setPadCellX (pad)
  self.padCellX = pad
  return self
end

function Grid:setPadCellY (pad)
  self.padCellY = pad
  return self
end

function Grid:setPadCell (padX, padY)
  self.padCellX = padX
  self.padCellY = padY
  return self
end

function Grid.Create ()
  local self = setmetatable({
    rowInfo  = {},
    colInfo  = {},

    children = List(),
  }, Grid)
  self:setCols(2)
  return self
end

return Grid
