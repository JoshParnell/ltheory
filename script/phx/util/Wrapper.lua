--[[----------------------------------------------------------------------------
  Convenience mechanism for easy creation of wrappers that use ffi.metatype to
  add functionality to raw C types.
----------------------------------------------------------------------------]]--
local Type  = require('phx.util.Type')
local CType = require('phx.util.CType')

local function Wrapper (name, index, statics, opaque)
  local type
  if opaque then
    local wrapperName = format('Opaque_%s', name)
    ffi.cdef(format('typedef %s %s;', name, wrapperName));
    type = Type.Create(wrapperName, true)
  else
    type = Type.Get(name)
  end

  local indexTable = type:getIndexTable()
  for k, v in pairs(index) do
    indexTable[k] = v
  end

  if statics then
    local typeTable = type:getMetatable()
    for k, v in pairs(statics) do
      typeTable[k] = v
    end
  end

  if opaque then
    local ptr = CType.Pointer(type)
    Type.Alias(ptr.name, name)
    CType[name] = ptr
  else
    CType[name] = type
  end

  return type
end

local function wrapOpaque (name, index, statics)
  return Wrapper(name, index, statics, true)
end

local function wrapTransparent (name, index, statics)
  return Wrapper(name, index, statics, false)
end

return {
  Opaque = wrapOpaque,
  Transparent = wrapTransparent,
}
