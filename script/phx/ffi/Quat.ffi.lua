-- Quat ------------------------------------------------------------------------
local Quat

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Quat  Quat_Create             (float x, float y, float z, float w);
    void  Quat_GetAxisX           (Quat const*, Vec3f*);
    void  Quat_GetAxisY           (Quat const*, Vec3f*);
    void  Quat_GetAxisZ           (Quat const*, Vec3f*);
    void  Quat_GetForward         (Quat const*, Vec3f*);
    void  Quat_GetRight           (Quat const*, Vec3f*);
    void  Quat_GetUp              (Quat const*, Vec3f*);
    void  Quat_Identity           (Quat*);
    void  Quat_Canonicalize       (Quat const*, Quat* out);
    void  Quat_ICanonicalize      (Quat*);
    float Quat_Dot                (Quat const*, Quat const*);
    bool  Quat_Equal              (Quat const*, Quat const*);
    bool  Quat_ApproximatelyEqual (Quat const*, Quat const*);
    void  Quat_Inverse            (Quat const*, Quat* out);
    void  Quat_IInverse           (Quat*);
    void  Quat_Lerp               (Quat const*, Quat const*, float t, Quat* out);
    void  Quat_ILerp              (Quat*, Quat const*, float t);
    void  Quat_Mul                (Quat const*, Quat const*, Quat* out);
    void  Quat_IMul               (Quat*, Quat const*);
    void  Quat_MulV               (Quat const*, Vec3f const*, Vec3f* out);
    void  Quat_Normalize          (Quat const*, Quat* out);
    void  Quat_INormalize         (Quat*);
    void  Quat_Scale              (Quat const*, float, Quat* out);
    void  Quat_IScale             (Quat*, float);
    void  Quat_Slerp              (Quat const*, Quat const*, float, Quat* out);
    void  Quat_ISlerp             (Quat*, Quat const*, float);
    cstr  Quat_ToString           (Quat const*);
    Error Quat_Validate           (Quat const*);
    void  Quat_FromAxisAngle      (Vec3f const* axis, float radians, Quat*);
    void  Quat_FromBasis          (Vec3f const* x, Vec3f const* y, Vec3f const* z, Quat*);
    void  Quat_FromLookUp         (Vec3f const* look, Vec3f const* up, Quat*);
    void  Quat_FromRotateTo       (Vec3f const* from, Vec3f const* to, Quat*);
  ]]
end

do -- Global Symbol Table
  Quat = {
    Create             = libphx.Quat_Create,
    GetAxisX           = libphx.Quat_GetAxisX,
    GetAxisY           = libphx.Quat_GetAxisY,
    GetAxisZ           = libphx.Quat_GetAxisZ,
    GetForward         = libphx.Quat_GetForward,
    GetRight           = libphx.Quat_GetRight,
    GetUp              = libphx.Quat_GetUp,
    Identity           = libphx.Quat_Identity,
    Canonicalize       = libphx.Quat_Canonicalize,
    ICanonicalize      = libphx.Quat_ICanonicalize,
    Dot                = libphx.Quat_Dot,
    Equal              = libphx.Quat_Equal,
    ApproximatelyEqual = libphx.Quat_ApproximatelyEqual,
    Inverse            = libphx.Quat_Inverse,
    IInverse           = libphx.Quat_IInverse,
    Lerp               = libphx.Quat_Lerp,
    ILerp              = libphx.Quat_ILerp,
    Mul                = libphx.Quat_Mul,
    IMul               = libphx.Quat_IMul,
    MulV               = libphx.Quat_MulV,
    Normalize          = libphx.Quat_Normalize,
    INormalize         = libphx.Quat_INormalize,
    Scale              = libphx.Quat_Scale,
    IScale             = libphx.Quat_IScale,
    Slerp              = libphx.Quat_Slerp,
    ISlerp             = libphx.Quat_ISlerp,
    ToString           = libphx.Quat_ToString,
    Validate           = libphx.Quat_Validate,
    FromAxisAngle      = libphx.Quat_FromAxisAngle,
    FromBasis          = libphx.Quat_FromBasis,
    FromLookUp         = libphx.Quat_FromLookUp,
    FromRotateTo       = libphx.Quat_FromRotateTo,
  }

  local mt = {
    __call  = function (t, ...) return Quat_t(...) end,
  }

  if onDef_Quat then onDef_Quat(Quat, mt) end
  Quat = setmetatable(Quat, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Quat')
  local mt = {
    __tostring = function (self) return ffi.string(libphx.Quat_ToString(self)) end,
    __index = {
      clone              = function (x) return Quat_t(x) end,
      getAxisX           = libphx.Quat_GetAxisX,
      getAxisY           = libphx.Quat_GetAxisY,
      getAxisZ           = libphx.Quat_GetAxisZ,
      getForward         = libphx.Quat_GetForward,
      getRight           = libphx.Quat_GetRight,
      getUp              = libphx.Quat_GetUp,
      identity           = libphx.Quat_Identity,
      canonicalize       = libphx.Quat_Canonicalize,
      iCanonicalize      = libphx.Quat_ICanonicalize,
      dot                = libphx.Quat_Dot,
      equal              = libphx.Quat_Equal,
      approximatelyEqual = libphx.Quat_ApproximatelyEqual,
      inverse            = libphx.Quat_Inverse,
      iInverse           = libphx.Quat_IInverse,
      lerp               = libphx.Quat_Lerp,
      iLerp              = libphx.Quat_ILerp,
      mul                = libphx.Quat_Mul,
      iMul               = libphx.Quat_IMul,
      mulV               = libphx.Quat_MulV,
      normalize          = libphx.Quat_Normalize,
      iNormalize         = libphx.Quat_INormalize,
      scale              = libphx.Quat_Scale,
      iScale             = libphx.Quat_IScale,
      slerp              = libphx.Quat_Slerp,
      iSlerp             = libphx.Quat_ISlerp,
      toString           = libphx.Quat_ToString,
      validate           = libphx.Quat_Validate,
    },
  }

  if onDef_Quat_t then onDef_Quat_t(t, mt) end
  Quat_t = ffi.metatype(t, mt)
end

return Quat
