-- BSPNodeRef ------------------------------------------------------------------
local BSPNodeRef

local ffi = require('ffi')

do -- Global Symbol Table
  BSPNodeRef = {
  }

  local mt = {
    __call  = function (t, ...) return BSPNodeRef_t(...) end,
  }

  if onDef_BSPNodeRef then onDef_BSPNodeRef(BSPNodeRef, mt) end
  BSPNodeRef = setmetatable(BSPNodeRef, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('BSPNodeRef')
  local mt = {
    __index = {
      clone = function (x) return BSPNodeRef_t(x) end,
    },
  }

  if onDef_BSPNodeRef_t then onDef_BSPNodeRef_t(t, mt) end
  BSPNodeRef_t = ffi.metatype(t, mt)
end

return BSPNodeRef
