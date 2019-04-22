local Log = require('env.util.Log')

local Config = {}

Config.jit = {
  loom        = false, -- Loom HTML Dump (log_jloom.html)
  profile     = false, -- LuaJIT profiler enabled (log_jp.txt)
  profileInit = false, -- Include initialization in profiling?
  profileVM   = false, -- Profile JIT VM state instead of zone?
  verbose     = false, -- LuaJIT verbose output (log_jv.txt)
  dumpasm     = false, -- LuaJIT machine code dump (log_jd.txt)
}

if (Config.jit.profile or Config.jit.verbose or Config.jit.loom) and Config.jit.dumpasm then
  Log.Error('Config.jit.dumpasm requires profile, verbose, and loom to be off.')
end

Config.jit.tune = {
  maxTrace   = 10000, -- [1000] Max traces in the cache
  maxRecord  = 10000, -- [4000] Max recorded IR instructions in trace
  maxConst   = 1000, -- [500] Max IR constants of a trace
  maxSide    = 100, -- [100] Max side traces per trace
  maxSnap    = 1000, -- [500] Max snapshots per trace
  hotLoop    = 56, -- [56] Min iterations to consider a loop 'hot'
  hotExit    = 10, -- [10] Min taken exits to spawn a side trace
  trySide    = 4, -- [4] Max attempts to compile a side trace
  instUnroll = 4, -- [4] Max unroll factor for instable loops
  loopUnroll = 15, -- [15] Max unroll factor for loop ops in side traces
  callUnroll = 3, -- [3] Max unroll factor for pseudo-recursive calls
  recUnroll  = 2, -- [2] Min unroll factor for true recursion
  sizeMCode  = 2^13, -- [32] Size (KB) of each mcode area
  maxMCode   = 2^13, -- [512] Total size (KB) of all mcode areas
}

return Config
