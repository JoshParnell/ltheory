Env = {}

require('env.ext.GlobalEx')
Env.Ext  = requireAll('env.ext')
Env.Util = requireAll('env.util')
Env.Util.Namespace.Inline(Env.Util, 'Env.Util')

function Env.Call (fn)
  local _, err = xpcall(fn, ErrorHandler)
  if err then print(err) end
end
