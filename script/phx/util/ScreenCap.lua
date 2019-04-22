-- TODO : Don't be an ass, Josh.
local dir = './screenshot/'

local function getPath (n)
  local time = Time.GetLocal()
  local path = dir
  local ext = '.png'
  local month = time.month
  local day = time.dayOfMonth
  if n < 10 then n = '0' .. n else n = tostring(n) end
  if month < 10 then month = '0' .. month else month = tostring(month) end
  if day < 10 then day = '0' .. day else day = tostring(day) end

  path = path .. time.year .. '-' .. month .. '-' .. day
  path = path .. ' ' .. n .. ext
  return path
end

local function screenshot ()
  local self = Tex2D.ScreenCapture()
  Directory.Create(dir)
  if not File.IsDir(dir) then
    Log.Error('Failed to create screenshot directory <%s>', dir)
  end

  local n = 0
  local path = getPath(n)
  while File.Exists(path) do
    n = n + 1
    path = getPath(n)
  end
  self:save(path)
  self:free()
  printf('Screenshot saved to <%s>', path)
end

return screenshot
