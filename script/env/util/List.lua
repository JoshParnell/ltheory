--[[----------------------------------------------------------------------------
  A growable linear list. Little more than a convenience wrapper over tables.
  Includes some useful generic algorithms for common linear list operations.
----------------------------------------------------------------------------]]--
local List = class(function (self, ...)
  local args = { ... }
  for i = 1, #args do
    self[i] = args[i]
  end
end)

function List:add              (elem)             end
function List:append           (elem)             end
function List:argMax           (scoreFn)          end
function List:argMin           (scoreFn)          end
function List:clear            ()                 end
function List:clone            ()                 end
function List:choose           (rng)              end
function List:contains         (elem)             end
function List:count            (predicateFn)      end
function List:difference       (other)            end
function List:filter           (predicateFn)      end
function List:ifilter          (predicateFn)      end
function List:find             (value)            end
function List:findAllWhere     (predicateFn)      end
function List:findWhere        (predicateFn)      end
function List:foreach          (fn)               end
function List:get              (i)                end
function List:getWrapped       (i)                end
function List:getNext          (cur)              end
function List:getPrev          (cur)              end
function List:iMerge           (other)            end
function List:insert           (i, elem)          end
function List:intersection     (other)            end
function List:join             (sep, first, last) end
function List:last             ()                 end
function List:map              (mapFn)            end
function List:max              ()                 end
function List:min              ()                 end
function List:match            (predicateFn)      end
function List:matchAll         (predicateFn)      end
function List:matchLast        (predicateFn)      end
function List:maxGiven         (lessFn)           end
function List:merge            (other)            end
function List:minGiven         (lessFn)           end
function List:moveFromIToFront (i)                end
function List:moveFromIToBack  (i)                end
function List:moveToFront      (elem)             end
function List:moveToBack       (elem)             end
function List:peek             ()                 end
function List:pop              ()                 end
function List:push             (elem)             end
function List:prepend          (elem)             end
function List:reduce           (reduceFn, start)  end
function List:remove           (elem)             end
function List:removeFast       (elem)             end
function List:removeSet        (elems)            end
function List:removeAt         (index)            end
function List:removeAtFast     (index)            end
function List:removeWhere      (predicateFn)      end
function List:removeFastWhere  (predicateFn)      end
function List:reverse          ()                 end
function List:shuffle          (rng)              end
function List:sort             (lessFn)           end
function List:sum              ()                 end
function List:swap             (i, j)             end
function List:transform        (transformFn)      end
function List:union            (other)            end
function List:__tostring       ()                 end

--------------------------------------------------------------------------------

-- Append an element to the end of the list
function List:add (elem)
  self[#self + 1] = elem
  return self
end

-- Append the given element to the end of the list
function List:append (elem)
  self[#self + 1] = elem
  return self
end

-- Return the element that maximizes fn, as well as said score
function List:argMax (scoreFn)
  if #self == 0 then return nil, nil end
  local x = self[1]
  local y = scoreFn(self[1])
  for i = 2, #self do
    local ly = scoreFn(self[i])
    if y < ly then
      x = self[i]
      y = ly
    end
  end
  return x, y
end

-- Return the element that minimizes fn, as well as said score
function List:argMin (scoreFn)
  if #self == 0 then return nil, nil end
  local x = self[1]
  local y = scoreFn(self[1])
  for i = 2, #self do
    local ly = scoreFn(self[i])
    if ly < y then
      x = self[i]
      y = ly
    end
  end
  return x, y
end

-- Clear the list (without re-allocating memory for a new list)
function List:clear ()
  for i = #self, 1, -1 do self[i] = nil end
  return self
end

-- Return a shallow copy of the list
function List:clone ()
  local clone = List()
  for i = 1, #self do clone[i] = self[i] end
  return clone
end

-- Return a random element using rng as a random source
function List:choose (rng)
  return self[rng:getInt(1, #self)]
end

-- Return whether or not elem is in the list
function List:contains (elem)
  for i = 1, #self do
    if self[i] == elem then return true end
  end
  return false
end

-- Return the number of elements for which predicateFn is true
function List:count (predicateFn)
  local x = 0
  for i = 1, #self do if predicateFn(self[i]) then x = x + 1 end end
  return x
end

-- Return elements that appear in this list but not other
function List:difference (other)
  local results = self:clone()
  results:removeSetFast(other)
  return results
end

-- Return a new list of elems for which predicateFn is true
function List:filter (predicateFn)
  local results = List()
  for i = 1, #self do if predicateFn(self[i]) then results:add(self[i]) end end
  return results
end

-- Remove all elems for which predicateFn is false
function List:ifilter (predicateFn)
  for i = #self, 1, -1 do
    if not predicateFn(self[i]) then self:removeAt(i) end
  end
  return self
end

-- Return the first index at which value occurs or nil if not found
function List:find (value)
  for i = 1, #self do if self[i] == value then return i end end
  return nil
end

-- Return all indices for which predicateFn is true
function List:findAllWhere (predicateFn)
  local results = List()
  for i = 1, #self do
    if predicateFn(self[i]) then results:append(i) end
  end
  return results
end

-- Return the first index for which predicateFn is true or nil if not found
function List:findWhere (predicateFn)
  for i = 1, #self do if predicateFn(self[i]) then return i end end
  return nil
end

-- Apply fn to each element
function List:foreach (fn)
  for i = 1, #self do fn(self[i]) end
  return self
end

-- Get the element at index i
function List:get (i)
  return self[i]
end

-- Get the element at index i, wrapping the index if it is out of bounds
function List:getWrapped (i)
  return self[Math.Wrap(i, 1, #self)]
end

-- Return the element immediately following the given one or nil
function List:getNext (cur)
  if #self == 0 then return nil end

  local next = 1
  for i = 2, #self do
    if self[i - 1] == cur then
      next = i
      break
    end
  end
  return self[next]
end

-- Return the element immediately preceeding the given one or nil
function List:getPrev (cur)
  if #self == 0 then return nil end

  local prev = #self
  for i = #self - 1, 1, -1 do
    if self[i + 1] == cur then
      prev = i
      break
    end
  end
  return self[prev]
end

-- Shallow copies all elements of other into this list
function List:iMerge (other)
  for i = 1, #other do self[#self + 1] = other[i] end
  return self
end

function List:insert (i, elem)
  table.insert(self, i, elem)
  return self
end

-- Return elements that appear in both this list and other
function List:intersection (other)
  local results = List()
  for i = 1, #self do
    if other:contains(self[i]) then results:append(self[i]) end
  end
  return results
end

-- Concatenate all elements of the list into a string with an optional separator
-- A first and last index can optionally be specified to concatenate only a
-- sub-range of the list
function List:join (sep, first, last)
  return table.concat(self, sep, first, last)
end

-- Return the last element of the list or nil if empty
function List:last ()
  return self[#self]
end

-- Mutate each element of the list using mapFn
function List:map (mapFn)
  for i = 1, #self do
    self[i] = mapFn(self[i])
  end
end

-- Return the maximal element
function List:max ()
  if #self == 0 then return nil end
  local x = self[1]
  for i = 2, #self do if x < self[i] then x = self[i] end end
  return x
end

-- Return the minimal element
function List:min ()
  if #self == 0 then return nil end
  local x = self[1]
  for i = 2, #self do if self[i] < x then x = self[i] end end
  return x
end

-- Return all elements for which predicateFn is true
function List:matchAll (predicateFn)
  local results = List()
  for i = 1, #self do
    if predicateFn(self[i]) then results:append(self[i]) end
  end
  return results
end

-- Return the first element for which predicateFn is true
function List:match (predicateFn)
  for i = 1, #self do
    if predicateFn(self[i]) then return self[i] end
  end
  return nil
end

-- Return the last element for which predicateFn is true
function List:matchLast (predicateFn)
  for i = #self, 1, -1 do
    if predicateFn(self[i]) then return self[i] end
  end
  return nil
end

-- Return the maximal element given lessFn as a comparator
function List:maxGiven (lessFn)
  if #self == 0 then return nil end
  local x = self[1]
  for i = 2, #self do if lessFn(x, self[i]) then x = self[i] end end
  return x
end

-- Return a new table containing the values of this table and the provided one
function List:merge (other)
  local clone = List()
  for i = 1, #self  do clone[#clone + 1] = self[i]  end
  for i = 1, #other do clone[#clone + 1] = other[i] end
  return clone
end

-- Return the minimal element given lessFn as a comparator
function List:minGiven (lessFn)
  if #self == 0 then return nil end
  local x = self[1]
  for i = 2, #self do if lessFn(self[i], x) then x = self[i] end end
  return x
end

-- Move the element at position i to the front of the list
function List:moveFromIToFront (i)
  local item = table.remove(self, i)
  table.insert(self, 1, item)
  return self
end

-- Move the element at position i to the back of the list
function List:moveFromIToBack (i)
  local item = table.remove(self, i)
  self[#self + 1] = item
  return self
end

-- Move the provided element to the front of the list
function List:moveToFront (elem)
  for i = 1, #self do
    if self[i] == elem then self:moveFromIToFront(i) break end
  end
  return self
end

-- Move the provided element to the back of the list
function List:moveToBack (elem)
  for i = 1, #self do
    if self[i] == elem then self:moveFromIToBack(i) break end
  end
  return self
end

-- Return the last element of the list or nil if empty
function List:peek ()
  return self[#self]
end

-- Pop the last element of the list off and return it
function List:pop ()
  return table.remove(self)
end

-- Push the element onto the end of the list
function List:push (elem)
  self[#self + 1] = elem
  return self
end

-- Prepend the given element to the beginning of the list
function List:prepend (elem)
  table.insert(self, 1, elem)
  return self
end

-- Return the reduction of elements using reduceFn as the reductor and start
-- as the initial value
function List:reduce (reduceFn, start)
  local x = start
  for i = 1, #self do x = reduceFn(x, self[i]) end
  return x
end

-- Remove the first occurrence of elem from the list
function List:remove (elem)
  for i = 1, #self do
    if self[i] == elem then table.remove(self, i) break end
  end
  return self
end

-- Remove the first occurrence of elem from the list, putting the last element
-- of the list in its slot
function List:removeFast (elem)
  for i = 1, #self do
    if self[i] == elem then
      self[i]     = self[#self]
      self[#self] = nil
      break
    end
  end
  return self
end

-- Remove the first occurrence of all elems from the list
function List:removeSet (elems)
  for i = 1, #elems do
    self:remove(elems[i])
  end
  return self
end

-- Remove the last occurrence of all elems from the list, putting the last
-- element of the list in its slot
function List:removeSetFast (elems)
  for i = #elems, 1, -1 do
    self:removeFast(elems[i])
  end
  return self
end

-- Remove the element at index
function List:removeAt (index)
  table.remove(self, index)
end

-- Remove the element at index, putting the list element of the list in its slot
function List:removeAtFast (index)
  self[index] = self[#self]
  self[#self] = nil
end

-- Remove each elem for which predicateFn is true
function List:removeWhere (predicateFn)
  for i = #self, 1, -1 do
    if predicateFn(self[i]) then self:removeAt(i) end
  end
  return self
end

-- Remove each elem for which predicateFn is true without preserving order
function List:removeFastWhere (predicateFn)
  for i = #self, 1, -1 do
    if predicateFn(self[i]) then self:removeAtFast(i) end
  end
  return self
end

-- Reverse the order of elements
function List:reverse ()
  for i = 1, #self / 2 do
    local t = self[i]
    self[i] = self[#self - i + 1]
    self[#self - i + 1] = t
  end
  return self
end

-- Shuffle the order of elements using rng as a random source
function List:shuffle (rng)
  for i = 1, #self - 1 do
    local j = rng:getInt(i, #self)
    local t = self[i]
    self[i] = self[j]
    self[j] = t
  end
  return self
end

-- Sort the elements according to the given < comparator
function List:sort (lessFn)
  table.sort(self, lessFn)
  return self
end

-- Return the sum of elements
function List:sum ()
  local x = 0
  for i = 1, #self do x = x + self[i] end
  return x
end

-- Swap the elements at positions i and j
function List:swap (i, j)
  self[i], self[j] = self[j], self[i]
  return self
end

-- Transform each element in the list by transformFn
function List:transform (transformFn)
  for i = 1, #self do self[i] = transformFn(self[i]) end
  return self
end

-- Return elements that appear in either this list or other (without duplication)
function List:union (other)
  local results = self:clone()
  for i = 1, #other do
    if not results:contains(other[i]) then
      results:append(other[i])
    end
  end
  return results
end

-- Recursively stringize the list
function List:__tostring ()
  local elems = {}
  for i = 1, #self do
    table.insert(elems, tostring(self[i]))
  end
  return '[' .. table.concat(elems, ', ') .. ']'
end

return List
