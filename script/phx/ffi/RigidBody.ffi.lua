-- RigidBody -------------------------------------------------------------------
local RigidBody

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    RigidBody* RigidBody_CreateBox                   ();
    RigidBody* RigidBody_CreateBoxFromMesh           (Mesh*);
    RigidBody* RigidBody_CreateSphere                ();
    RigidBody* RigidBody_CreateSphereFromMesh        (Mesh*);
    RigidBody* RigidBody_CreateHullFromMesh          (Mesh*);
    void       RigidBody_Free                        (RigidBody*);
    void       RigidBody_ApplyForce                  (RigidBody*, Vec3f*);
    void       RigidBody_ApplyTorque                 (RigidBody*, Vec3f*);
    void       RigidBody_Attach                      (RigidBody*, RigidBody* other, Vec3f*, Quat*);
    void       RigidBody_Detach                      (RigidBody*, RigidBody* other);
    void       RigidBody_GetBoundingBox              (RigidBody*, Box3f*);
    void       RigidBody_GetBoundingBoxCompound      (RigidBody*, Box3f*);
    void       RigidBody_GetBoundingBoxLocal         (RigidBody*, Box3f*);
    void       RigidBody_GetBoundingBoxLocalCompound (RigidBody*, Box3f*);
    float      RigidBody_GetBoundingRadius           (RigidBody*);
    float      RigidBody_GetBoundingRadiusCompound   (RigidBody*);
    RigidBody* RigidBody_GetParentBody               (RigidBody*);
    float      RigidBody_GetSpeed                    (RigidBody*);
    Matrix*    RigidBody_GetToLocalMatrix            (RigidBody*);
    Matrix*    RigidBody_GetToWorldMatrix            (RigidBody*);
    void       RigidBody_GetVelocity                 (RigidBody*, Vec3f*);
    void       RigidBody_GetVelocityA                (RigidBody*, Vec3f*);
    void       RigidBody_SetCollidable               (RigidBody*, bool);
    void       RigidBody_SetCollisionGroup           (RigidBody*, int);
    void       RigidBody_SetCollisionMask            (RigidBody*, int);
    void       RigidBody_SetDrag                     (RigidBody*, float linear, float angular);
    void       RigidBody_SetFriction                 (RigidBody*, float);
    void       RigidBody_SetKinematic                (RigidBody*, bool);
    void       RigidBody_SetRestitution              (RigidBody*, float);
    void       RigidBody_SetSleepThreshold           (RigidBody*, float linear, float angular);
    float      RigidBody_GetMass                     (RigidBody*);
    void       RigidBody_SetMass                     (RigidBody*, float);
    void       RigidBody_GetPos                      (RigidBody*, Vec3f*);
    void       RigidBody_GetPosLocal                 (RigidBody*, Vec3f*);
    void       RigidBody_SetPos                      (RigidBody*, Vec3f*);
    void       RigidBody_SetPosLocal                 (RigidBody*, Vec3f*);
    void       RigidBody_GetRot                      (RigidBody*, Quat*);
    void       RigidBody_GetRotLocal                 (RigidBody*, Quat*);
    void       RigidBody_SetRot                      (RigidBody*, Quat*);
    void       RigidBody_SetRotLocal                 (RigidBody*, Quat*);
    float      RigidBody_GetScale                    (RigidBody*);
    void       RigidBody_SetScale                    (RigidBody*, float);
  ]]
end

do -- Global Symbol Table
  RigidBody = {
    CreateBox                   = libphx.RigidBody_CreateBox,
    CreateBoxFromMesh           = libphx.RigidBody_CreateBoxFromMesh,
    CreateSphere                = libphx.RigidBody_CreateSphere,
    CreateSphereFromMesh        = libphx.RigidBody_CreateSphereFromMesh,
    CreateHullFromMesh          = libphx.RigidBody_CreateHullFromMesh,
    Free                        = libphx.RigidBody_Free,
    ApplyForce                  = libphx.RigidBody_ApplyForce,
    ApplyTorque                 = libphx.RigidBody_ApplyTorque,
    Attach                      = libphx.RigidBody_Attach,
    Detach                      = libphx.RigidBody_Detach,
    GetBoundingBox              = libphx.RigidBody_GetBoundingBox,
    GetBoundingBoxCompound      = libphx.RigidBody_GetBoundingBoxCompound,
    GetBoundingBoxLocal         = libphx.RigidBody_GetBoundingBoxLocal,
    GetBoundingBoxLocalCompound = libphx.RigidBody_GetBoundingBoxLocalCompound,
    GetBoundingRadius           = libphx.RigidBody_GetBoundingRadius,
    GetBoundingRadiusCompound   = libphx.RigidBody_GetBoundingRadiusCompound,
    GetParentBody               = libphx.RigidBody_GetParentBody,
    GetSpeed                    = libphx.RigidBody_GetSpeed,
    GetToLocalMatrix            = libphx.RigidBody_GetToLocalMatrix,
    GetToWorldMatrix            = libphx.RigidBody_GetToWorldMatrix,
    GetVelocity                 = libphx.RigidBody_GetVelocity,
    GetVelocityA                = libphx.RigidBody_GetVelocityA,
    SetCollidable               = libphx.RigidBody_SetCollidable,
    SetCollisionGroup           = libphx.RigidBody_SetCollisionGroup,
    SetCollisionMask            = libphx.RigidBody_SetCollisionMask,
    SetDrag                     = libphx.RigidBody_SetDrag,
    SetFriction                 = libphx.RigidBody_SetFriction,
    SetKinematic                = libphx.RigidBody_SetKinematic,
    SetRestitution              = libphx.RigidBody_SetRestitution,
    SetSleepThreshold           = libphx.RigidBody_SetSleepThreshold,
    GetMass                     = libphx.RigidBody_GetMass,
    SetMass                     = libphx.RigidBody_SetMass,
    GetPos                      = libphx.RigidBody_GetPos,
    GetPosLocal                 = libphx.RigidBody_GetPosLocal,
    SetPos                      = libphx.RigidBody_SetPos,
    SetPosLocal                 = libphx.RigidBody_SetPosLocal,
    GetRot                      = libphx.RigidBody_GetRot,
    GetRotLocal                 = libphx.RigidBody_GetRotLocal,
    SetRot                      = libphx.RigidBody_SetRot,
    SetRotLocal                 = libphx.RigidBody_SetRotLocal,
    GetScale                    = libphx.RigidBody_GetScale,
    SetScale                    = libphx.RigidBody_SetScale,
  }

  if onDef_RigidBody then onDef_RigidBody(RigidBody, mt) end
  RigidBody = setmetatable(RigidBody, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('RigidBody')
  local mt = {
    __index = {
      managed                     = function (self) return ffi.gc(self, libphx.RigidBody_Free) end,
      free                        = libphx.RigidBody_Free,
      applyForce                  = libphx.RigidBody_ApplyForce,
      applyTorque                 = libphx.RigidBody_ApplyTorque,
      attach                      = libphx.RigidBody_Attach,
      detach                      = libphx.RigidBody_Detach,
      getBoundingBox              = libphx.RigidBody_GetBoundingBox,
      getBoundingBoxCompound      = libphx.RigidBody_GetBoundingBoxCompound,
      getBoundingBoxLocal         = libphx.RigidBody_GetBoundingBoxLocal,
      getBoundingBoxLocalCompound = libphx.RigidBody_GetBoundingBoxLocalCompound,
      getBoundingRadius           = libphx.RigidBody_GetBoundingRadius,
      getBoundingRadiusCompound   = libphx.RigidBody_GetBoundingRadiusCompound,
      getParentBody               = libphx.RigidBody_GetParentBody,
      getSpeed                    = libphx.RigidBody_GetSpeed,
      getToLocalMatrix            = libphx.RigidBody_GetToLocalMatrix,
      getToWorldMatrix            = libphx.RigidBody_GetToWorldMatrix,
      getVelocity                 = libphx.RigidBody_GetVelocity,
      getVelocityA                = libphx.RigidBody_GetVelocityA,
      setCollidable               = libphx.RigidBody_SetCollidable,
      setCollisionGroup           = libphx.RigidBody_SetCollisionGroup,
      setCollisionMask            = libphx.RigidBody_SetCollisionMask,
      setDrag                     = libphx.RigidBody_SetDrag,
      setFriction                 = libphx.RigidBody_SetFriction,
      setKinematic                = libphx.RigidBody_SetKinematic,
      setRestitution              = libphx.RigidBody_SetRestitution,
      setSleepThreshold           = libphx.RigidBody_SetSleepThreshold,
      getMass                     = libphx.RigidBody_GetMass,
      setMass                     = libphx.RigidBody_SetMass,
      getPos                      = libphx.RigidBody_GetPos,
      getPosLocal                 = libphx.RigidBody_GetPosLocal,
      setPos                      = libphx.RigidBody_SetPos,
      setPosLocal                 = libphx.RigidBody_SetPosLocal,
      getRot                      = libphx.RigidBody_GetRot,
      getRotLocal                 = libphx.RigidBody_GetRotLocal,
      setRot                      = libphx.RigidBody_SetRot,
      setRotLocal                 = libphx.RigidBody_SetRotLocal,
      getScale                    = libphx.RigidBody_GetScale,
      setScale                    = libphx.RigidBody_SetScale,
    },
  }

  if onDef_RigidBody_t then onDef_RigidBody_t(t, mt) end
  RigidBody_t = ffi.metatype(t, mt)
end

return RigidBody
