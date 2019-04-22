-- Sound -----------------------------------------------------------------------
local Sound

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void   Sound_Acquire               (Sound*);
    void   Sound_Free                  (Sound*);
    Sound* Sound_Load                  (cstr name, bool isLooped, bool is3D);
    Sound* Sound_LoadAsync             (cstr name, bool isLooped, bool is3D);
    Sound* Sound_Clone                 (Sound*);
    void   Sound_ToFile                (Sound*, cstr);
    void   Sound_Pause                 (Sound*);
    void   Sound_Play                  (Sound*);
    void   Sound_Rewind                (Sound*);
    bool   Sound_Get3D                 (Sound*);
    float  Sound_GetDuration           (Sound*);
    bool   Sound_GetLooped             (Sound*);
    cstr   Sound_GetName               (Sound*);
    cstr   Sound_GetPath               (Sound*);
    bool   Sound_IsFinished            (Sound*);
    bool   Sound_IsPlaying             (Sound*);
    void   Sound_Attach3DPos           (Sound*, Vec3f const* pos, Vec3f const* vel);
    void   Sound_Set3DLevel            (Sound*, float);
    void   Sound_Set3DPos              (Sound*, Vec3f const* pos, Vec3f const* vel);
    void   Sound_SetFreeOnFinish       (Sound*, bool);
    void   Sound_SetPan                (Sound*, float);
    void   Sound_SetPitch              (Sound*, float);
    void   Sound_SetPlayPos            (Sound*, float);
    void   Sound_SetVolume             (Sound*, float);
    Sound* Sound_LoadPlay              (cstr name, bool isLooped, bool is3D);
    Sound* Sound_LoadPlayAttached      (cstr name, bool isLooped, bool is3D, Vec3f const* pos, Vec3f const* vel);
    void   Sound_LoadPlayFree          (cstr name, bool isLooped, bool is3D);
    void   Sound_LoadPlayFreeAttached  (cstr name, bool isLooped, bool is3D, Vec3f const* pos, Vec3f const* vel);
    Sound* Sound_ClonePlay             (Sound*);
    Sound* Sound_ClonePlayAttached     (Sound*, Vec3f const* pos, Vec3f const* vel);
    void   Sound_ClonePlayFree         (Sound*);
    void   Sound_ClonePlayFreeAttached (Sound*, Vec3f const* pos, Vec3f const* vel);
  ]]
end

do -- Global Symbol Table
  Sound = {
    Acquire               = libphx.Sound_Acquire,
    Free                  = libphx.Sound_Free,
    Load                  = libphx.Sound_Load,
    LoadAsync             = libphx.Sound_LoadAsync,
    Clone                 = libphx.Sound_Clone,
    ToFile                = libphx.Sound_ToFile,
    Pause                 = libphx.Sound_Pause,
    Play                  = libphx.Sound_Play,
    Rewind                = libphx.Sound_Rewind,
    Get3D                 = libphx.Sound_Get3D,
    GetDuration           = libphx.Sound_GetDuration,
    GetLooped             = libphx.Sound_GetLooped,
    GetName               = libphx.Sound_GetName,
    GetPath               = libphx.Sound_GetPath,
    IsFinished            = libphx.Sound_IsFinished,
    IsPlaying             = libphx.Sound_IsPlaying,
    Attach3DPos           = libphx.Sound_Attach3DPos,
    Set3DLevel            = libphx.Sound_Set3DLevel,
    Set3DPos              = libphx.Sound_Set3DPos,
    SetFreeOnFinish       = libphx.Sound_SetFreeOnFinish,
    SetPan                = libphx.Sound_SetPan,
    SetPitch              = libphx.Sound_SetPitch,
    SetPlayPos            = libphx.Sound_SetPlayPos,
    SetVolume             = libphx.Sound_SetVolume,
    LoadPlay              = libphx.Sound_LoadPlay,
    LoadPlayAttached      = libphx.Sound_LoadPlayAttached,
    LoadPlayFree          = libphx.Sound_LoadPlayFree,
    LoadPlayFreeAttached  = libphx.Sound_LoadPlayFreeAttached,
    ClonePlay             = libphx.Sound_ClonePlay,
    ClonePlayAttached     = libphx.Sound_ClonePlayAttached,
    ClonePlayFree         = libphx.Sound_ClonePlayFree,
    ClonePlayFreeAttached = libphx.Sound_ClonePlayFreeAttached,
  }

  if onDef_Sound then onDef_Sound(Sound, mt) end
  Sound = setmetatable(Sound, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Sound')
  local mt = {
    __index = {
      managed               = function (self) return ffi.gc(self, libphx.Sound_Free) end,
      acquire               = libphx.Sound_Acquire,
      free                  = libphx.Sound_Free,
      clone                 = libphx.Sound_Clone,
      toFile                = libphx.Sound_ToFile,
      pause                 = libphx.Sound_Pause,
      play                  = libphx.Sound_Play,
      rewind                = libphx.Sound_Rewind,
      get3D                 = libphx.Sound_Get3D,
      getDuration           = libphx.Sound_GetDuration,
      getLooped             = libphx.Sound_GetLooped,
      getName               = libphx.Sound_GetName,
      getPath               = libphx.Sound_GetPath,
      isFinished            = libphx.Sound_IsFinished,
      isPlaying             = libphx.Sound_IsPlaying,
      attach3DPos           = libphx.Sound_Attach3DPos,
      set3DLevel            = libphx.Sound_Set3DLevel,
      set3DPos              = libphx.Sound_Set3DPos,
      setFreeOnFinish       = libphx.Sound_SetFreeOnFinish,
      setPan                = libphx.Sound_SetPan,
      setPitch              = libphx.Sound_SetPitch,
      setPlayPos            = libphx.Sound_SetPlayPos,
      setVolume             = libphx.Sound_SetVolume,
      clonePlay             = libphx.Sound_ClonePlay,
      clonePlayAttached     = libphx.Sound_ClonePlayAttached,
      clonePlayFree         = libphx.Sound_ClonePlayFree,
      clonePlayFreeAttached = libphx.Sound_ClonePlayFreeAttached,
    },
  }

  if onDef_Sound_t then onDef_Sound_t(t, mt) end
  Sound_t = ffi.metatype(t, mt)
end

return Sound
