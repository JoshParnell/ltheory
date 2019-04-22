-- RNG -------------------------------------------------------------------------
local RNG

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    RNG*   RNG_Create          (uint64 seed);
    RNG*   RNG_FromStr         (cstr);
    RNG*   RNG_FromTime        ();
    void   RNG_Free            (RNG*);
    void   RNG_Rewind          (RNG*);
    bool   RNG_Chance          (RNG*, double probability);
    int32  RNG_Get31           (RNG*);
    uint32 RNG_Get32           (RNG*);
    uint64 RNG_Get64           (RNG*);
    double RNG_GetAngle        (RNG*);
    double RNG_GetErlang       (RNG*, int k);
    double RNG_GetExp          (RNG*);
    double RNG_GetGaussian     (RNG*);
    int    RNG_GetInt          (RNG*, int lower, int upper);
    RNG*   RNG_GetRNG          (RNG*);
    double RNG_GetSign         (RNG*);
    double RNG_GetUniform      (RNG*);
    double RNG_GetUniformRange (RNG*, double lower, double upper);
    void   RNG_GetAxis2        (RNG*, Vec2f* out);
    void   RNG_GetAxis3        (RNG*, Vec3f* out);
    void   RNG_GetDir2         (RNG*, Vec2f* out);
    void   RNG_GetDir3         (RNG*, Vec3f* out);
    void   RNG_GetDisc         (RNG*, Vec2f* out);
    void   RNG_GetSphere       (RNG*, Vec3f* out);
    void   RNG_GetVec2         (RNG*, Vec2f* out, double lower, double upper);
    void   RNG_GetVec3         (RNG*, Vec3f* out, double lower, double upper);
    void   RNG_GetVec4         (RNG*, Vec4f* out, double lower, double upper);
    void   RNG_GetQuat         (RNG*, Quat* out);
  ]]
end

do -- Global Symbol Table
  RNG = {
    Create          = libphx.RNG_Create,
    FromStr         = libphx.RNG_FromStr,
    FromTime        = libphx.RNG_FromTime,
    Free            = libphx.RNG_Free,
    Rewind          = libphx.RNG_Rewind,
    Chance          = libphx.RNG_Chance,
    Get31           = libphx.RNG_Get31,
    Get32           = libphx.RNG_Get32,
    Get64           = libphx.RNG_Get64,
    GetAngle        = libphx.RNG_GetAngle,
    GetErlang       = libphx.RNG_GetErlang,
    GetExp          = libphx.RNG_GetExp,
    GetGaussian     = libphx.RNG_GetGaussian,
    GetInt          = libphx.RNG_GetInt,
    GetRNG          = libphx.RNG_GetRNG,
    GetSign         = libphx.RNG_GetSign,
    GetUniform      = libphx.RNG_GetUniform,
    GetUniformRange = libphx.RNG_GetUniformRange,
    GetAxis2        = libphx.RNG_GetAxis2,
    GetAxis3        = libphx.RNG_GetAxis3,
    GetDir2         = libphx.RNG_GetDir2,
    GetDir3         = libphx.RNG_GetDir3,
    GetDisc         = libphx.RNG_GetDisc,
    GetSphere       = libphx.RNG_GetSphere,
    GetVec2         = libphx.RNG_GetVec2,
    GetVec3         = libphx.RNG_GetVec3,
    GetVec4         = libphx.RNG_GetVec4,
    GetQuat         = libphx.RNG_GetQuat,
  }

  if onDef_RNG then onDef_RNG(RNG, mt) end
  RNG = setmetatable(RNG, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('RNG')
  local mt = {
    __index = {
      managed         = function (self) return ffi.gc(self, libphx.RNG_Free) end,
      free            = libphx.RNG_Free,
      rewind          = libphx.RNG_Rewind,
      chance          = libphx.RNG_Chance,
      get31           = libphx.RNG_Get31,
      get32           = libphx.RNG_Get32,
      get64           = libphx.RNG_Get64,
      getAngle        = libphx.RNG_GetAngle,
      getErlang       = libphx.RNG_GetErlang,
      getExp          = libphx.RNG_GetExp,
      getGaussian     = libphx.RNG_GetGaussian,
      getInt          = libphx.RNG_GetInt,
      getRNG          = libphx.RNG_GetRNG,
      getSign         = libphx.RNG_GetSign,
      getUniform      = libphx.RNG_GetUniform,
      getUniformRange = libphx.RNG_GetUniformRange,
      getAxis2        = libphx.RNG_GetAxis2,
      getAxis3        = libphx.RNG_GetAxis3,
      getDir2         = libphx.RNG_GetDir2,
      getDir3         = libphx.RNG_GetDir3,
      getDisc         = libphx.RNG_GetDisc,
      getSphere       = libphx.RNG_GetSphere,
      getVec2         = libphx.RNG_GetVec2,
      getVec3         = libphx.RNG_GetVec3,
      getVec4         = libphx.RNG_GetVec4,
      getQuat         = libphx.RNG_GetQuat,
    },
  }

  if onDef_RNG_t then onDef_RNG_t(t, mt) end
  RNG_t = ffi.metatype(t, mt)
end

return RNG
