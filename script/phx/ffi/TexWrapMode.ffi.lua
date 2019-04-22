-- TexWrapMode -----------------------------------------------------------------
local TexWrapMode

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    TexWrapMode TexWrapMode_Clamp;
    TexWrapMode TexWrapMode_MirrorClamp;
    TexWrapMode TexWrapMode_MirrorRepeat;
    TexWrapMode TexWrapMode_Repeat;
  ]]
end

do -- Global Symbol Table
  TexWrapMode = {
    Clamp        = libphx.TexWrapMode_Clamp,
    MirrorClamp  = libphx.TexWrapMode_MirrorClamp,
    MirrorRepeat = libphx.TexWrapMode_MirrorRepeat,
    Repeat       = libphx.TexWrapMode_Repeat,
  }

  if onDef_TexWrapMode then onDef_TexWrapMode(TexWrapMode, mt) end
  TexWrapMode = setmetatable(TexWrapMode, mt)
end

return TexWrapMode
