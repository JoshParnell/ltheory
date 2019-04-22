-- TODO : ScrollViews
-- TODO : Visited for cdata

local function isFlat (value)
  if type(value) == 'table' then
    return false
  elseif type(value) == 'cdata' then
    -- TODO : HAAAAAATE.
    return string.sub(tostring(value), 1, 1) ~= '['
  end

  return true
end

local function addStruct (parent, data, visited)
  local rootGrid = UI.Grid():setCols(1):setPad(2, 0, 2, 2)


  -- Fields
  local fieldGrid = UI.Grid()
  for k, v in pairs(data) do
    if isFlat(v) then
      if type(v) == 'function' then
        fieldGrid:add(UI.Label(k))
        fieldGrid:add(UI.Label(string.format('< fn @ %p >', v)))

      else
        fieldGrid:add(UI.Label(k))
        fieldGrid:add(UI.Label(v))
      end
    end
  end
  rootGrid:add(fieldGrid)



  -- Structs
  local structGrid = UI.Grid():setCols(1)
  for k, v in pairs(data) do
    if not isFlat(v) then
      if type(v) == 'table' then
        if not visited[v] then
          visited[v] = true

          local collapsible = UI.Collapsible(k, false)
          addStruct(collapsible, v, visited)
          structGrid:add(
            UI.NavGroup():add(collapsible)
          )
        end

      elseif type(v) == 'cdata' and string.sub(tostring(v), 1, 1) == '[' then
        local collapsible = UI.Collapsible(k, false)
        addStruct(collapsible, v, visited)
        structGrid:add(
          UI.NavGroup():add(collapsible)
        )
      end
    end
  end
  rootGrid:add(structGrid)

  parent:add(rootGrid)
end

local function DebugInspector (data, name)
  name = name or 'root'

  local self = UI.Window('Inspector - ' .. name, false, true)
  self.align = false
  addStruct(self, data, {})
  self.children[1]:setPadUniform(2)
  return self
end

return DebugInspector
