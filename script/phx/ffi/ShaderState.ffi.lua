-- ShaderState -----------------------------------------------------------------
local ShaderState

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    ShaderState* ShaderState_Create         (Shader*);
    void         ShaderState_Acquire        (ShaderState*);
    void         ShaderState_Free           (ShaderState*);
    ShaderState* ShaderState_FromShaderLoad (cstr vertName, cstr fragName);
    void         ShaderState_SetFloat       (ShaderState*, cstr, float);
    void         ShaderState_SetFloat2      (ShaderState*, cstr, float, float);
    void         ShaderState_SetFloat3      (ShaderState*, cstr, float, float, float);
    void         ShaderState_SetFloat4      (ShaderState*, cstr, float, float, float, float);
    void         ShaderState_SetInt         (ShaderState*, cstr, int);
    void         ShaderState_SetMatrix      (ShaderState*, cstr, Matrix*);
    void         ShaderState_SetTex1D       (ShaderState*, cstr, Tex1D*);
    void         ShaderState_SetTex2D       (ShaderState*, cstr, Tex2D*);
    void         ShaderState_SetTex3D       (ShaderState*, cstr, Tex3D*);
    void         ShaderState_SetTexCube     (ShaderState*, cstr, TexCube*);
    void         ShaderState_Start          (ShaderState*);
    void         ShaderState_Stop           (ShaderState*);
  ]]
end

do -- Global Symbol Table
  ShaderState = {
    Create         = libphx.ShaderState_Create,
    Acquire        = libphx.ShaderState_Acquire,
    Free           = libphx.ShaderState_Free,
    FromShaderLoad = libphx.ShaderState_FromShaderLoad,
    SetFloat       = libphx.ShaderState_SetFloat,
    SetFloat2      = libphx.ShaderState_SetFloat2,
    SetFloat3      = libphx.ShaderState_SetFloat3,
    SetFloat4      = libphx.ShaderState_SetFloat4,
    SetInt         = libphx.ShaderState_SetInt,
    SetMatrix      = libphx.ShaderState_SetMatrix,
    SetTex1D       = libphx.ShaderState_SetTex1D,
    SetTex2D       = libphx.ShaderState_SetTex2D,
    SetTex3D       = libphx.ShaderState_SetTex3D,
    SetTexCube     = libphx.ShaderState_SetTexCube,
    Start          = libphx.ShaderState_Start,
    Stop           = libphx.ShaderState_Stop,
  }

  if onDef_ShaderState then onDef_ShaderState(ShaderState, mt) end
  ShaderState = setmetatable(ShaderState, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('ShaderState')
  local mt = {
    __index = {
      managed        = function (self) return ffi.gc(self, libphx.ShaderState_Free) end,
      acquire        = libphx.ShaderState_Acquire,
      free           = libphx.ShaderState_Free,
      setFloat       = libphx.ShaderState_SetFloat,
      setFloat2      = libphx.ShaderState_SetFloat2,
      setFloat3      = libphx.ShaderState_SetFloat3,
      setFloat4      = libphx.ShaderState_SetFloat4,
      setInt         = libphx.ShaderState_SetInt,
      setMatrix      = libphx.ShaderState_SetMatrix,
      setTex1D       = libphx.ShaderState_SetTex1D,
      setTex2D       = libphx.ShaderState_SetTex2D,
      setTex3D       = libphx.ShaderState_SetTex3D,
      setTexCube     = libphx.ShaderState_SetTexCube,
      start          = libphx.ShaderState_Start,
      stop           = libphx.ShaderState_Stop,
    },
  }

  if onDef_ShaderState_t then onDef_ShaderState_t(t, mt) end
  ShaderState_t = ffi.metatype(t, mt)
end

return ShaderState
