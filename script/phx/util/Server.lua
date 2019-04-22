local Server = {}
Server.__index = Server

local buffSize = 1024

function Server:__gc ()
  Memory.Free(self.buffer)
  self.socket:free()
end

function Server:bind (port)
  self.socket:bind(port)
end

function Server:send (dst, ptr)
  if #text > buffSize then error('Message is too long for internal buffer') end
  Memory.MemCopy(self.buff, ffi.cast('void const*', text), #text)
  self.socket:setAddress(dst)
  self.socket:sendTo(self.buff, #text)
end

function Server:sendBinary (dst, data, size)
  self.socket:setAddress(dst)
  self.socket:sendTo(data, size)
end

function Server:update ()
  while true do
    local bytes = self.socket:receiveFrom(self.buff, buffSize)
    if bytes <= 0 then break end
    self.handler:onReceive(self.socket:getAddress(), self.buff, bytes)
  end
end

local function CreateServer (handler)
  local self = setmetatable({
    handler = handler,
  }, Server)

  self.socket = Socket.Create(SocketType.UDP)
  self.buff = ffi.C.malloc(buffSize)
  return self
end

return CreateServer
