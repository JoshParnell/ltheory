--[[----------------------------------------------------------------------------
  Hooks the global table's __index and __newindex metamethods to prevent
  (presumably-accidental) reading from or writing to global variables.
----------------------------------------------------------------------------]]--

local GlobalRestrict = {}

local GlobalMT = {}
function GlobalMT.__index (t, k)
  Log.Error("Attempt to access undefined global variable '%s'", k)
end

function GlobalMT.__newindex (t, k, v)
  Log.Error("Attempt to create global variable '%s'", k)
end

function GlobalRestrict.On ()
  setmetatable(_G, GlobalMT)
end

function GlobalRestrict.Off ()
  setmetatable(_G, nil)
end

return GlobalRestrict

-- TODO : When attempting to access a non-existent global variable this script
--        ends up on the top of the stack and we don't get a proper line number
--        for the error.
