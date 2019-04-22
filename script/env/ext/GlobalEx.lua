if __debug__      == nil then __debug__      = false end
if __checklevel__ == nil then __checklevel__ = 0     end
if __embedded__   == nil then __embedded__   = false end

ffi = require('ffi')
jit = require('jit')
for k, v in pairs(math) do
  if type(v) == 'function' then
    _G[k] = v
  end
end

insert = table.insert
remove = table.remove
format = string.format
join = table.concat

function printf(...) print(format(...)) end
function trace() print(debug.traceback()) end
function traceFn()
  local info = debug.getinfo(2, 'nS')
  local file = info.short_src:match('[\\/]([^\\/%.]*)%.')
  printf('%s.%s', file, info.name)
end

--[[----------------------------------------------------------------------------
  Provides a more-detailed tostring function that automatically retrieves debug
  information for function objects and converts C strings. Note that since
  tostring() is used for print(), using this function to globally replace the
  default tostring will also replace the default print behavior.
----------------------------------------------------------------------------]]--
_tostring = tostring
function tostring (x)
  local result
  if type(x) == 'function' then
    local info = debug.getinfo(x)
    if info.what == 'Lua' then
      if info.linedefined == -1 then
        result = format('[Lua function @ %p %s]', x, info.short_src)
      else
        result = format('[Lua function @ %p -- %s:%d]', x, info.short_src, info.linedefined)
      end
    else
      result = format('[C function @ %p]', x)
    end
  elseif type(x) == 'cdata' then
    if x == nil then
      result = '(nullptr)'
    else
      if ffi.istype('char const*', x) then
        result = format('"%s"', ffi.string(x))
      end
    end
  end
  return result or _tostring(x)
end

require('env.ext.IOEx')
require('env.ext.StringEx')
local Log = require('env.util.Log')

local requireAllCache = {}

function requireAll (path)
  -- NOTE : It may be more idiomatic to use package.searchers to handle this
  if requireAllCache[path] then return requireAllCache[path] end
  local pathWithSlashes = path:gsub('%.', '/')

  local dir
  local templates = package.path:split(';')
  for i = 1, #templates do
    local maybeDir = templates[i]
    if maybeDir ~= '' then
      maybeDir = maybeDir:gsub('[^/\\]*%?[^/\\]*$', '')
      maybeDir = maybeDir:gsub('%?', pathWithSlashes)
      maybeDir = maybeDir..pathWithSlashes..'/'
      if io.exists(maybeDir) and io.isdir(maybeDir) then
        dir = maybeDir
        break
      end
    end
  end
  if not dir then Log.Error('Failed to open directory <%s>', path) end

  local results = {}
  local files, dirs = io.listdirex(dir)
  for i = 1, #dirs do
    local dirName = dirs[i]
    results[dirName] = requireAll(path..'.'..dirName)
  end

  for i = 1, #files do
    local fileName = files[i]
    fileName = fileName:gsub('%..*$', '')
    results[fileName] = require(path..'.'..fileName)
  end

  requireAllCache[path] = results
  return results
end
