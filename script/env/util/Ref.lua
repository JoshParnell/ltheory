--[[----------------------------------------------------------------------------
  TODO : Update this highly-questionable description ... ? These are obviously
         strong references (!) Also, ffi calls are JITed, not stitched.
         Stitched is for lua_CFunctions.

  [Experimental]

  Description:
  Provides weak reference functionality in Lua.

  Context:
  Using wrappers to call into luaL_ref/unref is an alternative if we are ok with
  strong references, but this pure lua implementation is faster than calling
  into C would be.

  Calling into C requires trace stitching. LuaJIT pushes a continuation on the
  stack, returns to the interpreter to call the C function, then uses the
  continuation to resume JITing once the function returns.

  This process is faster than falling back to the interpreter for the entire
  path, but it's still not particularly fast. Thus, calling into the engine
  extremely frequently has a noticeable negative performance impact.

  One place where that manifests is having frequently accessed components
  implemented in the engine, such as Entity.children in a CMultiArray.

  Notes:
  Initial allocation & reservation of a fixed number of free elements has been
  shown to be detrimental to performance.
----------------------------------------------------------------------------]]--

local refTable = {}
local freeList = {}
local nextID = 1

function RefCreate (t)
  if #freeList > 0 then
    local v = freeList[#freeList]
    freeList[#freeList] = nil
    refTable[v] = t
    return v
  else
    local v = nextID
    nextID = nextID + 1
    refTable[v] = t
    return v
  end
end

function RefGet (id)
  return refTable[id]
end

function RefDelete (id)
  refTable[id] = nil
  freeList[#freeList + 1] = id
end
