#include "Directory.h"
#include "Engine.h"
#include "File.h"
#include "Lua.h"

#if WINDOWS
extern "C" {
  __declspec(dllexport) unsigned long NvOptimusEnablement = 0x00000001;
  __declspec(dllexport) int AmdPowerXpressRequestHighPerformance = 1;
}
#endif

int main (int argc, char* argv[]) {
  Engine_Init(2, 1);
  Lua* self = Lua_Create();
  char const* entryPoint = "./script/Main.lua";

  if (!File_Exists(entryPoint))
  {
    Directory_Change("../");
    if (!File_Exists(entryPoint))
      Fatal("can't find script entrypoint <%s>", entryPoint);
  }

  Lua_SetBool(self, "__debug__", DEBUG > 0);
  Lua_SetBool(self, "__embedded__", true);
  Lua_SetNumber(self, "__checklevel__", CHECK_LEVEL);
  Lua_DoFile(self, "./script/Main.lua");
  Lua_Free(self);
  Engine_Free();
  return 0;
}
