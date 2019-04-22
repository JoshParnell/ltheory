-- Matrix ----------------------------------------------------------------------
local Matrix

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Matrix* Matrix_Clone              (Matrix const*);
    void    Matrix_Free               (Matrix*);
    bool    Matrix_Equal              (Matrix const*, Matrix const*);
    bool    Matrix_ApproximatelyEqual (Matrix const*, Matrix const*);
    Matrix* Matrix_Inverse            (Matrix const*);
    Matrix* Matrix_InverseTranspose   (Matrix const*);
    Matrix* Matrix_Product            (Matrix const*, Matrix const*);
    Matrix* Matrix_Sum                (Matrix const*, Matrix const*);
    Matrix* Matrix_Transpose          (Matrix const*);
    void    Matrix_IInverse           (Matrix*);
    void    Matrix_IScale             (Matrix*, float);
    void    Matrix_ITranspose         (Matrix*);
    Matrix* Matrix_Identity           ();
    Matrix* Matrix_LookAt             (Vec3f const* pos, Vec3f const* at, Vec3f const* up);
    Matrix* Matrix_LookUp             (Vec3f const* pos, Vec3f const* look, Vec3f const* up);
    Matrix* Matrix_Perspective        (float degreesFovY, float aspect, float zNear, float zFar);
    Matrix* Matrix_RotationX          (float rads);
    Matrix* Matrix_RotationY          (float rads);
    Matrix* Matrix_RotationZ          (float rads);
    Matrix* Matrix_Scaling            (float sx, float sy, float sz);
    Matrix* Matrix_SRT                (float sx, float sy, float sz, float ry, float rp, float rr, float tx, float ty, float tz);
    Matrix* Matrix_Translation        (float tx, float ty, float tz);
    Matrix* Matrix_YawPitchRoll       (float yaw, float pitch, float roll);
    void    Matrix_MulBox             (Matrix const*, Box3f* out, Box3f const* in);
    void    Matrix_MulDir             (Matrix const*, Vec3f* out, float x, float y, float z);
    void    Matrix_MulPoint           (Matrix const*, Vec3f* out, float x, float y, float z);
    void    Matrix_MulVec             (Matrix const*, Vec4f* out, float x, float y, float z, float w);
    void    Matrix_GetForward         (Matrix const*, Vec3f* out);
    void    Matrix_GetRight           (Matrix const*, Vec3f* out);
    void    Matrix_GetUp              (Matrix const*, Vec3f* out);
    void    Matrix_GetPos             (Matrix const*, Vec3f* out);
    void    Matrix_GetRow             (Matrix const*, Vec4f* out, int row);
    Matrix* Matrix_FromBasis          (Vec3f const* x, Vec3f const* y, Vec3f const* z);
    Matrix* Matrix_FromPosRot         (Vec3f const*, Quat const*);
    Matrix* Matrix_FromPosRotScale    (Vec3f const*, Quat const*, float);
    Matrix* Matrix_FromPosBasis       (Vec3f const* pos, Vec3f const* x, Vec3f const* y, Vec3f const* z);
    Matrix* Matrix_FromQuat           (Quat const*);
    void    Matrix_ToQuat             (Matrix const*, Quat* out);
    void    Matrix_Print              (Matrix const*);
    cstr    Matrix_ToString           (Matrix const*);
  ]]
end

do -- Global Symbol Table
  Matrix = {
    Clone              = libphx.Matrix_Clone,
    Free               = libphx.Matrix_Free,
    Equal              = libphx.Matrix_Equal,
    ApproximatelyEqual = libphx.Matrix_ApproximatelyEqual,
    Inverse            = libphx.Matrix_Inverse,
    InverseTranspose   = libphx.Matrix_InverseTranspose,
    Product            = libphx.Matrix_Product,
    Sum                = libphx.Matrix_Sum,
    Transpose          = libphx.Matrix_Transpose,
    IInverse           = libphx.Matrix_IInverse,
    IScale             = libphx.Matrix_IScale,
    ITranspose         = libphx.Matrix_ITranspose,
    Identity           = libphx.Matrix_Identity,
    LookAt             = libphx.Matrix_LookAt,
    LookUp             = libphx.Matrix_LookUp,
    Perspective        = libphx.Matrix_Perspective,
    RotationX          = libphx.Matrix_RotationX,
    RotationY          = libphx.Matrix_RotationY,
    RotationZ          = libphx.Matrix_RotationZ,
    Scaling            = libphx.Matrix_Scaling,
    SRT                = libphx.Matrix_SRT,
    Translation        = libphx.Matrix_Translation,
    YawPitchRoll       = libphx.Matrix_YawPitchRoll,
    MulBox             = libphx.Matrix_MulBox,
    MulDir             = libphx.Matrix_MulDir,
    MulPoint           = libphx.Matrix_MulPoint,
    MulVec             = libphx.Matrix_MulVec,
    GetForward         = libphx.Matrix_GetForward,
    GetRight           = libphx.Matrix_GetRight,
    GetUp              = libphx.Matrix_GetUp,
    GetPos             = libphx.Matrix_GetPos,
    GetRow             = libphx.Matrix_GetRow,
    FromBasis          = libphx.Matrix_FromBasis,
    FromPosRot         = libphx.Matrix_FromPosRot,
    FromPosRotScale    = libphx.Matrix_FromPosRotScale,
    FromPosBasis       = libphx.Matrix_FromPosBasis,
    FromQuat           = libphx.Matrix_FromQuat,
    ToQuat             = libphx.Matrix_ToQuat,
    Print              = libphx.Matrix_Print,
    ToString           = libphx.Matrix_ToString,
  }

  local mt = {
    __call  = function (t, ...) return Matrix_t(...) end,
  }

  if onDef_Matrix then onDef_Matrix(Matrix, mt) end
  Matrix = setmetatable(Matrix, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Matrix')
  local mt = {
    __tostring = function (self) return ffi.string(libphx.Matrix_ToString(self)) end,
    __index = {
      clone              = function (x) return Matrix_t(x) end,
      managed            = function (self) return ffi.gc(self, libphx.Matrix_Free) end,
      clone              = libphx.Matrix_Clone,
      free               = libphx.Matrix_Free,
      equal              = libphx.Matrix_Equal,
      approximatelyEqual = libphx.Matrix_ApproximatelyEqual,
      inverse            = libphx.Matrix_Inverse,
      inverseTranspose   = libphx.Matrix_InverseTranspose,
      product            = libphx.Matrix_Product,
      sum                = libphx.Matrix_Sum,
      transpose          = libphx.Matrix_Transpose,
      iInverse           = libphx.Matrix_IInverse,
      iScale             = libphx.Matrix_IScale,
      iTranspose         = libphx.Matrix_ITranspose,
      mulBox             = libphx.Matrix_MulBox,
      mulDir             = libphx.Matrix_MulDir,
      mulPoint           = libphx.Matrix_MulPoint,
      mulVec             = libphx.Matrix_MulVec,
      getForward         = libphx.Matrix_GetForward,
      getRight           = libphx.Matrix_GetRight,
      getUp              = libphx.Matrix_GetUp,
      getPos             = libphx.Matrix_GetPos,
      getRow             = libphx.Matrix_GetRow,
      toQuat             = libphx.Matrix_ToQuat,
      print              = libphx.Matrix_Print,
      toString           = libphx.Matrix_ToString,
    },
  }

  if onDef_Matrix_t then onDef_Matrix_t(t, mt) end
  Matrix_t = ffi.metatype(t, mt)
end

return Matrix
