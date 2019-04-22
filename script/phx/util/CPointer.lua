local Type  = require('phx.util.Type')
local cache = {}

local function CreateCPointer (ElemT)
  local T = Type.Create('_ptr_' .. ElemT.name, true)
  T.niceName = ElemT.name .. '*'
  return T
end

local function CPointer (ElemT)
  if cache[ElemT.name] then return cache[ElemT.name] end
  local T = CreateCPointer(ElemT)
  cache[ElemT.name] = T
  return T
end

return CPointer
