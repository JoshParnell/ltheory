-- ClipRect --------------------------------------------------------------------
local ClipRect

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void ClipRect_Push          (float x, float y, float sx, float sy);
    void ClipRect_PushCombined  (float x, float y, float sx, float sy);
    void ClipRect_PushDisabled  ();
    void ClipRect_PushTransform (float tx, float ty, float sx, float sy);
    void ClipRect_Pop           ();
    void ClipRect_PopTransform  ();
  ]]
end

do -- Global Symbol Table
  ClipRect = {
    Push          = libphx.ClipRect_Push,
    PushCombined  = libphx.ClipRect_PushCombined,
    PushDisabled  = libphx.ClipRect_PushDisabled,
    PushTransform = libphx.ClipRect_PushTransform,
    Pop           = libphx.ClipRect_Pop,
    PopTransform  = libphx.ClipRect_PopTransform,
  }

  if onDef_ClipRect then onDef_ClipRect(ClipRect, mt) end
  ClipRect = setmetatable(ClipRect, mt)
end

return ClipRect
