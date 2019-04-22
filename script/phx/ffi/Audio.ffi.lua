-- Audio -----------------------------------------------------------------------
local Audio

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void  Audio_Init              ();
    void  Audio_Free              ();
    void  Audio_AttachListenerPos (Vec3f const* pos, Vec3f const* vel, Vec3f const* fwd, Vec3f const* up);
    void  Audio_Set3DSettings     (float doppler, float scale, float rolloff);
    void  Audio_SetListenerPos    (Vec3f const* pos, Vec3f const* vel, Vec3f const* fwd, Vec3f const* up);
    void  Audio_Update            ();
    int32 Audio_GetLoadedCount    ();
    int32 Audio_GetPlayingCount   ();
    int32 Audio_GetTotalCount     ();
  ]]
end

do -- Global Symbol Table
  Audio = {
    Init              = libphx.Audio_Init,
    Free              = libphx.Audio_Free,
    AttachListenerPos = libphx.Audio_AttachListenerPos,
    Set3DSettings     = libphx.Audio_Set3DSettings,
    SetListenerPos    = libphx.Audio_SetListenerPos,
    Update            = libphx.Audio_Update,
    GetLoadedCount    = libphx.Audio_GetLoadedCount,
    GetPlayingCount   = libphx.Audio_GetPlayingCount,
    GetTotalCount     = libphx.Audio_GetTotalCount,
  }

  if onDef_Audio then onDef_Audio(Audio, mt) end
  Audio = setmetatable(Audio, mt)
end

return Audio
