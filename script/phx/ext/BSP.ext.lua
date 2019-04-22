local zone = require('jit.zone')

function onDef_BSP (t, mt)
  t.Create = function (...)
    zone('.BSP_Create')
    local e = libphx.Mesh_Validate(...)
    if e ~= 0 then
      print('BSP Incoming Mesh Error:')
      libphx.Error_Print(e)
    end

    local result = libphx.BSP_Create(...)
    zone()
    return result
  end
end
