-- Maps pointers to numbers so that true pointers can be used as keys
-- NOTE : Emphasis on *true* (i.e. 48-bit under x64) pointers! Will NOT work on
--        arbitrary 64-bit values (use guidToKey below)
function ptrToKey (p)
  return tonumber(ffi.cast('intptr_t', ffi.cast('void*', p)))
end

local u64buff = ffi.new('uint64_t[1]')

-- Maps full 64-bit uints to lua strings for use as table keys
-- NOTE : Obviously less efficient than ptrToKey due to new GCd string object
function guidToKey (guid)
  u64buff[0] = guid
  return ffi.string(u64buff, 8) -- 64 bits
end
