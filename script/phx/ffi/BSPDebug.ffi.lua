-- BSPDebug --------------------------------------------------------------------
local BSPDebug

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    BSPNodeRef BSPDebug_GetNode                     (BSP*, BSPNodeRef, BSPNodeRel);
    void       BSPDebug_DrawNode                    (BSP*, BSPNodeRef);
    void       BSPDebug_DrawNodeSplit               (BSP*, BSPNodeRef);
    void       BSPDebug_DrawLineSegment             (BSP*, LineSegment*);
    void       BSPDebug_DrawSphere                  (BSP*, Sphere*);
    void       BSPDebug_PrintRayProfilingData       (BSP*, double totalTime);
    void       BSPDebug_PrintSphereProfilingData    (BSP*, double totalTime);
    bool       BSPDebug_GetIntersectSphereTriangles (BSP*, Sphere*, IntersectSphereProfiling* sphereProf);
    BSPNodeRef BSPDebug_GetLeaf                     (BSP*, int32 leafIndex);
  ]]
end

do -- Global Symbol Table
  BSPDebug = {
    GetNode                     = libphx.BSPDebug_GetNode,
    DrawNode                    = libphx.BSPDebug_DrawNode,
    DrawNodeSplit               = libphx.BSPDebug_DrawNodeSplit,
    DrawLineSegment             = libphx.BSPDebug_DrawLineSegment,
    DrawSphere                  = libphx.BSPDebug_DrawSphere,
    PrintRayProfilingData       = libphx.BSPDebug_PrintRayProfilingData,
    PrintSphereProfilingData    = libphx.BSPDebug_PrintSphereProfilingData,
    GetIntersectSphereTriangles = libphx.BSPDebug_GetIntersectSphereTriangles,
    GetLeaf                     = libphx.BSPDebug_GetLeaf,
  }

  if onDef_BSPDebug then onDef_BSPDebug(BSPDebug, mt) end
  BSPDebug = setmetatable(BSPDebug, mt)
end

return BSPDebug
