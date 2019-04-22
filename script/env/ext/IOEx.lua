io.stdout:setvbuf('no')
io.stderr:setvbuf('no')

function io.abspath (path)
  local cwd = lfs.currentdir()
  if not cwd then return path end
  if not lfs.chdir(path) then return path end
  local abs = lfs.currentdir()
  lfs.chdir(cwd)
  return abs
end

function io.exists (path)
  return lfs.attributes(path, 'mode') ~= nil
end

function io.isdir (path)
  return lfs.attributes(path, 'mode') == 'directory'
end

function io.islink (path)
  local mode = lfs.attributes(path, 'mode')
  return mode and mode ~= lfs.symlinkattributes(path, 'mode')
end

function io.listdir (root, recurse)
  local root = root:gsub('/$','')
  local files = {}
  local result, iter, dir_obj = pcall(lfs.dir, root)
  if not result then return files end
  for file in iter, dir_obj do
    if file ~= '.' and file ~= '..' then
      local path = root .. '/' .. file
      local mode = lfs.attributes(path, 'mode')
      if mode == 'file' then
        files[#files + 1] = path
      elseif recurse and mode == 'directory' and not io.islink(path) then
        local result = io.listdir(path, recurse)
        for i = 1, #result do files[#files + 1] = result[i] end
      end
    end
  end
  dir_obj:close()
  table.sort(files)
  return files
end

-- Return two lists, the first of files, the second of (immediate) subdirs
-- NOTE : Unlike io.listdir, returns name only (not path), since this function
--        is never recursive
function io.listdirex (root)
  local root = root:gsub('/$','')
  local files, dirs = {}, {}
  local result, iter, dir_obj = pcall(lfs.dir, root)
  if not result then return files, dirs end
  for file in iter, dir_obj do
    if file ~= '.' and file ~= '..' then
      local path = root .. '/' .. file
      local mode = lfs.attributes(path, 'mode')
      if mode == 'file' then
        files[#files + 1] = file
      elseif mode == 'directory' and not io.islink(path) then
        dirs[#dirs + 1] = file
      end
    end
  end
  dir_obj:close()
  table.sort(files)
  table.sort(dirs)
  return files, dirs
end

function io.mkdir (path)
  local path = path
    :gsub('^%./', '')
    :gsub('/$', '')

  local paths = path:split('/')
  local cwd = lfs.currentdir()
  for i, dir in ipairs(paths) do
    local attr = lfs.attributes(dir)
    if attr == nil then
      if not lfs.mkdir(dir) then errorf("Failed to make directory '%s'", dir) end
    elseif attr.mode ~= 'directory' then
      errorf("'%s' already exists but is not a directory", dir)
    end
    if not lfs.chdir(dir) then
      lfs.chdir(cwd)
      errorf("Failed to change directory to '%s'", dir)
    end
  end
  lfs.chdir(cwd)
end
