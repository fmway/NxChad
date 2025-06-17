{ lib, ... }:
{
  performance = {
    byteCompileLua = {
      enable = lib.mkDefault true;
      configs = lib.mkDefault true;
      initLua = lib.mkDefault true;
      luaLib = lib.mkDefault true;
      nvimRuntime = lib.mkDefault true;
      plugins = lib.mkDefault true;
    };
  };
}
