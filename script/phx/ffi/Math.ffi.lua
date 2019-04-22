-- Math ------------------------------------------------------------------------
local Math

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    double Math_Bezier3       (double x, double, double, double);
    double Math_Bezier4       (double x, double, double, double, double);
    double Math_Clamp         (double x, double a, double b);
    double Math_Clamp01       (double x);
    double Math_ClampSafe     (double x, double a, double b);
    double Math_ClampUnit     (double x);
    double Math_ExpMap        (double x, double p);
    double Math_ExpMapSigned  (double x, double p);
    double Math_ExpMap1       (double x);
    double Math_ExpMap1Signed (double x);
    double Math_ExpMap2       (double x);
    double Math_ExpMap2Signed (double x);
    double Math_PowSigned     (double x, double p);
    double Math_Round         (double x);
    double Math_Sign          (double x);
  ]]
end

do -- Global Symbol Table
  Math = {
    Bezier3       = libphx.Math_Bezier3,
    Bezier4       = libphx.Math_Bezier4,
    Clamp         = libphx.Math_Clamp,
    Clamp01       = libphx.Math_Clamp01,
    ClampSafe     = libphx.Math_ClampSafe,
    ClampUnit     = libphx.Math_ClampUnit,
    ExpMap        = libphx.Math_ExpMap,
    ExpMapSigned  = libphx.Math_ExpMapSigned,
    ExpMap1       = libphx.Math_ExpMap1,
    ExpMap1Signed = libphx.Math_ExpMap1Signed,
    ExpMap2       = libphx.Math_ExpMap2,
    ExpMap2Signed = libphx.Math_ExpMap2Signed,
    PowSigned     = libphx.Math_PowSigned,
    Round         = libphx.Math_Round,
    Sign          = libphx.Math_Sign,
  }

  if onDef_Math then onDef_Math(Math, mt) end
  Math = setmetatable(Math, mt)
end

return Math
