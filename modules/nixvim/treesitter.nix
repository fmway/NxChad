{ lib, ... }:
{
  _file = ./treesitter.nix;
  plugins.treesitter = {
    enable = true;
    lazyLoad.enable = true;
    settings = {
      auto_install = lib.mkDefault false;
      ensure_installed = [ "lua" "luadoc" "printf" "vim" "vimdoc" ];

      highlight.enable = lib.mkDefault true;
      highlight.use_languagetree = lib.mkDefault true;

      # indent.enable = lib.mkDefault true;
    };
    lazyLoad.settings = {
      event = ["BufReadPost" "BufNewFile"];
      cmd = [ "TSInstall" "TSBufEnable" "TSBufDisable" "TSModuleInfo" ];
    };
  };
}
