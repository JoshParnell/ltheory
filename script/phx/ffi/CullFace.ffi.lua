-- CullFace --------------------------------------------------------------------
local CullFace

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void CullFace_Pop       ();
    void CullFace_Push      (CullFace);
    void CullFace_PushNone  ();
    void CullFace_PushBack  ();
    void CullFace_PushFront ();
  ]]
end

do -- Global Symbol Table
  CullFace = {
    None  = 0,
    Back  = 1,
    Front = 2,
    Pop       = libphx.CullFace_Pop,
    Push      = libphx.CullFace_Push,
    PushNone  = libphx.CullFace_PushNone,
    PushBack  = libphx.CullFace_PushBack,
    PushFront = libphx.CullFace_PushFront,
  }

  if onDef_CullFace then onDef_CullFace(CullFace, mt) end
  CullFace = setmetatable(CullFace, mt)
end

return CullFace
