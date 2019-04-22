function table.clear (t)
  for i = #t, 1, -1 do t[i] = nil end
end

function table.tostring (t, recurse, visited)
  if recurse == nil then recurse = false end
  visited = visited or {}

  if visited[t] then return '< already visited >' end
  visited[t] = true
  local mt = getmetatable(t)
  if mt and mt.__tostring then return mt.__tostring(t) end
  local vals = {}
  for k, v in pairs(t) do
    local combined
    if recurse and type(v) == 'table' then
      combined = format('%s = %s', k, table.tostring(v, recurse, visited))
    else
      combined = format('%s = %s', k, v)
    end
    combined = combined:split('\n')
    for i = 1, #combined do
      combined[i] = '  ' .. combined[i]
    end
    vals[#vals + 1] = table.concat(combined, '\n')
  end
  if #vals < 1 then
    return format('table @ %p', t)
  else
    return format('table @ %p :\n%s\n', t, table.concat(vals, '\n'))
  end
end
