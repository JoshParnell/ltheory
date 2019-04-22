-- TODO : Ensure mt exists in genffi

function onDef_File (t, mt)
  t.Read = function (path)
    local s = libphx.File_ReadCstr(path)
    if s ~= nil then return ffi.string(s) else return nil
    end
  end
end
