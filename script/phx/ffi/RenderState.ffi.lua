-- RenderState -----------------------------------------------------------------
local RenderState

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void RenderState_PushAllDefaults   ();
    void RenderState_PushBlendMode     (BlendMode);
    void RenderState_PushCullFace      (CullFace);
    void RenderState_PushDepthTest     (bool);
    void RenderState_PushDepthWritable (bool);
    void RenderState_PushWireframe     (bool);
    void RenderState_PopAll            ();
    void RenderState_PopBlendMode      ();
    void RenderState_PopCullFace       ();
    void RenderState_PopDepthTest      ();
    void RenderState_PopDepthWritable  ();
    void RenderState_PopWireframe      ();
  ]]
end

do -- Global Symbol Table
  RenderState = {
    PushAllDefaults   = libphx.RenderState_PushAllDefaults,
    PushBlendMode     = libphx.RenderState_PushBlendMode,
    PushCullFace      = libphx.RenderState_PushCullFace,
    PushDepthTest     = libphx.RenderState_PushDepthTest,
    PushDepthWritable = libphx.RenderState_PushDepthWritable,
    PushWireframe     = libphx.RenderState_PushWireframe,
    PopAll            = libphx.RenderState_PopAll,
    PopBlendMode      = libphx.RenderState_PopBlendMode,
    PopCullFace       = libphx.RenderState_PopCullFace,
    PopDepthTest      = libphx.RenderState_PopDepthTest,
    PopDepthWritable  = libphx.RenderState_PopDepthWritable,
    PopWireframe      = libphx.RenderState_PopWireframe,
  }

  if onDef_RenderState then onDef_RenderState(RenderState, mt) end
  RenderState = setmetatable(RenderState, mt)
end

return RenderState
