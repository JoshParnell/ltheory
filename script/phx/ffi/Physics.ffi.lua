-- Physics ---------------------------------------------------------------------
local Physics

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Physics* Physics_Create                 ();
    void     Physics_Free                   (Physics*);
    void     Physics_AddRigidBody           (Physics*, RigidBody*);
    void     Physics_RemoveRigidBody        (Physics*, RigidBody*);
    void     Physics_AddTrigger             (Physics*, Trigger*);
    void     Physics_RemoveTrigger          (Physics*, Trigger*);
    bool     Physics_GetNextCollision       (Physics*, Collision*);
    void     Physics_Update                 (Physics*, float dt);
    void     Physics_RayCast                (Physics*, Ray*, RayCastResult*);
    void     Physics_SphereCast             (Physics*, Sphere*, ShapeCastResult*);
    void     Physics_BoxCast                (Physics*, Vec3f* pos, Quat* rot, Vec3f* halfExtents, ShapeCastResult*);
    bool     Physics_SphereOverlap          (Physics*, Sphere*);
    bool     Physics_BoxOverlap             (Physics*, Vec3f* pos, Quat* rot, Vec3f* halfExtents);
    void     Physics_PrintProfiling         (Physics*);
    void     Physics_DrawBoundingBoxesLocal (Physics*);
    void     Physics_DrawBoundingBoxesWorld (Physics*);
    void     Physics_DrawTriggers           (Physics*);
    void     Physics_DrawWireframes         (Physics*);
  ]]
end

do -- Global Symbol Table
  Physics = {
    Create                 = libphx.Physics_Create,
    Free                   = libphx.Physics_Free,
    AddRigidBody           = libphx.Physics_AddRigidBody,
    RemoveRigidBody        = libphx.Physics_RemoveRigidBody,
    AddTrigger             = libphx.Physics_AddTrigger,
    RemoveTrigger          = libphx.Physics_RemoveTrigger,
    GetNextCollision       = libphx.Physics_GetNextCollision,
    Update                 = libphx.Physics_Update,
    RayCast                = libphx.Physics_RayCast,
    SphereCast             = libphx.Physics_SphereCast,
    BoxCast                = libphx.Physics_BoxCast,
    SphereOverlap          = libphx.Physics_SphereOverlap,
    BoxOverlap             = libphx.Physics_BoxOverlap,
    PrintProfiling         = libphx.Physics_PrintProfiling,
    DrawBoundingBoxesLocal = libphx.Physics_DrawBoundingBoxesLocal,
    DrawBoundingBoxesWorld = libphx.Physics_DrawBoundingBoxesWorld,
    DrawTriggers           = libphx.Physics_DrawTriggers,
    DrawWireframes         = libphx.Physics_DrawWireframes,
  }

  if onDef_Physics then onDef_Physics(Physics, mt) end
  Physics = setmetatable(Physics, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Physics')
  local mt = {
    __index = {
      managed                = function (self) return ffi.gc(self, libphx.Physics_Free) end,
      free                   = libphx.Physics_Free,
      addRigidBody           = libphx.Physics_AddRigidBody,
      removeRigidBody        = libphx.Physics_RemoveRigidBody,
      addTrigger             = libphx.Physics_AddTrigger,
      removeTrigger          = libphx.Physics_RemoveTrigger,
      getNextCollision       = libphx.Physics_GetNextCollision,
      update                 = libphx.Physics_Update,
      rayCast                = libphx.Physics_RayCast,
      sphereCast             = libphx.Physics_SphereCast,
      boxCast                = libphx.Physics_BoxCast,
      sphereOverlap          = libphx.Physics_SphereOverlap,
      boxOverlap             = libphx.Physics_BoxOverlap,
      printProfiling         = libphx.Physics_PrintProfiling,
      drawBoundingBoxesLocal = libphx.Physics_DrawBoundingBoxesLocal,
      drawBoundingBoxesWorld = libphx.Physics_DrawBoundingBoxesWorld,
      drawTriggers           = libphx.Physics_DrawTriggers,
      drawWireframes         = libphx.Physics_DrawWireframes,
    },
  }

  if onDef_Physics_t then onDef_Physics_t(t, mt) end
  Physics_t = ffi.metatype(t, mt)
end

return Physics
