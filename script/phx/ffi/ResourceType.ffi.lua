-- ResourceType ----------------------------------------------------------------
local ResourceType

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    cstr         ResourceType_ToString (ResourceType);
    ResourceType ResourceType_Font;
    ResourceType ResourceType_Mesh;
    ResourceType ResourceType_Other;
    ResourceType ResourceType_Script;
    ResourceType ResourceType_Shader;
    ResourceType ResourceType_Sound;
    ResourceType ResourceType_Tex1D;
    ResourceType ResourceType_Tex2D;
    ResourceType ResourceType_Tex3D;
    ResourceType ResourceType_TexCube;
  ]]
end

do -- Global Symbol Table
  ResourceType = {
    Font    = libphx.ResourceType_Font,
    Mesh    = libphx.ResourceType_Mesh,
    Other   = libphx.ResourceType_Other,
    Script  = libphx.ResourceType_Script,
    Shader  = libphx.ResourceType_Shader,
    Sound   = libphx.ResourceType_Sound,
    Tex1D   = libphx.ResourceType_Tex1D,
    Tex2D   = libphx.ResourceType_Tex2D,
    Tex3D   = libphx.ResourceType_Tex3D,
    TexCube = libphx.ResourceType_TexCube,
    COUNT   = 0xA,
    ToString = libphx.ResourceType_ToString,
  }

  if onDef_ResourceType then onDef_ResourceType(ResourceType, mt) end
  ResourceType = setmetatable(ResourceType, mt)
end

return ResourceType
