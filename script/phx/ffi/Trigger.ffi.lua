-- Trigger ---------------------------------------------------------------------
local Trigger

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Trigger*   Trigger_CreateBox        (Vec3f* halfExtents);
    void       Trigger_Free             (Trigger*);
    void       Trigger_Attach           (Trigger*, RigidBody*, Vec3f*);
    void       Trigger_Detach           (Trigger*, RigidBody*);
    void       Trigger_GetBoundingBox   (Trigger*, Box3f*);
    int        Trigger_GetContentsCount (Trigger*);
    RigidBody* Trigger_GetContents      (Trigger*, int);
    void       Trigger_SetCollisionMask (Trigger*, int);
    void       Trigger_SetPos           (Trigger*, Vec3f*);
    void       Trigger_SetPosLocal      (Trigger*, Vec3f*);
  ]]
end

do -- Global Symbol Table
  Trigger = {
    CreateBox        = libphx.Trigger_CreateBox,
    Free             = libphx.Trigger_Free,
    Attach           = libphx.Trigger_Attach,
    Detach           = libphx.Trigger_Detach,
    GetBoundingBox   = libphx.Trigger_GetBoundingBox,
    GetContentsCount = libphx.Trigger_GetContentsCount,
    GetContents      = libphx.Trigger_GetContents,
    SetCollisionMask = libphx.Trigger_SetCollisionMask,
    SetPos           = libphx.Trigger_SetPos,
    SetPosLocal      = libphx.Trigger_SetPosLocal,
  }

  if onDef_Trigger then onDef_Trigger(Trigger, mt) end
  Trigger = setmetatable(Trigger, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Trigger')
  local mt = {
    __index = {
      managed          = function (self) return ffi.gc(self, libphx.Trigger_Free) end,
      free             = libphx.Trigger_Free,
      attach           = libphx.Trigger_Attach,
      detach           = libphx.Trigger_Detach,
      getBoundingBox   = libphx.Trigger_GetBoundingBox,
      getContentsCount = libphx.Trigger_GetContentsCount,
      getContents      = libphx.Trigger_GetContents,
      setCollisionMask = libphx.Trigger_SetCollisionMask,
      setPos           = libphx.Trigger_SetPos,
      setPosLocal      = libphx.Trigger_SetPosLocal,
    },
  }

  if onDef_Trigger_t then onDef_Trigger_t(t, mt) end
  Trigger_t = ffi.metatype(t, mt)
end

return Trigger
