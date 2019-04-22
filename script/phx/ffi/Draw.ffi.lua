-- Draw ------------------------------------------------------------------------
local Draw

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void Draw_Clear        (float r, float g, float b, float a);
    void Draw_ClearDepth   (float d);
    void Draw_Color        (float r, float g, float b, float a);
    void Draw_Flush        ();
    void Draw_LineWidth    (float width);
    void Draw_PointSize    (float size);
    void Draw_PushAlpha    (float a);
    void Draw_PopAlpha     ();
    void Draw_SmoothLines  (bool);
    void Draw_SmoothPoints (bool);
    void Draw_Border       (float s, float x, float y, float w, float h);
    void Draw_Line         (float x1, float y1, float x2, float y2);
    void Draw_Point        (float x, float y);
    void Draw_Poly         (Vec2f const* points, int count);
    void Draw_Quad         (Vec2f const* p1, Vec2f const* p2, Vec2f const* p3, Vec2f const* p4);
    void Draw_Rect         (float x, float y, float sx, float sy);
    void Draw_Tri          (Vec2f const* p1, Vec2f const* p2, Vec2f const* p3);
    void Draw_Axes         (Vec3f const* pos, Vec3f const* x, Vec3f const* y, Vec3f const* z, float scale, float alpha);
    void Draw_Box3         (Box3f const* box);
    void Draw_Line3        (Vec3f const* p1, Vec3f const* p2);
    void Draw_Plane        (Vec3f const* p, Vec3f const* n, float scale);
    void Draw_Point3       (float x, float y, float z);
    void Draw_Poly3        (Vec3f const* points, int count);
    void Draw_Quad3        (Vec3f const* p1, Vec3f const* p2, Vec3f const* p3, Vec3f const* p4);
    void Draw_Sphere       (Vec3f const* p, float r);
    void Draw_Tri3         (Vec3f const* p1, Vec3f const* p2, Vec3f const* p3);
  ]]
end

do -- Global Symbol Table
  Draw = {
    Clear        = libphx.Draw_Clear,
    ClearDepth   = libphx.Draw_ClearDepth,
    Color        = libphx.Draw_Color,
    Flush        = libphx.Draw_Flush,
    LineWidth    = libphx.Draw_LineWidth,
    PointSize    = libphx.Draw_PointSize,
    PushAlpha    = libphx.Draw_PushAlpha,
    PopAlpha     = libphx.Draw_PopAlpha,
    SmoothLines  = libphx.Draw_SmoothLines,
    SmoothPoints = libphx.Draw_SmoothPoints,
    Border       = libphx.Draw_Border,
    Line         = libphx.Draw_Line,
    Point        = libphx.Draw_Point,
    Poly         = libphx.Draw_Poly,
    Quad         = libphx.Draw_Quad,
    Rect         = libphx.Draw_Rect,
    Tri          = libphx.Draw_Tri,
    Axes         = libphx.Draw_Axes,
    Box3         = libphx.Draw_Box3,
    Line3        = libphx.Draw_Line3,
    Plane        = libphx.Draw_Plane,
    Point3       = libphx.Draw_Point3,
    Poly3        = libphx.Draw_Poly3,
    Quad3        = libphx.Draw_Quad3,
    Sphere       = libphx.Draw_Sphere,
    Tri3         = libphx.Draw_Tri3,
  }

  if onDef_Draw then onDef_Draw(Draw, mt) end
  Draw = setmetatable(Draw, mt)
end

return Draw
