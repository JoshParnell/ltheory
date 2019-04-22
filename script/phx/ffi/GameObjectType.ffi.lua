-- GameObjectType --------------------------------------------------------------
local GameObjectType

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    GameObjectType* GameObjectType_Create ();
  ]]
end

do -- Global Symbol Table
  GameObjectType = {
    Create = libphx.GameObjectType_Create,
  }

  if onDef_GameObjectType then onDef_GameObjectType(GameObjectType, mt) end
  GameObjectType = setmetatable(GameObjectType, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('GameObjectType')
  local mt = {
    __index = {
    },
  }

  if onDef_GameObjectType_t then onDef_GameObjectType_t(t, mt) end
  GameObjectType_t = ffi.metatype(t, mt)
end

return GameObjectType
