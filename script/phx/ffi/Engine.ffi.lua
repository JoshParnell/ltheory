-- Engine ----------------------------------------------------------------------
local Engine

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void   Engine_Init          (int glVersionMajor, int glVersionMinor);
    void   Engine_Free          ();
    void   Engine_Abort         ();
    int    Engine_GetBits       ();
    double Engine_GetTime       ();
    bool   Engine_IsInitialized ();
    void   Engine_Terminate     ();
    void   Engine_Update        ();
  ]]
end

do -- Global Symbol Table
  Engine = {
    Init          = libphx.Engine_Init,
    Free          = libphx.Engine_Free,
    Abort         = libphx.Engine_Abort,
    GetBits       = libphx.Engine_GetBits,
    GetTime       = libphx.Engine_GetTime,
    IsInitialized = libphx.Engine_IsInitialized,
    Terminate     = libphx.Engine_Terminate,
    Update        = libphx.Engine_Update,
  }

  if onDef_Engine then onDef_Engine(Engine, mt) end
  Engine = setmetatable(Engine, mt)
end

return Engine
