-- RenderTarget ----------------------------------------------------------------
local RenderTarget

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void RenderTarget_Push             (int sx, int sy);
    void RenderTarget_Pop              ();
    void RenderTarget_BindTex2D        (Tex2D*);
    void RenderTarget_BindTex2DLevel   (Tex2D*, int level);
    void RenderTarget_BindTex3D        (Tex3D*, int layer);
    void RenderTarget_BindTex3DLevel   (Tex3D*, int layer, int level);
    void RenderTarget_BindTexCube      (TexCube*, CubeFace);
    void RenderTarget_BindTexCubeLevel (TexCube*, CubeFace, int level);
    void RenderTarget_PushTex2D        (Tex2D*);
    void RenderTarget_PushTex2DLevel   (Tex2D*, int level);
    void RenderTarget_PushTex3D        (Tex3D*, int layer);
    void RenderTarget_PushTex3DLevel   (Tex3D*, int layer, int level);
  ]]
end

do -- Global Symbol Table
  RenderTarget = {
    Push             = libphx.RenderTarget_Push,
    Pop              = libphx.RenderTarget_Pop,
    BindTex2D        = libphx.RenderTarget_BindTex2D,
    BindTex2DLevel   = libphx.RenderTarget_BindTex2DLevel,
    BindTex3D        = libphx.RenderTarget_BindTex3D,
    BindTex3DLevel   = libphx.RenderTarget_BindTex3DLevel,
    BindTexCube      = libphx.RenderTarget_BindTexCube,
    BindTexCubeLevel = libphx.RenderTarget_BindTexCubeLevel,
    PushTex2D        = libphx.RenderTarget_PushTex2D,
    PushTex2DLevel   = libphx.RenderTarget_PushTex2DLevel,
    PushTex3D        = libphx.RenderTarget_PushTex3D,
    PushTex3DLevel   = libphx.RenderTarget_PushTex3DLevel,
  }

  if onDef_RenderTarget then onDef_RenderTarget(RenderTarget, mt) end
  RenderTarget = setmetatable(RenderTarget, mt)
end

return RenderTarget
