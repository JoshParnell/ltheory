function onDef_Directory (t, mt)
  local function walkDirectory (path, root, fn, recurse)
    local dir = t.Open(path)
    if dir == nil then return end

    local subdirs = {}
    while true do
      local name = dir:getNext()
      if name == nil then break end
      name = ffi.string(name)
      local fullpath = format('%s/%s', path, name)
      if File.IsDir(fullpath) then
        local root = #root > 0 and (root .. '/' .. name) or name
        subdirs[#subdirs + 1] = { path = fullpath, root = root }
      else
        fn(root, name, fullpath)
      end
    end
    dir:close()

    if recurse then
      for i = 1, #subdirs do
        local subdir = subdirs[i]
        walkDirectory(subdir.path, subdir.root, fn)
      end
    end
  end

  -- Collects all files in a directory tree for which the given filter function
  -- returns true. The filter is called with arguments filterFn(root, filename,
  -- fullpath). Note that files are returned as full (relative) paths.
  t.Filter = function (path, filterFn, recurse)
    local recurse = recurse or true
    local elems = List()
    t.Foreach(path, function (root, filename, fullpath)
      if filterFn(root, filename, fullpath) then elems:add(fullpath) end
    end, recurse)
    return elems
  end

  -- Visit each file in the directory tree, calling fn(root, filename, fullpath)
  -- for each file found
  t.ForEach = function (path, fn, recurse)
    local recurse = recurse or true
    if path:sub(#path, #path) == '/' then path = path:sub(1, #path - 1) end
    walkDirectory(path, '', fn, recurse)
  end

  -- Return a List of all elements in the given directory
  t.List = function (path)
    local dir = t.Open(path)
    if dir == nil then error('Failed to open directory at ' .. path) end
    local elems = List()
    while true do
      local elem = dir:getNext()
      if elem == nil then break end
      elems:add(ffi.string(elem))
    end
    dir:close()
    return elems
  end
end
