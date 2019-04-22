local memory

function onDef_Profiler (t, mt)
  t.BeginMemoryProfile = function ()
    GC.Collect()
    GC.Stop()
    memory = GC.GetMemory()
  end

  t.EndMemoryProfile = function ()
    local dMemory = GC.GetMemory() - memory
    GC.Start()
    return dMemory
  end

  t.TimeGPU = function (name, fn)
    Draw.Flush()
    local begin = TimeStamp.Get()
    fn()
    Draw.Flush()
    local duration = TimeStamp.GetElapsedMs(begin)
    printf('%s : %.2f ms', name, duration)
  end
end
