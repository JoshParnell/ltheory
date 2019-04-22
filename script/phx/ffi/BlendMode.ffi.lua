-- BlendMode -------------------------------------------------------------------
local BlendMode

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void BlendMode_Pop              ();
    void BlendMode_Push             (BlendMode);
    void BlendMode_PushAdditive     ();
    void BlendMode_PushAlpha        ();
    void BlendMode_PushDisabled     ();
    void BlendMode_PushPreMultAlpha ();
  ]]
end

do -- Global Symbol Table
  BlendMode = {
    Additive     = 0,
    Alpha        = 1,
    Disabled     = 2,
    PreMultAlpha = 3,
    Pop              = libphx.BlendMode_Pop,
    Push             = libphx.BlendMode_Push,
    PushAdditive     = libphx.BlendMode_PushAdditive,
    PushAlpha        = libphx.BlendMode_PushAlpha,
    PushDisabled     = libphx.BlendMode_PushDisabled,
    PushPreMultAlpha = libphx.BlendMode_PushPreMultAlpha,
  }

  if onDef_BlendMode then onDef_BlendMode(BlendMode, mt) end
  BlendMode = setmetatable(BlendMode, mt)
end

return BlendMode
