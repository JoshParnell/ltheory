-- ShaderVar -------------------------------------------------------------------
local ShaderVar

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void* ShaderVar_Get         (cstr, ShaderVarType);
    void  ShaderVar_PushFloat   (cstr, float);
    void  ShaderVar_PushFloat2  (cstr, float, float);
    void  ShaderVar_PushFloat3  (cstr, float, float, float);
    void  ShaderVar_PushFloat4  (cstr, float, float, float, float);
    void  ShaderVar_PushInt     (cstr, int);
    void  ShaderVar_PushMatrix  (cstr, Matrix*);
    void  ShaderVar_PushTex1D   (cstr, Tex1D*);
    void  ShaderVar_PushTex2D   (cstr, Tex2D*);
    void  ShaderVar_PushTex3D   (cstr, Tex3D*);
    void  ShaderVar_PushTexCube (cstr, TexCube*);
    void  ShaderVar_Pop         (cstr);
  ]]
end

do -- Global Symbol Table
  ShaderVar = {
    Get         = libphx.ShaderVar_Get,
    PushFloat   = libphx.ShaderVar_PushFloat,
    PushFloat2  = libphx.ShaderVar_PushFloat2,
    PushFloat3  = libphx.ShaderVar_PushFloat3,
    PushFloat4  = libphx.ShaderVar_PushFloat4,
    PushInt     = libphx.ShaderVar_PushInt,
    PushMatrix  = libphx.ShaderVar_PushMatrix,
    PushTex1D   = libphx.ShaderVar_PushTex1D,
    PushTex2D   = libphx.ShaderVar_PushTex2D,
    PushTex3D   = libphx.ShaderVar_PushTex3D,
    PushTexCube = libphx.ShaderVar_PushTexCube,
    Pop         = libphx.ShaderVar_Pop,
  }

  if onDef_ShaderVar then onDef_ShaderVar(ShaderVar, mt) end
  ShaderVar = setmetatable(ShaderVar, mt)
end

return ShaderVar
