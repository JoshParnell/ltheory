-- GLMatrix --------------------------------------------------------------------
local GLMatrix

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void    GLMatrix_Clear       ();
    void    GLMatrix_LookAt      (Vec3d const* eye, Vec3d const* at, Vec3d const* up);
    void    GLMatrix_Load        (Matrix* matrix);
    void    GLMatrix_ModeP       ();
    void    GLMatrix_ModeWV      ();
    Matrix* GLMatrix_Get         ();
    void    GLMatrix_Mult        (Matrix* matrix);
    void    GLMatrix_Perspective (double degreesFovY, double aspect, double zNear, double zFar);
    void    GLMatrix_Pop         ();
    void    GLMatrix_Push        ();
    void    GLMatrix_PushClear   ();
    void    GLMatrix_RotateX     (double rads);
    void    GLMatrix_RotateY     (double rads);
    void    GLMatrix_RotateZ     (double rads);
    void    GLMatrix_Scale       (double x, double y, double z);
    void    GLMatrix_Translate   (double x, double y, double z);
  ]]
end

do -- Global Symbol Table
  GLMatrix = {
    Clear       = libphx.GLMatrix_Clear,
    LookAt      = libphx.GLMatrix_LookAt,
    Load        = libphx.GLMatrix_Load,
    ModeP       = libphx.GLMatrix_ModeP,
    ModeWV      = libphx.GLMatrix_ModeWV,
    Get         = libphx.GLMatrix_Get,
    Mult        = libphx.GLMatrix_Mult,
    Perspective = libphx.GLMatrix_Perspective,
    Pop         = libphx.GLMatrix_Pop,
    Push        = libphx.GLMatrix_Push,
    PushClear   = libphx.GLMatrix_PushClear,
    RotateX     = libphx.GLMatrix_RotateX,
    RotateY     = libphx.GLMatrix_RotateY,
    RotateZ     = libphx.GLMatrix_RotateZ,
    Scale       = libphx.GLMatrix_Scale,
    Translate   = libphx.GLMatrix_Translate,
  }

  if onDef_GLMatrix then onDef_GLMatrix(GLMatrix, mt) end
  GLMatrix = setmetatable(GLMatrix, mt)
end

return GLMatrix
