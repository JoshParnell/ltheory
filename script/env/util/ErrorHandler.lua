local function fg (x) return 30 + x end
local function bg (x) return 40 + x end

local function style (...)
  local args = { ... }
  for i = 1, #args do args[i] = tostring(args[i]) end
  local style = table.concat(args, ';')
  return function (s)
    printf(
      '\x1B[41m \x1B[0m \x1B[%sm%s\x1B[0m',
      style,
      format('%-78s', s))
  end
end

local bright        = 1
local dim           = 2
local itallic       = 3
local underline     = 4
local inverted      = 7
local invisible     = 8
local strikethrough = 9

local black   = 0
local red     = 1
local green   = 2
local yellow  = 3
local blue    = 4
local magenta = 5
local cyan    = 6
local white   = 7

local styleRedBar      = style(bg(red))
local styleError       = style(fg(red), bright, bg(black))
local styleErrorHeader = style(fg(red), bright, underline)
local styleSource      = style(fg(white), itallic)
local styleLine        = style(fg(white), dim, bg(black))
local styleBadLine     = style(fg(white), bright, bg(black))

local linesBefore = 1
local linesAfter  = 1

local function ErrorHandler (e)
  print()
  styleErrorHeader('ERROR:')
  styleError(format('  %s', tostring(e)))

  local bottomFrame = 2
  local topFrame = bottomFrame
  while debug.getinfo(topFrame + 1) do
    topFrame = topFrame + 1
  end

  local indent = ' '
  local prevPath = nil

  for i = bottomFrame, topFrame do
    local info = debug.getinfo(i)
    local lines = nil

    if info.source:beginsWith('@') then
      local path = info.source:sub(2)
      -- TODO : Does src/ need to be changed to script?
      if path:beginsWith('./script/Main') then goto continue end
      if prevPath == path then
        styleLine('')
      else
        print()
        styleSource(format('%s', path:gsub('%./', '', 1):gsub('/', '.')))
        prevPath = path
      end

      if info.currentline and io.open(path, 'r') then
        lines = {}
        for line in io.lines(path) do lines[#lines + 1] = line end
      end

    elseif info.source == '=[C]' then
      prevPath = nil
    else
      print()
      styleSource(format('%s', 'String'))
      lines = info.source:split('\n')
      prevPath = nil
    end

    if lines and #lines >= info.currentline then
      local a = max(1, info.currentline - linesBefore)
      local b = min(#lines, info.currentline + linesAfter)
      for j = a, b do
        if j == info.currentline then
          styleBadLine(format('%s-> %-4d| %s', indent:gsub('[ |]', '-'), j, lines[j]))
        else
          styleLine(format('%s   %-4d| %s', indent, j, lines[j]))
        end
      end
    end

    -- TODO : Print locals
    if false then
      for j = 1, 128 do
        local name, value = debug.getlocal(i, j)
        if not name then break end
        print('  ', name, tostringRaw(value))
      end
    end

    ::continue::
  end
  print()
end

return ErrorHandler
