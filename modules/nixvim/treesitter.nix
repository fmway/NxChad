{ internal, self, ... }:
{ lib, pkgs, ... }:
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

  # 60 th priority, so user can override using mkForce
  extraFiles."queries/nix/injections.scm".source = lib.mkOverride 60 self.packages.${pkgs.system}.injections-scm;
}
