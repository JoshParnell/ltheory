-- DepthTest -------------------------------------------------------------------
local DepthTest

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    void DepthTest_Pop          ();
    void DepthTest_Push         (bool);
    void DepthTest_PushDisabled ();
    void DepthTest_PushEnabled  ();
  ]]
end

do -- Global Symbol Table
  DepthTest = {
    Pop          = libphx.DepthTest_Pop,
    Push         = libphx.DepthTest_Push,
    PushDisabled = libphx.DepthTest_PushDisabled,
    PushEnabled  = libphx.DepthTest_PushEnabled,
  }

  if onDef_DepthTest then onDef_DepthTest(DepthTest, mt) end
  DepthTest = setmetatable(DepthTest, mt)
end

return DepthTest
