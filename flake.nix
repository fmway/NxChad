{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs";
    fmway-nix.url = "github:fmway/fmway.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
  };

  outputs = { fmway-nix, ... } @ inputs: let
    inherit (fmway-nix) lib;
  in lib.mkFlake {
    inherit inputs;
    specialArgs.lib = lib.optionals (lib.pathIsRegularFile ./lib/default.nix) [
      (self: super: lib.fmway.doImport ./lib { lib = self; inherit inputs; })
    ];
  } {
    imports = let
        top-level = lib.fmway.genImportsWithDefault ./top-level;
        modules = { self, config, lib, ... } @v: {
          flake = lib.fmway.genModules ./modules v;
        };
      in lib.optionals (lib.pathIsDirectory ./top-level) top-level
      ++ lib.optionals (lib.pathIsDirectory ./modules) [ modules ]
      ++ [
        # expose lib to flake outputs
        ({ lib, ... }: { flake = { inherit lib; }; })
      ];
  };
}
