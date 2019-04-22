-- TODO JP : Make better.

local ShaderVarCache = class(function (self, shader, vars)
  for i = 1, #vars do
    if shader:hasVariable(vars[i]) then
      self[vars[i]] = shader:getVariable(vars[i])
    else
      self[vars[i]] = -1
    end
  end
end)

return ShaderVarCache
