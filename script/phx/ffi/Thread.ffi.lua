-- Thread ----------------------------------------------------------------------
local Thread

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Thread* Thread_Create (cstr name, ThreadFn, void* data);
    void    Thread_Detach (Thread*);
    void    Thread_Sleep  (uint ms);
    int     Thread_Wait   (Thread*);
  ]]
end

do -- Global Symbol Table
  Thread = {
    Create = libphx.Thread_Create,
    Detach = libphx.Thread_Detach,
    Sleep  = libphx.Thread_Sleep,
    Wait   = libphx.Thread_Wait,
  }

  if onDef_Thread then onDef_Thread(Thread, mt) end
  Thread = setmetatable(Thread, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Thread')
  local mt = {
    __index = {
      detach = libphx.Thread_Detach,
      wait   = libphx.Thread_Wait,
    },
  }

  if onDef_Thread_t then onDef_Thread_t(t, mt) end
  Thread_t = ffi.metatype(t, mt)
end

return Thread
