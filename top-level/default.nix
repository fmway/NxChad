{ inputs, self, config, lib, ... } @ v:
{
  perSystem = { pkgs, system, ... }: {
    legacyPackages = pkgs;
    devShells.default = pkgs.mkShellNoCC {
      NIXD_PATH = lib.concatStringsSep ":" [
        "pkgs=${self.outPath}#legacyPackages.${system}"
        "nixvim=${self.outPath}#packages.${system}.default.options"
      ];
    };
  };
}
