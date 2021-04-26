PHX = {}

PHX.Ext  = requireAll('ffiext')
PHX.Lib  = require('ffi.libphx')

PHX.FFI  = requireAll('ffi')
Namespace.Inline(PHX.FFI, 'PHX.FFI')
Namespace.Inject(PHX, 'PHX', PHX.FFI, 'PHX.FFI')

PHX.Util = requireAll('phx.util')
Namespace.Inline(PHX.Util, 'PHX.Util')

-- Builtins registered with Type library
local builtins = {
  'int8_t',
  'int16_t',
  'int32_t',
  'int64_t',
  'uint8_t',
  'uint16_t',
  'uint32_t',
  'uint64_t',
  'float',
  'double',
  'cstr',
}

-- Typedefs registered with Type library
local lua_typedefs = {
  { 'int8_t',   'Int8'    },
  { 'int16_t',  'Int16'   },
  { 'int32_t',  'Int32'   },
  { 'int64_t',  'Int64'   },
  { 'uint8_t',  'Uint8'   },
  { 'uint16_t', 'Uint16'  },
  { 'uint32_t', 'Uint32'  },
  { 'uint64_t', 'Uint64'  },
  { 'float',    'Float32' },
  { 'double',   'Float64' },
  { 'cstr',     'String'  },
}

for i = 1, #builtins do
  Type.Create(builtins[i], true)
end

for i = 1, #lua_typedefs do
  local src = lua_typedefs[i][1]
  local dst = lua_typedefs[i][2]
  Type.Alias(src, dst)
  CType[dst] = Type.Get(src)
end

for i = 1, #PHX.Lib.Opaques do
  local name = PHX.Lib.Opaques[i]
  local wrapperName = format('Opaque_%s', name)
  ffi.cdef(format('typedef %s %s;', name, wrapperName));
  local type = Type.Create(wrapperName, true)
  local ptr  = CType.Pointer(type)
  Type.Alias(ptr.name, name)
  CType[name] = ptr
end

for i = 1, #PHX.Lib.Structs do
  local name = PHX.Lib.Structs[i]
  local type = Type.Create(name, true)
  CType[name] = type
end
