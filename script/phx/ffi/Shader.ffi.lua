-- Shader ----------------------------------------------------------------------
local Shader

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Shader*      Shader_Create        (cstr vertCode, cstr fragCode);
    Shader*      Shader_Load          (cstr vertName, cstr fragName);
    void         Shader_Acquire       (Shader*);
    void         Shader_Free          (Shader*);
    ShaderState* Shader_ToShaderState (Shader*);
    void         Shader_Start         (Shader*);
    void         Shader_Stop          (Shader*);
    uint         Shader_GetHandle     (Shader*);
    int          Shader_GetVariable   (Shader*, cstr);
    bool         Shader_HasVariable   (Shader*, cstr);
    void         Shader_ClearCache    ();
    void         Shader_SetFloat      (cstr, float);
    void         Shader_SetFloat2     (cstr, float, float);
    void         Shader_SetFloat3     (cstr, float, float, float);
    void         Shader_SetFloat4     (cstr, float, float, float, float);
    void         Shader_SetInt        (cstr, int);
    void         Shader_SetMatrix     (cstr, Matrix*);
    void         Shader_SetMatrixT    (cstr, Matrix*);
    void         Shader_SetTex1D      (cstr, Tex1D*);
    void         Shader_SetTex2D      (cstr, Tex2D*);
    void         Shader_SetTex3D      (cstr, Tex3D*);
    void         Shader_SetTexCube    (cstr, TexCube*);
    void         Shader_ISetFloat     (int, float);
    void         Shader_ISetFloat2    (int, float, float);
    void         Shader_ISetFloat3    (int, float, float, float);
    void         Shader_ISetFloat4    (int, float, float, float, float);
    void         Shader_ISetInt       (int, int);
    void         Shader_ISetMatrix    (int, Matrix*);
    void         Shader_ISetMatrixT   (int, Matrix*);
    void         Shader_ISetTex1D     (int, Tex1D*);
    void         Shader_ISetTex2D     (int, Tex2D*);
    void         Shader_ISetTex3D     (int, Tex3D*);
    void         Shader_ISetTexCube   (int, TexCube*);
  ]]
end

do -- Global Symbol Table
  Shader = {
    Create        = libphx.Shader_Create,
    Load          = libphx.Shader_Load,
    Acquire       = libphx.Shader_Acquire,
    Free          = libphx.Shader_Free,
    ToShaderState = libphx.Shader_ToShaderState,
    Start         = libphx.Shader_Start,
    Stop          = libphx.Shader_Stop,
    GetHandle     = libphx.Shader_GetHandle,
    GetVariable   = libphx.Shader_GetVariable,
    HasVariable   = libphx.Shader_HasVariable,
    ClearCache    = libphx.Shader_ClearCache,
    SetFloat      = libphx.Shader_SetFloat,
    SetFloat2     = libphx.Shader_SetFloat2,
    SetFloat3     = libphx.Shader_SetFloat3,
    SetFloat4     = libphx.Shader_SetFloat4,
    SetInt        = libphx.Shader_SetInt,
    SetMatrix     = libphx.Shader_SetMatrix,
    SetMatrixT    = libphx.Shader_SetMatrixT,
    SetTex1D      = libphx.Shader_SetTex1D,
    SetTex2D      = libphx.Shader_SetTex2D,
    SetTex3D      = libphx.Shader_SetTex3D,
    SetTexCube    = libphx.Shader_SetTexCube,
    ISetFloat     = libphx.Shader_ISetFloat,
    ISetFloat2    = libphx.Shader_ISetFloat2,
    ISetFloat3    = libphx.Shader_ISetFloat3,
    ISetFloat4    = libphx.Shader_ISetFloat4,
    ISetInt       = libphx.Shader_ISetInt,
    ISetMatrix    = libphx.Shader_ISetMatrix,
    ISetMatrixT   = libphx.Shader_ISetMatrixT,
    ISetTex1D     = libphx.Shader_ISetTex1D,
    ISetTex2D     = libphx.Shader_ISetTex2D,
    ISetTex3D     = libphx.Shader_ISetTex3D,
    ISetTexCube   = libphx.Shader_ISetTexCube,
  }

  if onDef_Shader then onDef_Shader(Shader, mt) end
  Shader = setmetatable(Shader, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Shader')
  local mt = {
    __index = {
      managed       = function (self) return ffi.gc(self, libphx.Shader_Free) end,
      acquire       = libphx.Shader_Acquire,
      free          = libphx.Shader_Free,
      toShaderState = libphx.Shader_ToShaderState,
      start         = libphx.Shader_Start,
      stop          = libphx.Shader_Stop,
      getHandle     = libphx.Shader_GetHandle,
      getVariable   = libphx.Shader_GetVariable,
      hasVariable   = libphx.Shader_HasVariable,
    },
  }

  if onDef_Shader_t then onDef_Shader_t(t, mt) end
  Shader_t = ffi.metatype(t, mt)
end

return Shader
