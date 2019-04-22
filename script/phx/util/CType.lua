local CArray     = require('phx.util.CArray')
local CPointer   = require('phx.util.CPointer')
local CReference = require('phx.util.CReference')
local CStruct    = require('phx.util.CStruct')
local Type       = require('phx.util.Type')

local CType = {}

function CType.Array (T)
  return CArray(T)
end

function CType.Pointer (T)
  return CPointer(T)
end

function CType.Reference (T)
  return CReference(T)
end

function CType.Struct (name)
  local self = CStruct(name)
  CType[name] = self
  return self
end

function CType.Subclass (name, parent)
  local self = CStruct(name)
  self.parent = parent
  for i = 1, #parent.fields do
    self:add(parent.fields[i].T, parent.fields[i].name)
  end
  CType[name] = self
  for i = 1, #parent.onSubclass do
    parent.onSubclass[i](parent, self)
  end
  return self
end

CType.MultiArray   = require('phx.util.CMultiArray')
CType.MultiPointer = require('phx.util.CMultiPointer')

return CType
