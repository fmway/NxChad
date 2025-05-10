# NxChad - NvChad UI in nixvim
NxChad is a nixvim module that brings the UI feel of NvChad to your Neovim setup-powered by the Nix ecosystem.

## Features
You can use all the features in nvchad, but a few things are different:
- **Nixvim based**. NxChad using [nixvim](https://github.com/nix-community/nixvim), instead just plain lua. You still have full access to Lua if you prefer, but your plugins and configuration are managed declaratively via nix.
- **Fast Lazy Loading with lz-n**. Instead of `lazy.nvim`. NxChad uses [lz-n](https://github.com/nixvim/lz-n) for plugin lazy loading. While `lazy.nvim` supported in nixvim, `lz-n` integrates more flexibly and predictable (as proven in [nvchad.nix](https://github.com/fmway/nvchad.nix))
- **Temporary Theme Switching**. Change your color scheme on-the-fly without altering your core config. If you want a theme change to stick, simply write it to your nixvim config

## Demo
You can try it without installing it into the system using `nix run` or `nix shell`
```bash
$ nix run github:fmway/nxchad --override-input nixpkgs flake:nixpkgs
# or use nix shell
$ nix shell github:fmway/nxchad --override-input nixpkgs flake:nixpkgs
$ nvim
```

## Installation
Currently, nxchad is only supported on flakes

1. Add `nixvim` and `nxchad` in your inputs.
   ```nix
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
     nixvim.url = "github:nix-community/nixvim";
     nixvim.inputs.nixpkgs.follows = "nixpkgs";
     nxchad.url = "github:fmway/nxchad";
     # This is important, since nxchad dosn't add nixpkgs repo in dependencies
     nxchad.inputs.nixpkgs.follows = "nixpkgs";

     # ... 
   };
   ```
2. Import `nxchad` to your configuration.

   You can import `nxchad` in Home Manager, NixOS, nix-darwin, or in standalone package. Here is the example:
   <details> 
      <summary>Home Manager</summary>

      ```nix
      {
        outputs = { nixpkgs, home-manager, nxchad, nixvim, ... }:
        {
          homeConfigurations.user = home-manager.lib.homeConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              nixvim.homeManagerModules.nixvim
              nxchad.homeManagerModules.nixvim
              {
                programs.nixvim.enable = true;
                programs.nixvim = {
                  # set relative number
                  opts.relativenumber = true;
                };
              }
              # ...
            ];
          };
        };
      }
      ```
   </details>
   <details> 
      <summary>NixOS</summary>

      ```nix
      outputs = { nixpkgs, nxchad, nixvim, ... }:
      {
        nixosConfigurations.localhost = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixvim.nixosModules.nixvim
            nxchad.nixosModules.nixvim
            {
              programs.nixvim.enable = true;
              programs.nixvim = {
                # change theme nvchad
                nvchad.config.base46.theme = "starlight";
              };
              # ...
            }
          ];
        };
      };
      ```
   </details>
   <details> 
      <summary>Nix Darwin</summary>

      ```nix
      outputs = { nixpkgs, nix-darwin, nixvim, nxchad, ... }:
      {
        darwinConfigurations = nix-darwin.lib.darwinSystem {
          modules = [
            nixvim.nixDarwinModules.nixvim
            nxchad.nixDarwinModules.nixvim
            {
              programs.nixvim.enable = true;
              programs.nixvim = {
                # add vim-notify
                plugins.notify.enable = true;
              };
              # ...
            }
          ];
        };
      }
      ```
   </details>
   <details> 
      <summary>Standalone</summary>

      Example in standalone + nixos
      ```nix
      outputs = { nixpkgs, nxchad, nixvim, ... }:
      {
        nixosConfigurations.localhost = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ pkgs, ... }: {
              environment.systemPackages = [
                nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
                  module = {
                    imports = [
                      nxchad.nixvimModules.default
                      # ...
                    ];

                    # add toggleterm plugin
                    plugins.toggleterm.enable = true;
                    # lazyload
                    plugins.toggleterm.lazyLoad = {
                      enable = true;
                      settings.event = [ "User FilePost"];
                    };
                  };
                };
              ];
            })
            # ...
          ];
        };
      };
      ```
   </details>
  
## Configuration

If you want to configure chadrc, you can write it in `nxchad.config` or `nvchad.config`. The configuration specifications are the same as for chadrc, you can find all the options at https://nxchad-options.pages.dev or https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua. For example, to disable nvdash at startup:
```nix
nxchad.config.nvdash.load_on_startup = false;
```

## Roadmap
- [x] lazy load plugins.
- [x] base46 compability
- [x] chadrc options
- [ ] options to choose `blink.cmp` or `nvim-cmp` (since nvchad ui supports both)
- [ ] raw lua support options

## Related projects
- [nix4nvchad](https://github.com/nix-community/nix4nvchad) - a wrapper of neovim that sits on top of nixpkgs
