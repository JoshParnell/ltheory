--[[----------------------------------------------------------------------------
                  Error and debug message logging functions.
----------------------------------------------------------------------------]]--
local Log = {}

-- Hard error (non-recoverable)
function Log.Error (...)
  local pre = '\x1B[43m \x1B[0m \x1B[33;1mError: '
  local app = '\x1B[0m'
  error(pre..format(...)..app)
end

-- Recoverable issue
function Log.Warning (...)
  local pre = '\x1B[43m \x1B[0m \x1B[33;1mWarning: '
  local app = '\x1B[0m'
  print(pre..format(...)..app)
end

return Log
