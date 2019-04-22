-- BSPNodeRel ------------------------------------------------------------------
local BSPNodeRel

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    BSPNodeRel BSPNodeRel_Parent;
    BSPNodeRel BSPNodeRel_Back;
    BSPNodeRel BSPNodeRel_Front;
  ]]
end

do -- Global Symbol Table
  BSPNodeRel = {
    Parent = libphx.BSPNodeRel_Parent,
    Back   = libphx.BSPNodeRel_Back,
    Front  = libphx.BSPNodeRel_Front,
  }

  if onDef_BSPNodeRel then onDef_BSPNodeRel(BSPNodeRel, mt) end
  BSPNodeRel = setmetatable(BSPNodeRel, mt)
end

return BSPNodeRel
