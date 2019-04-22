-- ShaderVarType ---------------------------------------------------------------
local ShaderVarType

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    ShaderVarType ShaderVarType_FromStr     (cstr);
    cstr          ShaderVarType_GetGLSLName (ShaderVarType);
    cstr          ShaderVarType_GetName     (ShaderVarType);
    int           ShaderVarType_GetSize     (ShaderVarType);
  ]]
end

do -- Global Symbol Table
  ShaderVarType = {
    None    = 0x0,
    BEGIN   = 0x1,
    Float   = 0x1,
    Float2  = 0x2,
    Float3  = 0x3,
    Float4  = 0x4,
    Int     = 0x5,
    Int2    = 0x6,
    Int3    = 0x7,
    Int4    = 0x8,
    Matrix  = 0x9,
    Tex1D   = 0xA,
    Tex2D   = 0xB,
    Tex3D   = 0xC,
    TexCube = 0xD,
    END     = 0xD,
    SIZE    = 0xD,
    FromStr     = libphx.ShaderVarType_FromStr,
    GetGLSLName = libphx.ShaderVarType_GetGLSLName,
    GetName     = libphx.ShaderVarType_GetName,
    GetSize     = libphx.ShaderVarType_GetSize,
  }

  if onDef_ShaderVarType then onDef_ShaderVarType(ShaderVarType, mt) end
  ShaderVarType = setmetatable(ShaderVarType, mt)
end

return ShaderVarType
