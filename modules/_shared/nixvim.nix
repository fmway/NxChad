{ internal, nixvimModules, ... }:
{ lib, ... }:
{
  _file = ./nixvim.nix;
  programs.nixvim.imports = [
    nixvimModules.default
    { nixpkgs.useGlobalPackages = lib.mkDefault true; }
  ];
}
