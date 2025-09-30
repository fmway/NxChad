{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs";
    fmway-lib.url = "github:fmway/lib";
    fmway-modules.url = "github:fmway/modules";
    fmway-modules.inputs.fmway-lib.follows = "fmway-lib";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
  };

  outputs = { fmway-lib, ... } @ inputs: let
    inherit (fmway-lib) lib;
  in lib.mkFlake {
    inherit inputs;
    src = ./.;
  } {
    imports = [
      # expose lib to flake outputs
      ({ lib, ... }: { flake = { inherit lib; }; })
    ];
  };
}
