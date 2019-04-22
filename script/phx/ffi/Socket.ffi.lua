-- Socket ----------------------------------------------------------------------
local Socket

local ffi = require('ffi')

do -- C Definitions
  ffi.cdef [[
    Socket* Socket_Create      (SocketType);
    void    Socket_Free        (Socket*);
    void    Socket_Bind        (Socket*, int port);
    cstr    Socket_Read        (Socket*);
    Bytes*  Socket_ReadBytes   (Socket*);
    void    Socket_Write       (Socket*, cstr);
    void    Socket_WriteBytes  (Socket*, Bytes*);
    Socket* Socket_Accept      (Socket*);
    void    Socket_Listen      (Socket*);
    int     Socket_ReceiveFrom (Socket*, void* data, size_t len);
    cstr    Socket_GetAddress  (Socket*);
    void    Socket_SetAddress  (Socket*, cstr addr);
    int     Socket_SendTo      (Socket*, void const* data, size_t len);
  ]]
end

do -- Global Symbol Table
  Socket = {
    Create      = libphx.Socket_Create,
    Free        = libphx.Socket_Free,
    Bind        = libphx.Socket_Bind,
    Read        = libphx.Socket_Read,
    ReadBytes   = libphx.Socket_ReadBytes,
    Write       = libphx.Socket_Write,
    WriteBytes  = libphx.Socket_WriteBytes,
    Accept      = libphx.Socket_Accept,
    Listen      = libphx.Socket_Listen,
    ReceiveFrom = libphx.Socket_ReceiveFrom,
    GetAddress  = libphx.Socket_GetAddress,
    SetAddress  = libphx.Socket_SetAddress,
    SendTo      = libphx.Socket_SendTo,
  }

  if onDef_Socket then onDef_Socket(Socket, mt) end
  Socket = setmetatable(Socket, mt)
end

do -- Metatype for class instances
  local t  = ffi.typeof('Socket')
  local mt = {
    __index = {
      managed     = function (self) return ffi.gc(self, libphx.Socket_Free) end,
      create      = libphx.Socket_Create,
      free        = libphx.Socket_Free,
      bind        = libphx.Socket_Bind,
      read        = libphx.Socket_Read,
      readBytes   = libphx.Socket_ReadBytes,
      write       = libphx.Socket_Write,
      writeBytes  = libphx.Socket_WriteBytes,
      accept      = libphx.Socket_Accept,
      listen      = libphx.Socket_Listen,
      receiveFrom = libphx.Socket_ReceiveFrom,
      getAddress  = libphx.Socket_GetAddress,
      setAddress  = libphx.Socket_SetAddress,
      sendTo      = libphx.Socket_SendTo,
    },
  }

  if onDef_Socket_t then onDef_Socket_t(t, mt) end
  Socket_t = ffi.metatype(t, mt)
end

return Socket
