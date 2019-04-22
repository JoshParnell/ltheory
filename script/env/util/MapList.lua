--[[----------------------------------------------------------------------------
  A combination map (hash-only table) / list (array-only table) pair container,
  useful for keeping track of a list of items that require both fast iteration
  (using the list) and fast lookup (using the map). Also provides a newindex
  hook for convenience (such that you need only provide a constructor function
  that generates the correct value for a key; called automatically when the
  key is not found).

  NOTE : For convenience, the MapList itself is the list part, hence can be
         iterated over in the usual manner for lists. The map and constructor
         are stored in the hash part of the MapList. :get is for *map lookup*,
         not for indexing (indexing is, again, simply mapList[i]).
----------------------------------------------------------------------------]]--
local MapList = {}

local function mapListGet (self, k)
  local v = self.__map[k]
  if v then return v end
  v = self.__constructor(k)
  self.__map[k] = v
  self[#self + 1] = v
  return v
end

local function MapList (constructor)
  return setmetatable({
    get = mapListGet,
    __constructor = constructor,
    __map = {},
  }, MapList)
end

return MapList
