-- HashGrid --------------------------------------------------------------------
local HashGrid

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    HashGrid*     HashGrid_Create     (float cellSize, uint32 cellCount);
    void          HashGrid_Free       (HashGrid*);
    HashGridElem* HashGrid_Add        (HashGrid*, void* object, Box3f const*);
    void          HashGrid_Clear      (HashGrid*);
    void          HashGrid_Remove     (HashGrid*, HashGridElem*);
    void          HashGrid_Update     (HashGrid*, HashGridElem*, Box3f const*);
    void**        HashGrid_GetResults (HashGrid*);
    int           HashGrid_QueryBox   (HashGrid*, Box3f const*);
    int           HashGrid_QueryPoint (HashGrid*, Vec3f const*);
  ]]
end

do -- Global Symbol Table
  HashGrid = {
    Create     = libphx.HashGrid_Create,
    Free       = libphx.HashGrid_Free,
    Add        = libphx.HashGrid_Add,
    Clear      = libphx.HashGrid_Clear,
    Remove     = libphx.HashGrid_Remove,
    Update     = libphx.HashGrid_Update,
    GetResults = libphx.HashGrid_GetResults,
    QueryBox   = libphx.HashGrid_QueryBox,
    QueryPoint = libphx.HashGrid_QueryPoint,
  }

  if onDef_HashGrid then onDef_HashGrid(HashGrid, mt) end
  HashGrid = setmetatable(HashGrid, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('HashGrid')
  local mt = {
    __index = {
      managed    = function (self) return ffi.gc(self, libphx.HashGrid_Free) end,
      free       = libphx.HashGrid_Free,
      add        = libphx.HashGrid_Add,
      clear      = libphx.HashGrid_Clear,
      remove     = libphx.HashGrid_Remove,
      update     = libphx.HashGrid_Update,
      getResults = libphx.HashGrid_GetResults,
      queryBox   = libphx.HashGrid_QueryBox,
      queryPoint = libphx.HashGrid_QueryPoint,
    },
  }

  if onDef_HashGrid_t then onDef_HashGrid_t(t, mt) end
  HashGrid_t = ffi.metatype(t, mt)
end

return HashGrid
