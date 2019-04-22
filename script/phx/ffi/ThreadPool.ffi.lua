-- ThreadPool ------------------------------------------------------------------
local ThreadPool

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    ThreadPool* ThreadPool_Create (int threads);
    void        ThreadPool_Free   (ThreadPool*);
    void        ThreadPool_Launch (ThreadPool*, ThreadPoolFn, void* data);
    void        ThreadPool_Wait   (ThreadPool*);
  ]]
end

do -- Global Symbol Table
  ThreadPool = {
    Create = libphx.ThreadPool_Create,
    Free   = libphx.ThreadPool_Free,
    Launch = libphx.ThreadPool_Launch,
    Wait   = libphx.ThreadPool_Wait,
  }

  if onDef_ThreadPool then onDef_ThreadPool(ThreadPool, mt) end
  ThreadPool = setmetatable(ThreadPool, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('ThreadPool')
  local mt = {
    __index = {
      managed = function (self) return ffi.gc(self, libphx.ThreadPool_Free) end,
      free   = libphx.ThreadPool_Free,
      launch = libphx.ThreadPool_Launch,
      wait   = libphx.ThreadPool_Wait,
    },
  }

  if onDef_ThreadPool_t then onDef_ThreadPool_t(t, mt) end
  ThreadPool_t = ffi.metatype(t, mt)
end

return ThreadPool
