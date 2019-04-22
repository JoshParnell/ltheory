local string = getmetatable('').__index

function string.__mod (fmt, args)
  if type(args) == 'table' then
    return string.format(fmt, unpack(args))
  else
    return string.format(fmt, args)
  end
end

function string.beginsWith (a, b)
  local la, lb = #a, #b
  if la < lb then return false end
  if lb < 1 then return true end
  return string.sub(a, 0, lb) == b
end

function string.capitalize (s)
  return s:sub(1, 1):upper() .. s:sub(2)
end

function string.contains (a, b)
  return string.match(a, b) ~= nil
end

function string.endsWith (a, b)
  local la, lb = #a, #b
  if la < lb then return false end
  if lb < 1 then return true end
  return string.sub(a, -lb) == b
end

-- NOTE : This is a work-in-progress! Probably needs lots more escapes to be bulletproof.
function string.escape (str)
  local result = str
    :gsub('\\', '\\\\')
    :gsub('\n', '\\n')
    :gsub('\r', '')
    :gsub('\t','\\t')
    :gsub('"','\\"')
  return result
end

function string.indent (s, prefix)
  local lines = s:split('\n')
  for i = 1, #lines do
    lines[i] = prefix .. lines[i]
  end
  return table.concat(lines, '\n')
end

function string.join (delim, elems)
  return table.concat(elems, delim)
end

function string.parse (str, format, fn, ...)
  local args = {...}
  return string.gsub(str, format, function (...) fn(unpack(args), ...) return '' end)
end

function string.replace (str, src, dst)
  return string.gsub(str, src, dst)
end

function string.split (str, delim)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(str, delim, from)
  while delim_from do
    table.insert(result, string.sub(str, from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find(str, delim, from)
  end
  table.insert(result, string.sub(str, from))
  return result
end

function string.splitPair (str, delim)
  local first, last = string.find(self, delim)
  if not first then return nil end
  return string.sub(str, 0, first - 1), string.sub(str, last + 1)
end

function string.stripPrefix (str, pre)
  local index = 1
  local l1 = str:len()
  local l2 = pre:len()
  while index <= l1 and index <= l2 and str[index] == pre[index] do
    index = index + 1
  end
  return string.sub(str, index)
end

function string.stripTo (str, pattern)
  local first, last = string.find(str, pattern)
  if not last then return nil end
  return string.sub(str, last + 1)
end
