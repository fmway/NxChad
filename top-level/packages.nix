{ inputs, config, lib, ... }:
{
  perSystem = { inputs', pkgs, ... }:
  {
    packages = {
      default = pkgs.makeNixvimWithModule {
        module.imports = [
          config.flake.nixvimModules.default
        ];
      };
      base46-cache = pkgs.callPackage ../pkgs/base46-cache.nix {
        helpers = lib.nixvim;
      };
      base46-patch = pkgs.callPackage ../pkgs/base46-patch {};
      injections-scm = pkgs.callPackage ../pkgs/injections-scm {
        inherit inputs;
      };
    };

    nixpkgs.config = {
      packageOverrides = pkgs:
        inputs'.nixvim.legacyPackages;
      allowUnfree = true;
    };
    legacyPackages = pkgs;
  };
}
