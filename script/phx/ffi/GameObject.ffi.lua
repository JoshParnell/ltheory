-- GameObject ------------------------------------------------------------------
local GameObject

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    GameObject* GameObject_Create ();
    void        GameObject_Free   (GameObject*);
  ]]
end

do -- Global Symbol Table
  GameObject = {
    Create = libphx.GameObject_Create,
    Free   = libphx.GameObject_Free,
  }

  if onDef_GameObject then onDef_GameObject(GameObject, mt) end
  GameObject = setmetatable(GameObject, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('GameObject')
  local mt = {
    __index = {
      managed = function (self) return ffi.gc(self, libphx.GameObject_Free) end,
      free   = libphx.GameObject_Free,
    },
  }

  if onDef_GameObject_t then onDef_GameObject_t(t, mt) end
  GameObject_t = ffi.metatype(t, mt)
end

return GameObject
