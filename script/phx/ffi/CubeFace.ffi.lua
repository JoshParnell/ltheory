-- CubeFace --------------------------------------------------------------------
local CubeFace

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    CubeFace CubeFace_Get (int index);
    CubeFace CubeFace_PX;
    CubeFace CubeFace_NX;
    CubeFace CubeFace_PY;
    CubeFace CubeFace_NY;
    CubeFace CubeFace_PZ;
    CubeFace CubeFace_NZ;
  ]]
end

do -- Global Symbol Table
  CubeFace = {
    PX = libphx.CubeFace_PX,
    NX = libphx.CubeFace_NX,
    PY = libphx.CubeFace_PY,
    NY = libphx.CubeFace_NY,
    PZ = libphx.CubeFace_PZ,
    NZ = libphx.CubeFace_NZ,
    Get = libphx.CubeFace_Get,
  }

  if onDef_CubeFace then onDef_CubeFace(CubeFace, mt) end
  CubeFace = setmetatable(CubeFace, mt)
end

return CubeFace
