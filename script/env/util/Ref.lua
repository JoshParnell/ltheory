--[[----------------------------------------------------------------------------
  Provides a safe mechanism for storing 'pointers' to Lua objects in C structs
  by converting them to integer IDs. These IDs are indices into a global
  reference table, which provides both an index->object mapping, as well as the
  guarantee that the Lua object is still reachable and therefore will not be
  GCd while someone is holding an integer ID.

  Also implements a reference-counting mechanism so that only one ID is assigned
  to a Lua object at any given time.
----------------------------------------------------------------------------]]--

local refData = {}
local refTable = {}
local freeList = {}
local nextID = 1

function IncRef (t)
  local data = refData[t]
  if data then
    data.refCount = data.refCount + 1
    return data.id
  end

  local id
  if #freeList > 0 then
    id = freeList[#freeList]
    freeList[#freeList] = nil
  else
    id = nextID
    nextID = nextID + 1
  end
  refTable[id] = t

  refData[t] = {
    refCount = 1,
    id = id
  }
  return id
end

function Deref (id)
  return refTable[id]
end

function DecRef (id)
  local t = refTable[id]
  local data = refData[t]
  data.refCount = data.refCount - 1
  assert(data.refCount >= 0)
  assert(data.id == id)

  if data.refCount == 0 then
    refTable[id] = nil
    freeList[#freeList + 1] = id
    refData[t] = nil
  end
end
